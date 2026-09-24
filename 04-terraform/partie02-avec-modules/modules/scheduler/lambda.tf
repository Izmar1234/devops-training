# ============================================================
# ARCHIVE ZIP DU CODE PYTHON
# ============================================================

data "archive_file" "scheduler_lambda" {
  type = "zip"

  source_file = var.lambda_source_file
  output_path = var.lambda_output_path
}


# ============================================================
# FONCTION LAMBDA
# ============================================================

resource "aws_lambda_function" "scheduler" {
  function_name = "${var.name_prefix}_lambda_scheduler"

  description = (
    "Démarre et arrête les deux instances EC2 du TP"
  )

  filename = data.archive_file.scheduler_lambda.output_path

  source_code_hash = (
    data.archive_file.scheduler_lambda.output_base64sha256
  )

  role = aws_iam_role.scheduler_lambda.arn

  runtime = "python3.12"
  handler = "scheduler.lambda_handler"

  architectures = ["x86_64"]

  memory_size = 128
  timeout     = 30

  reserved_concurrent_executions = 1

  environment {
    variables = {
      TARGET_INSTANCE_IDS = join(
        ",",
        [
          var.docker_instance_id,
          var.nodejs_instance_id
        ]
      )
    }
  }

  tags = {
    Name = "${var.name_prefix}_lambda_scheduler"
    Role = "ec2-scheduler"
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_scheduler,
    aws_cloudwatch_log_group.scheduler
  ]
}
