# Trigger remote build for amis 

```
gh workflow run build.yml -R r33drichards/free-ngrok
```

view logs for workflow run
```
gh run watch -R r33drichards/free-ngrok
```


# Deployment steps 

## prerequisites 

aws credentials configured locally, you can do this with 

```
aws configure
```

## bootstrapping 

### terraform state management 

we need to provision an s3 bucket and dynammo db table for our terraform state management 

```
cd state-management
terraform init
terraform plan
terraform apply
```

if successful, you should see some output like this 

```
Outputs:

dynamodb_table_name = "terraform-state-lock-73cea43c7d6aa30e"
state_bucket_name = "terraform-state-73cea43c7d6aa30e"
```

copy terraform state to s3 bucket 

```
aws s3 cp terraform.tfstate s3://terraform-state-73cea43c7d6aa30e/state-management/terraform.tfstate

### oidc

first we need to set up oidc to give github actions permissions to provision resources on our behalf 

change into the oidc directory 

```
cd oidc
```

edit `terraform.tfvars` to reflect the correct values 

```
aws_region     = "us-west-2"
role_name      = "github-actions-oidc-role-free-ngrok"
repositories   = ["r33drichards/free-ngrok"]
s3_bucket_name = "free-ngrok-amis"
```

edit main.tf to include the bucket and dynamodb table from the previous step 

```
terraform {
  backend "s3" {
    bucket         = "terraform-state-73cea43c7d6aa30e" # Replace with your bucket name
    key            = "oidc/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-state-lock-73cea43c7d6aa30e" # Replace with your table name
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
```

then apply the terraform 

```
terraform init
terraform plan
terraform apply
```

if everything is working properly, you should see an output like this 

```
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

github_oidc_role_arn = "arn:aws:iam::<your account id>:role/github-oidc-role-0b63a2a04f37c8ee"
```

### provision s3 bucket and ec2 for the reverse proxy 

