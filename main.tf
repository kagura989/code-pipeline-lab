provider "aws" { region = var.region }

resource "aws_s3_bucket" "artifact_bucket" { bucket = "${var.bucket_name}-${random_id.bucket_id.hex}" force_destroy = true }

resource "random_id" "bucket_id" { byte_length = 4 }

resource "aws_iam_role" "codepipeline_role" { name = "codepipeline-role"

assume_role_policy = jsonencode({ Version = "2012-10-17" Statement = [ { Action = "sts:AssumeRole" Effect = "Allow" Principal = { Service = "codepipeline.amazonaws.com" } } ] }) }

resource "aws_iam_role_policy_attachment" "codepipeline_policy" { role       = aws_iam_role.codepipeline_role.name policy_arn = "arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess" }

resource "aws_iam_role" "codebuild_role" { name = "codebuild-role"

assume_role_policy = jsonencode({ Version = "2012-10-17" Statement = [ { Action = "sts:AssumeRole" Effect = "Allow" Principal = { Service = "codebuild.amazonaws.com" } } ] }) }

resource "aws_iam_role_policy_attachment" "codebuild_policy" { role       = aws_iam_role.codebuild_role.name policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess" }

resource "aws_codebuild_project" "build_project" { name          = "codebuild-project" description   = "Build project for CodePipeline" service_role  = aws_iam_role.codebuild_role.arn

artifacts { type = "CODEPIPELINE" }

environment { compute_type                = "BUILD_GENERAL1_SMALL" image                       = "aws/codebuild/standard:5.0" type                        = "LINUX_CONTAINER"

environment_variables = [
  {
    name  = "EC2_IP"
    value = var.ec2_ip
  },
  {
    name  = "PRIVATE_KEY"
    value = var.private_key
    type  = "PLAINTEXT"
  }
]

}

source { type = "CODEPIPELINE" } }

resource "aws_codepipeline" "codepipeline" { name     = "devops-lab-pipeline" role_arn = aws_iam_role.codepipeline_role.arn

artifact_store { location = aws_s3_bucket.artifact_bucket.bucket type     = "S3" }

stage { name = "Source"

action {
  name             = "Source"
  category         = "Source"
  owner            = "ThirdParty"
  provider         = "GitHub"
  version          = "1"
  output_artifacts = ["source_output"]

  configuration = {
    Owner      = var.github_owner
    Repo       = var.github_repo
