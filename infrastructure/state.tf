# Reference: https://technology.doximity.com/articles/terraform-s3-backend-best-practices

resource "aws_kms_key" "terraform-bucket-key" {
    description             = "This key is used to encrypt bucket objects"
    deletion_window_in_days = 30
    enable_key_rotation     = true
}

resource "aws_kms_alias" "key-alias" {
    name          = local.state-bucket-kms-alias
    target_key_id = aws_kms_key.terraform-bucket-key.key_id
}


# S3 bucket creation and access management for the bucket
resource "aws_s3_bucket" "terraform-state" {
    bucket = local.state-bucket-name
}

resource aws_s3_bucket_acl "state-bucket-acl" {
    bucket = aws_s3_bucket.terraform-state.id
    acl    = "private"
}

resource aws_s3_bucket_versioning "state-bucket-versioning" {
    bucket = aws_s3_bucket.terraform-state.id
    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state-bucket-encryption" {
    bucket = aws_s3_bucket.terraform-state.bucket
    rule {
        apply_server_side_encryption_by_default {
            kms_master_key_id = aws_kms_key.terraform-bucket-key.arn
            sse_algorithm     = "aws:kms"
        }
    }
}

resource "aws_s3_bucket_public_access_block" "block" {
    bucket = aws_s3_bucket.terraform-state.id
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true

}


# DynamoDB table lock, will be used to prevent two team members 
# from writing to the state file at the same time by table lock
resource "aws_dynamodb_table" "terraform-state" {
    name           = local.dynamodb-state-lock-table
    read_capacity  = 20
    write_capacity = 20
    hash_key       = "LockID"

    attribute {
        name = "LockID"
        type = "S"
    }
}
