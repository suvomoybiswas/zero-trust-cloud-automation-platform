terraform {
    backend "s3" {
        bucket = "suvo-zero-trust-tf-state-2026"
        key = "terraform/state.tfstate"
        region = "us-east-1"
        dynamodb_table = "terraform-state-lock"
        encrypt = true
    }
}