moved {
  from = data.archive_file.scheduler_lambda
  to   = module.scheduler.data.archive_file.scheduler_lambda
}

moved {
  from = data.aws_iam_policy_document.lambda_assume_role
  to   = module.scheduler.data.aws_iam_policy_document.lambda_assume_role
}

moved {
  from = data.aws_iam_policy_document.lambda_scheduler
  to   = module.scheduler.data.aws_iam_policy_document.lambda_scheduler
}

moved {
  from = data.aws_iam_policy_document.scheduler_assume_role
  to   = module.scheduler.data.aws_iam_policy_document.scheduler_assume_role
}

moved {
  from = data.aws_iam_policy_document.eventbridge_invoke_lambda
  to   = module.scheduler.data.aws_iam_policy_document.eventbridge_invoke_lambda
}

moved {
  from = aws_cloudwatch_log_group.scheduler
  to   = module.scheduler.aws_cloudwatch_log_group.scheduler
}

moved {
  from = aws_iam_role.scheduler_lambda
  to   = module.scheduler.aws_iam_role.scheduler_lambda
}

moved {
  from = aws_iam_policy.lambda_scheduler
  to   = module.scheduler.aws_iam_policy.lambda_scheduler
}

moved {
  from = aws_iam_role_policy_attachment.lambda_scheduler
  to   = module.scheduler.aws_iam_role_policy_attachment.lambda_scheduler
}

moved {
  from = aws_lambda_function.scheduler
  to   = module.scheduler.aws_lambda_function.scheduler
}

moved {
  from = aws_iam_role.eventbridge_scheduler
  to   = module.scheduler.aws_iam_role.eventbridge_scheduler
}

moved {
  from = aws_iam_policy.eventbridge_invoke_lambda
  to   = module.scheduler.aws_iam_policy.eventbridge_invoke_lambda
}

moved {
  from = aws_iam_role_policy_attachment.eventbridge_invoke_lambda
  to   = module.scheduler.aws_iam_role_policy_attachment.eventbridge_invoke_lambda
}

moved {
  from = aws_scheduler_schedule.start
  to   = module.scheduler.aws_scheduler_schedule.start
}

moved {
  from = aws_scheduler_schedule.stop
  to   = module.scheduler.aws_scheduler_schedule.stop
}
