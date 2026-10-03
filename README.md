# aws-static-app-devops-pipeline
My personal project

Project Architecture
                    GitHub
                       │
             ┌─────────┴─────────┐
             │                   │
       Application Code     Terraform Code
             │                   │
             ↓                   ↓
       GitHub Actions       GitHub Actions
          CI/CD                  │
             │                   │
             ↓                   ↓
        Docker Hub              AWS
             │             ┌─────┴─────┐
             │             │    VPC    │
             │             │           │
             │             │    ALB    │
             │             │     │     │
             │             │    ASG    │
             │             │     │     │
             └─────────────┼─── EC2 ───┘
                           │
                           ↓
                     Docker Container
