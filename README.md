# Cloud Engineer Assignment

## Rules

Duration : 1-2 weeks

Based on the following architecture diagram, implement the infrastructure using CloudFormation in Yaml or CDK python, taking into account that:
- It should be easy to deploy and updates the infrastructure
- It should be possible to re-use the template to deploy a 2nd iteration of that infrastructure in the same AWS account and the same region
- You are free to use resource types (EC2 instance types, ECS instance type, OS, DB instance type) that you want 

1. Share your code repository with us.
2. You should also provide a plan for disaster recovery.
![image](./Archi.png)

## Deployment process

```sh
aws configure
git clone https://github.com/inkunzi-x09/sonarsource.git
cd terraformSonar
terraform init
terraform plan
terraform apply
```

If you want to deploy a second architecture you can copy the folder "terraformSonar" and paste it wherever you want.
Then, in the backend.tf file, you have to change the name of the destination bucket S3 where the state files will be stored.
Make sure that, in your AWS account, you have created another bucket with the same name provided before.

## Way of improvements

- Autoscaling group with launch template for ECS, RDS and EC2 service
- CloudWatch logs for VPC Flow Logs, EC2 instances, RDS databases and ECS clusters
- Put in place AWS Backup plan