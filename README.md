# terraform
terraform repo to provide infrastructure to project
Create AWS resources for MeetlyOmni Project.

terraform {
  backend "s3" {
    bucket = "myterraform-meetly"
    key    = "meetlyomni-frontend/terraform.tfstate"
    region = "ap-southeast-2"
  }
}

