<h1 align="center"> 🧭 JobTracker – Cloud-Native Job Application Management System </h1> 

A fully automated Job Application Management System built with a cloud-native approach.
This project showcases modern DevOps practices using Terraform, AWS, CI/CD, and Flask —
integrated into a single, maintainable deployment workflow.

🌐 Overview

JobTracker simplifies tracking and managing job applications with a secure and scalable architecture.
The system automates both infrastructure provisioning and application deployment using GitHub Actions,
ensuring reliability and minimal manual intervention.

🏗️ Architecture

![JobTracker Architecture](https://raw.githubusercontent.com/Miyata-lee/Job-Tracker/main/Architecture.svg)



The architecture follows a modular design:
- **Frontend:** HTML, CSS, JS served via S3 + CloudFront  
- **Backend:** Flask application hosted on AWS EC2  
- **Database:** Amazon RDS (PostgreSQL)
- **Storage:** S3 for static assets  
- **Networking:** VPC with public/private subnets, security groups, and NAT gateway  
- **Automation:** Terraform for IaC and GitHub Actions for CI/CD  


✨ Highlights

- VPC with public/private subnets across two Availability Zones.
- Application Load Balancer routing traffic to EC2 instances on port 5000.
- Auto Scaling Group for high availability and fault tolerance.
- RDS MySQL in private subnets for secure database hosting.
- S3 + CloudFront for static asset delivery and caching.
- GitHub Actions CI/CD pipeline with OIDC (no long-lived AWS keys).

⚙️ Tech Stack

| Category              | Tools Used                               |
| --------------------- | ---------------------------------------- |
|   Infrastructure      | Terraform                                |
|   Cloud Provider      | AWS (EC2, RDS, S3, CloudFront, IAM, VPC) |
|   CI/CD               | GitHub Actions                           |
|   Version Control     | Git & GitHub                             |

🔒 Security Design

Security Groups:

- ALB Security Group — Inbound: 80/443 from the internet; Egress: 5000 to EC2 instances.
- EC2 Security Group — Inbound: 5000 from ALB SG, optional 22 (SSH) from operator IP; Egress: 3306 to RDS.
- RDS Security Group — Inbound: 3306 from EC2 SG only.

IAM Roles:

- EC2 Instance Role: Grants least-privilege access for app and logging.
- GitHub Actions OIDC Role: Assumed dynamically for Terraform and deployment.

🔑 Repository Secrets

| Name	               |  Description       |
| -------------------  | ------------------ |
| DB_USER	RDS          |  username          | 
| DB_PASSWORD	RDS      |  password          |
| EC2_PRIVATE_KEY	PEM  |  private key       |
| SECRET_KEY	         |  Flask secret key  |

⚙️ Key Decisions

- Used public EC2 instances with tight security groups instead of private EC2 + NAT Gateway to minimize cost and simplify deployment.
- CloudFront + S3 handle static content and reduce EC2 load.
- ALB + ASG provide horizontal scaling and self-healing.
- OIDC-based GitHub Actions eliminate the need for stored AWS credentials.

🚀 CI/CD Workflow

- Two automated pipelines manage the deployment process:
- Infrastructure Workflow: Runs Terraform plan and apply when updates are pushed.
- Application Workflow: Builds and deploys the Flask app to EC2, uploads static files to S3,
- and invalidates CloudFront cache for instant content updates.


📸 Screenshots

🎓 What This Project Proved

I can:
- Design cloud architecture from scratch
- Write infrastructure as code (Terraform)
- Automate deployments (CI/CD)
- Implement security best practices
- Think about scaling and reliability
- Debug complex AWS issues
- Make pragmatic tradeoffs (cost vs. complexity)

🎯 Final Thought

 The goal wasn't perfection - it was learning.


👤 Author

Ashik — Cloud & DevOps 

GitHub: [github.com/Miyata-lee](https://github.com/Miyata-lee/Job-Tracker.git)

LinkedIn: 
