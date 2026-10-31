#!/bin/bash
set -e  # Stop the script if a command fails

# Get our ALB website URL from Terraform.
ALB_URL="http://$(terraform output -raw alb_dns_name)"

# Send 5 requests to check if the website is available.
for i in {1..5}; do
    curl -fsS -o /dev/null -w "Request $i: HTTP %{http_code}\n" "$ALB_URL"
    sleep 2
done

echo "Test completed successfully!"
