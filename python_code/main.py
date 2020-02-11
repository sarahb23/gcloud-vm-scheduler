import os, base64, json
from googleapiclient import errors, discovery
from google.auth import compute_engine

project = os.environ['PROJECT_ID']
zone = os.environ['ZONE']

credentials = compute_engine.Credentials()
compute = discovery.build('compute', 'v1', credentials=credentials)

def get_instances(compute, zone, project):
    all_instances = compute.instances().list(
        project=project,
        zone=zone
    ).execute()['items']
    instances = [
        i for i in all_instances if [
            h for h in i['labels'] if 'autostartstop' in i['labels'].keys() and i['labels']['autostartstop'] == 'true'
        ]
    ]
    return instances

def stop_instance(compute, zone, project, instance):
    return compute.instances().stop(
        project=project,
        zone=zone,
        instance=instance
    ).execute()

def start_instance(compute, zone, project, instance):
    return compute.instances().start(
        project=project,
        zone=zone,
        instance=instance
    ).execute()

def main(event, context):
    message = base64.b64decode(event['data']).decode('utf-8')
    instances = get_instances(compute, zone, project)
    if message == 'on':
        for i in instances:
            instance = i['name']
            start_instance(compute, zone, project, instance)
    elif message == 'off':
        for i in instances:
            instance = i['name']
            stop_instance(compute, zone, project, instance)