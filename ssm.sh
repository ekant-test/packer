#!/bin/bash
# Get the AMI ID from manifest file.
AMI_ID=$(jq -r '.builds[-1].artifact_id' manifest.json | cut -d ":" -f2)

# Add the AMI ID to Paramater Store.
aws ssm put-parameter \
    --name "ami_test" \
    --type "String" \
    --value "$AMI_ID" \
    --tier Standard \
    --overwrite

# After execution remove manifest file which was used for temproraey extraction of AMI ID..
rm -rf manifest.json
