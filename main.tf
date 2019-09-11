/**
 * Usage:
 *
 * module "dlm_14days" {
 *   source      = "git::https://github.com/shztki/terraform-aws-dlm.git?ref=2.0.0"
 *   dlm_role_name   = "dlm-lifecycle-role"
 *   dlm_policy_name = "dlm-lifecycle-policy"
 *   dlm_role_tags   = "${module.label.tags}"
 *   dlm_description        = "Every 0300 14gen"
 *   dlm_execution_role_arn = ""
 *   dlm_schedule_name      = "14 generations snapshot at daily"
 * 
 *   dlm_target_tags {
 *     dlm_snapshot = "daily-0300-14"
 *   }
 * 
 *   dlm_copy_tags = true
 * 
 *   dlm_tags_to_add {
 *     SnapshotCreator = "DLM"
 *   }
 * 
 *   dlm_interval = "24"
 *   dlm_times    = ["18:00"] # 03:00 JST
 *   dlm_count    = "14"
 * }
 * 
 * #module "dlm_7days" {
 * #  source = "git::https://github.com/shztki/terraform-aws-dlm.git?ref=2.0.0"
 * #
 * #  dlm_description        = "Every 0300 7gen"
 * #  dlm_execution_role_arn = "${module.dlm_14days.role_arn}"
 * #  dlm_schedule_name      = "7 generations snapshot at daily"
 * #
 * #  dlm_target_tags {
 * #    dlm_snapshot = "daily-0300-7"
 * #  }
 * #
 * #  dlm_copy_tags = true
 * #
 * #  dlm_tags_to_add {
 * #    SnapshotCreator = "DLM"
 * #  }
 * #
 * #  dlm_interval = "24"
 * #  dlm_times    = ["18:00"] # 03:00 JST
 * #  dlm_count    = "7"
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
  count              = "${var.dlm_execution_role_arn == "" ? 1 : 0}"
  name               = "${var.dlm_role_name}"
  tags               = "${var.dlm_role_tags}"
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
  count  = "${var.dlm_execution_role_arn == "" ? 1 : 0}"
  name   = "${var.dlm_policy_name}"
  role   = "${aws_iam_role.this[0].id}"
  policy = "${data.aws_iam_policy_document.policy.json}"
}

resource "aws_dlm_lifecycle_policy" "this" {
  description        = "${var.dlm_description}"
  execution_role_arn = "${coalesce(var.dlm_execution_role_arn, join("", aws_iam_role.this.*.arn))}"
  state              = "${var.dlm_state}"

  policy_details {
    resource_types = ["${var.dlm_resource_types}"]

    schedule {
      name = "${var.dlm_schedule_name}"

      create_rule {
        interval      = "${var.dlm_interval}"
        interval_unit = "${var.dlm_interval_unit}"
        times         = "${var.dlm_times}"
      }

      retain_rule {
        count = "${var.dlm_count}"
      }

      tags_to_add = "${var.dlm_tags_to_add}"

      copy_tags = "${var.dlm_copy_tags}"
    }

    target_tags = "${var.dlm_target_tags}"
  }
}
