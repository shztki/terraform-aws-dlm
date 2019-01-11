# terraform-aws-dlm
A module that creates a Data Lifecycle Manager (DLM) lifecycle policy for managing snapshots.

* モジュールでは depends_on を使用できないので、複数作成する場合は 1個目を作成してから、1個目の role_arn を使用する形で追加してください。無駄に同じ内容の role を複数作成する必要はないです。

## Usage:
```
module "dlm_3days" {
  source      = "git::https://github.com/shztki/terraform-aws-dlm.git?ref=1.0.0"
  role_name   = "dlm-lifecycle-role"
  policy_name = "dlm-lifecycle-policy"
  role_tags   = "${module.label.tags}"

  description        = "DLM lifecycle policy for 3days"
  execution_role_arn = ""
  schedule_name      = "3 generations snapshot at daily"

  target_tags {
    dlm_snapshot = "daily-3"
  }

  copy_tags = true

  tags_to_add {
    SnapshotCreator = "DLM"
  }

  interval = "24"
  times    = ["09:40"]
  count    = "3"
}

#module "dlm_7days" {
#  source = "git::https://github.com/shztki/terraform-aws-dlm.git?ref=1.0.0"
#
#  description        = "DLM lifecycle policy for 7days"
#  execution_role_arn = "${module.dlm_3days.role_arn}"
#  schedule_name      = "7 generations snapshot at daily"
#
#  target_tags {
#    dlm_snapshot = "daily-7"
#  }
#
#  copy_tags = true
#
#  tags_to_add {
#    SnapshotCreator = "DLM"
#  }
#
#  interval = "24"
#  times    = ["06:45"]
#  count    = "7"
#}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| copy\_tags | Copy all user-defined tags on a source volume to snapshots of the volume created by this policy. | string | `""` | no |
| count | How many snapshots to keep. Must be an integer between 1 and 1000. | string | n/a | yes |
| description | A description for the DLM lifecycle policy. | string | n/a | yes |
| execution\_role\_arn | The ARN of an IAM role that is able to be assumed by the DLM service. | string | `""` | no |
| interval | How often this lifecycle policy should be evaluated. 12 or 24 are valid values. | string | n/a | yes |
| interval\_unit | The unit for how often the lifecycle policy should be evaluated. HOURS is currently the only allowed value and also the default value. | string | `"HOURS"` | no |
| policy\_name | The name of the role policy. If omitted, Terraform will assign a random, unique name. | string | `"dlm-lifecycle-policy"` | no |
| resource\_types | A list of resource types that should be targeted by the lifecycle policy. | string | `"VOLUME"` | no |
| role\_name | The name of the role. If omitted, Terraform will assign a random, unique name. | string | `""` | no |
| role\_tags | Key-value mapping of tags for the IAM role | map | `<map>` | no |
| schedule\_name | A name for the schedule. | string | n/a | yes |
| state | Whether the lifecycle policy should be enabled or disabled. ENABLED or DISABLED are valid values. | string | `"ENABLED"` | no |
| tags\_to\_add | A mapping of tag keys and their values. DLM lifecycle policies will already tag the snapshot with the tags on the volume. This configuration adds extra tags on top of these. | map | `<map>` | no |
| target\_tags | A mapping of tag keys and their values. Any resources that match the resource_types and are tagged with any of these tags will be targeted. | map | n/a | yes |
| times | A list of times in 24 hour clock format that sets when the lifecycle policy should be evaluated. Max of 1. | list | `<list>` | no |

## Outputs

| Name | Description |
|------|-------------|
| role\_arn | Please use this ARN after the second one. |

