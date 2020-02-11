# GCP Instance Scheduler in Terraform and Python

### Project rationale:
This project is meant to address cost issues with DEVELOPMENT Compute Engine instances. A typical use case would be a software or application POC that uses one or more instances that does not necessarily need to be accessed by developers outside of business hours. This saves on Compute costs by more than halving an instances uptime.

A production use case would be an internal application that is distributed among several instances and is used heavily during regular business hours, but rarely accessed on nights and weekends.

**This Terraform project deploys:**
- A Python 3.7 CloudFunction that uses the Python SDK to start and stop instances
- A PubSub topic that sends a message (`"off"` or `"on"`) to the Cloud Function
- Two Cloud Scheduler Jobs that trigger the PubSub topic

**This Project assumes that:**
- You have a GCP Project with existing instances
- You have a Service Account with a role sufficient enough to create the resources in the Project
- You have Terraform and the gcloud command line tool installed on your system

#### Clone the repo to get started
```
git clone https://github.com/zach-23/gcloud-vm-scheduler.git
cd gcloud-vm-scheduler/
```
----------------------------------------------------------------

## Environment setup
Before running this example, you will need to set up your GCP environment. Depending on your system, you will run an init script. This script enables the `cloudscheduler`, `cloudfunctions`, and `pubsub` APIs in your GCP project.
**If these APIs are already enabled in your project you can skip to the next section.**

#### MacOS / Linux
1. To enable the APIs, `export` your GCP Project ID as an environment variable:
   ```
   export PROJECT_ID="<YOUR_PROJECT_ID>"
   ```

2. Then run the `enable_services.sh` script:
   ```
   bash init_scripts/enable_services.sh
   ```

#### Windows
1. To enable the APIs, `set` your GCP Project ID as an environment variable:
   ```
   $Env:PROJECT_ID = "<YOUR_PROJECT_ID>"
   ```

2. Then run the `enable_services.ps1` script:
   ```
   ./init_scripts/enable_services.ps1
   ```

----------------------------------------------------------------

## Instance tags
- The Cloud Function will only apply to instances with a specific label

- Attach a [label](https://cloud.google.com/compute/docs/labeling-resources) to each instance
  ```
  autostartstop: true
  ```

- Only instances with this label will be started or stopped

- You can change what labels are included in [main.py](./python_code/main.py)
  ```
  def get_instances(compute, zone, project):
  ...
  instances = [
        i for i in all_instances if [
            h for h in i['labels'] if 'autostartstop' in i['labels'].keys() and i['labels']['autostartstop'] == 'true'
        ]
    ]
  ...
  ```

----------------------------------------------------------------

## Terraform usage
Update your project variables in [terraform.tfvars](./terraform.tfvars):
```
key_file      = "/FULL/PATH/TO/YOUR/SERVICE_ACCOUNT/KEY_FILE" #You can save the key file in the project directory. All JSON files will be gitignored in this project.
project       = "YOUR_GCP_PROJECT_ID"
region        = "YOUR_PREFERRED_REGION"
zone          = "YOUR_PREFERRED_ZONE" #Must be in your chosen region!
bucket_name   = "CODE_BUCKET" #Must be a pre-existing bucket in your GCP project
```

Initialize your Terraform project:
```
terraform init
```

Export a plan:
```
terraform plan -out plan -var-file=terraform.tfvars
```

Apply the plan:
```
terraform apply plan
```

----------------------------------------------------------------
## Change the timing of your Cloud Scheduler Job

In the [main.tf](./main.tf) file, take a look at the two resources blocks titled `google_cloud_scheduler_job`

```
resource "google_cloud_scheduler_job" "vm_on" {
    name        = "turnVMOn"
    description = "Turn on VM at 6am EST M-F"
    schedule    = "0 6 * * 1-5"
    time_zone   = "America/New_York"
```

Change the `schedule` argument according to a `cron` statement. Optionally, you can change the `time_zone` argument to a supported timezone to be used for interpreting the `cron` expression.