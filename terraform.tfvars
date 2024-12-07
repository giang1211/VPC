aws_region= "us-east-1"
vpc_cidr=  "10.0.0.0/16"
subnet_count =3
name=  "my-vpc"


tags = {
    "owner"          = "s8giang"
    "environment"    = "dev"
    "create_by"      = "Terraform"
    "cloud_provider" = "aws"
}
