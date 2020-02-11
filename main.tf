provider "google" {
    credentials = var.key_file
    project     = var.project
    region      = var.region
    zone        = var.zone
    version     = "~> 3.0.0"
}

resource "google_pubsub_topic" "vm_scheduler" {
    name = "turnVMOnOff"
}

resource "google_cloud_scheduler_job" "vm_on" {
    name        = "turnVMOn"
    description = "Turn on VM at 6am EST M-F"
    schedule    = "0 6 * * 1-5"
    time_zone   = "America/New_York"

    pubsub_target {
        topic_name = google_pubsub_topic.vm_scheduler.id
        data       = base64encode("on")
    }
}

resource "google_cloud_scheduler_job" "vm_off" {
    name        = "turnVMOff"
    description = "Turn off VM at 6pm EST M-F and remain off on Weekends"
    schedule    = "0 18 * * 1-5"
    time_zone   = "America/New_York"

    pubsub_target {
        topic_name = google_pubsub_topic.vm_scheduler.id
        data       = base64encode("off")
    }
}

data "archive_file" "py-zip" {
    type        = "zip"
    output_path = "${path.module}/turnVMOnOff.zip"
    source_dir  = "${path.module}/python_code"
}

resource "google_storage_bucket_object" "py-zip" {
    name   = "turnVMOnOff"
    source = "${path.module}/turnVMOnOff.zip"
    bucket = var.bucket_name

    depends_on = [data.archive_file.py-zip]
}

resource "google_cloudfunctions_function" "resources" {
    name        = "turnVMOnOff"
    description = "Turns VM on or off according to Cloud Scheduler Job"
    runtime     = "python37"

    available_memory_mb   = 128
    entry_point           = "main"
    source_archive_bucket = var.bucket_name
    source_archive_object = google_storage_bucket_object.py-zip.name
    event_trigger {
        event_type = "google.pubsub.topic.publish"
        resource   = google_pubsub_topic.vm_scheduler.id
    }
    
    environment_variables = {
        PROJECT_ID    = var.project
        ZONE          = var.zone
    }

    depends_on = [google_storage_bucket_object.py-zip]
}