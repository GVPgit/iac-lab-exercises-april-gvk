terraform {
  backend "s3" {
    bucket = "mys3gvk"
    key    = "terraform.tfstate"
    region = "ap-southeast-2"

    dynamodb_table = "iac-lab-exercises-april-gvk-tfstate-locks"
    encrypt        = true
  }
}
