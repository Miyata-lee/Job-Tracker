<h1 align="center"> 🧭 JobTracker – Cloud-Native Job Application Management System </h1> 

A fully automated Job Application Management System built with a cloud-native architecture.
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
- **Database:** Amazon RDS (MySQL)
- **Storage:** S3 for static assets  
- **Networking:** VPC with public/private subnets and tightly configured security groups  
- **Automation:** Terraform for IaC and GitHub Actions for CI/CD


📂 Project Structure                   
```bash
Job-Tracker/
├── .github/
│   └── workflows/
│       ├── application.yml
│       └── infrastructure.yml       
├── application/                    
├── environment/                     
├── modules/                        
│   ├── compute/                   
│   ├── database/                   
│   ├── frontend/                  
│   ├── network/                   
│   └── security/                   
├── scripts/                         
├── .gitignore
├── Architecture.svg
└── README.md
```


✨ Key Features

- VPC across two Availability Zones
- ALB routing traffic to EC2 instances
- Auto Scaling Group for high availability and fault tolerance
- RDS MySQL in private subnets for secure database hosting
- CloudFront + S3 for caching and faster delivery
- GitHub Actions CI/CD pipeline with OIDC (no long-lived AWS keys)
- Optimized for cost and simplicity — public EC2 instances with tightly controlled security groups were used instead of a NAT Gateway setup

⚙️ Tech Stack

| Category              | Tools Used                               |
| --------------------- | ---------------------------------------- |
|   Infrastructure      | Terraform                                |
|   Cloud Provider      | AWS (EC2, RDS, S3, CloudFront, IAM, VPC) |
|   CI/CD               | GitHub Actions                           |
|   Version Control     | Git & GitHub                             |

🔒 Security Design

Security Groups:

- ALB SG — Inbound: 80/443 from the internet; Egress: 5000 to EC2 instances.
- EC2 SG — Inbound: 5000 from ALB SG, optional 22 (SSH) from operator IP; Egress: 3306 to RDS.
- RDS SG — Inbound: 3306 from EC2 SG only.

IAM Roles:

- EC2 Instance Role: Grants least-privilege access for app and logging.
- GitHub Actions OIDC Role: Temporary credentials for Terraform and deployments.

🚀 CI/CD Workflow

Two fully automated pipelines:
- Infrastructure Pipeline: Terraform plan → apply (runs on infra changes)
- Application Pipeline: Builds Flask app → deploys to EC2 → syncs S3 → invalidates CloudFront cache


📸 Screenshots

<img width="1062" height="172" alt="full flow" src="https://github.com/user-attachments/assets/9b09dbb1-2570-4664-a62d-cec0a9dc6bd8" />

<img width="1330" height="343" alt="cl" src="https://github.com/user-attachments/assets/93359555-7dc4-4421-a8c3-de1f1ddde383" />

<img width="1364" height="724" alt="signup" src="https://github.com/user-attachments/assets/7cc04758-fec3-4cd0-a965-1bc5a64c5072" />

<img width="1360" height="712" alt="login" src="https://github.com/user-attachments/assets/0cafa677-5ee8-4dd0-ac76-c5540a076699" />

<img width="1365" height="723" alt="dash" src="https://github.com/user-attachments/assets/b040a16f-a89c-4ef0-955e-3cf866ef941d" />

<img width="1366" height="714" alt="form" src="https://github.com/user-attachments/assets/7fddaea0-2e96-4e04-9804-8701b50aca9c" />

<img width="1364" height="728" alt="lis" src="https://github.com/user-attachments/assets/0f50f10a-8934-4365-9ecf-eb913ac530ec" />

<img width="1366" height="405" alt="boa" src="https://github.com/user-attachments/assets/c6a199f6-064d-4a01-b824-8d0e9a3cfb6a" />

<img width="1351" height="598" alt="ec" src="https://github.com/user-attachments/assets/a7870271-1d37-4380-810a-02a50102cb48" />

<img width="1365" height="467" alt="ALB" src="https://github.com/user-attachments/assets/f969f4e3-544b-4187-a668-22ac495fd6cc" />

<img width="1359" height="640" alt="vpc" src="https://github.com/user-attachments/assets/32f404ff-0a63-4fba-9c2b-6582eb445902" />









🎓 What This Project Demonstrates

- Designing end-to-end cloud architecture
- Writing Infrastructure as Code (Terraform)
- Implementing CI/CD with GitHub Actions
- Managing AWS security and IAM roles
- Balancing performance, reliability, and cost

🎯 Final Thought

The goal wasn’t perfection — it was to learn and build something real using end-to-end DevOps principles.


👤 Author: Ashik Meeran 

GitHub: https://github.com/Ashik-Techie

LinkedIn: www.linkedin.com/in/ashik-meeran
