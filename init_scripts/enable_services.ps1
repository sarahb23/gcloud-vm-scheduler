$services = "cloudscheduler", "cloudfunctions", "pubsub"

foreach ($SRVC in $services) {
    gcloud services enable "$SRVC.googleapis.com" --project=$Env:PROJECT_ID
}