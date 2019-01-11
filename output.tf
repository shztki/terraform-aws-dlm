output "role_arn" {
  description = "Please use this ARN after the second one."
  value       = "${substr(coalesce(var.execution_role_arn, join("", aws_iam_role.this.*.arn)), 0, -1)}"
}
