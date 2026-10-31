# Changelog

All notable changes to this project are documented here.

## [1.0.0] - 2026-10-31

### Added
- Custom Terraform VPC module with two public and two private subnets across two AWS Availability Zones.
- Internet Gateway, route tables, and a single zonal NAT Gateway for private subnet internet access.
- Two private Ubuntu EC2 instances with Security Groups restricting inbound application traffic to the ALB.
- Internet-facing Application Load Balancer with HTTP listeners, target groups, and health checks.
- Automated Apache2 and Tooplate website deployment using Bash and EC2 user data.
- Reusable Bash script for application availability and failover testing.

### Tested
- Verified successful deployment of the website through the ALB DNS name.
- Confirmed healthy EC2 targets and successful HTTP health checks.
- Simulated a Web01 failure and verified that Web02 continued serving the application.
- Successfully completed five HTTP requests during the failover test.

### Documentation
- Added architecture diagram and deployment screenshots.
- Documented real-world use cases, infrastructure decisions, challenges, and production improvements.
- Explained the cost-versus-availability trade-off of using one NAT Gateway.

### Cleanup
- Destroyed the lab infrastructure using Terraform after testing to avoid ongoing resource charges.

**Release status:** v1.0.0 — Initial completed release.
