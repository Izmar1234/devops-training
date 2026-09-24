# ============================================================
# ARCHIVE ZIP DU CODE PYTHON
# ============================================================

data "archive_file" "scheduler_lambda" {
  type = "zip"

  source_file = (
    "${path.module}/lambda/scheduler.py"
  )

  output_path = (
    "${path.module}/lambda/scheduler.zip"
  )
}


# ============================================================
# FONCTION LAMBDA DE DÉMARRAGE ET D'ARRÊT DES EC2
# ============================================================

resource "aws_lambda_function" "scheduler" {
  function_name = "${local.name_prefix}_lambda_scheduler"

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

  # Une seule exécution simultanée suffit pour ce scheduler.
  reserved_concurrent_executions = 1

  environment {
    variables = {
      TARGET_INSTANCE_IDS = join(
        ",",
        [
          aws_instance.docker.id,
          aws_instance.nodejs.id
        ]
      )
    }
  }

  tags = {
    Name = "${local.name_prefix}_lambda_scheduler"
    Role = "ec2-scheduler"
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_scheduler,
    aws_cloudwatch_log_group.scheduler
  ]
}
