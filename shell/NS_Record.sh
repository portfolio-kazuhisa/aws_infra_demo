#!/bin/bash
###############################################
# get_nsrecords
###############################################

aws route53 list-resource-record-sets \
  --hosted-zone-id $(aws route53 list-hosted-zones \
    --query "HostedZones[?Name == 'portfolio-kazuhisa.com.'].Id" \
    --output text) \
  --query "ResourceRecordSets[?Type == 'NS' && Name == 'portfolio-kazuhisa.com.']" \
  --output text | awk '$1 == "RESOURCERECORDS" {print $2}' 