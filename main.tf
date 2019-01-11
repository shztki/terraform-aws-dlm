/**
 * Usage:
 *
 * module "dlm_3days" {
 *   source      = "git::https://github.com/shztki/terraform-aws-dlm.git?ref=1.0.0"
 *   role_name   = "dlm-lifecycle-role"
 *   policy_name = "dlm-lifecycle-policy"
 *   role_tags   = "${module.label.tags}"
 * 
 *   description        = "DLM lifecycle policy for 3days"
 *   execution_role_arn = ""
 *   schedule_name      = "3 generations snapshot at daily"
 * 
 *   target_tags {
 *     dlm_snapshot = "daily-3"
 *   }
 * 
 *   copy_tags = true
 * 
 *   tags_to_add {
 *     SnapshotCreator = "DLM"
 *   }
 * 
 *   interval = "24"
 *   times    = ["09:40"]
 *   count    = "3"
 * }
 * 
 * #module "dlm_7days" {
 * #  source = "git::https://github.com/shztki/terraform-aws-dlm.git?ref=1.0.0"
 * #
 * #  description        = "DLM lifecycle policy for 7days"
 * #  execution_role_arn = "${module.dlm_3days.role_arn}"
 * #  schedule_name      = "7 generations snapshot at daily"
 * #
 * #  target_tags {
 * #    dlm_snapshot = "daily-7"
 * #  }
 * #
 * #  copy_tags = true
 * #
 * #  tags_to_add {
 * #    SnapshotCreator = "DLM"
 * #  }
 * #
 * #  interval = "24"
 * #  times    = ["06:45"]
 * #  count    = "7"
 * #}
 */

data "aws_iam_policy_document" "role" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["dlm.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  count              = "${var.execution_role_arn == "" ? 1 : 0}"
  name               = "${var.role_name}"
  tags               = "${var.role_tags}"
  assume_role_policy = "${data.aws_iam_policy_document.role.json}"
}

data "aws_iam_policy_document" "policy" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "ec2:CreateSnapshot",
      "ec2:DeleteSnapshot",
      "ec2:DescribeVolumes",
      "ec2:DescribeSnapshots",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:ec2:*::snapshot/*"]
    actions   = ["ec2:CreateTags"]
  }
}

resource "aws_iam_role_policy" "this" {
  count  = "${var.execution_role_arn == "" ? 1 : 0}"
  name   = "${var.policy_name}"
  role   = "${aws_iam_role.this.id}"
  policy = "${data.aws_iam_policy_document.policy.json}"
}

resource "aws_dlm_lifecycle_policy" "this" {
  description        = "${var.description}"
  execution_role_arn = "${coalesce(var.execution_role_arn, join("", aws_iam_role.this.*.arn))}"
  state              = "${var.state}"

  policy_details {
    resource_types = ["${var.resource_types}"]

    schedule {
      name = "${var.schedule_name}"

      create_rule {
        interval      = "${var.interval}"
        interval_unit = "${var.interval_unit}"
        times         = ["${var.times}"]
      }

      retain_rule {
        count = "${var.count}"
      }

      tags_to_add = "${var.tags_to_add}"

      copy_tags = "${var.copy_tags}"
    }

    target_tags = "${var.target_tags}"
  }
}
