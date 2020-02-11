#!/usr/bin/env bash

services = ("cloudfunctions" "cloudscheduler" "pubsub")

for SRVC in ${services[@]}; do
    gcloud services enable \
        $SRVC.googleapis.com \
        --project=$PROJECT_ID
done