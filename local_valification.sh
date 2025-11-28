#!/bin/bash

###############################################
# ローカル検証用
###############################################
timestamp=$(date +"%Y%m%d-%H%M%S")
log="logs/result-${timestamp}.log"

terraform apply -auto-approve 2>&1 | tee ${log}
terraform destroy -auto-approve 2>&1 | tee -a ${log}
exit 0