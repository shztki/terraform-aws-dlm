# terraform-aws-dlm
A module that creates a Data Lifecycle Manager (DLM) lifecycle policy for managing snapshots.

* モジュールでは depends_on を使用できないので、複数作成する場合は 1個目を作成してから、1個目の role_arn を使用する形で追加してください。無駄に同じ内容の role を複数作成する必要はないです。

* terraform0.11以前は `ref=1.0.0` で、terraform0.12以降は `ref=2.0.0` で利用してください。

Usage:

```
module "dlm_14days" {
  source      = "git::https://github.com/shztki/terraform-aws-dlm.git?ref=2.0.0"
  dlm_role_name   = "dlm-lifecycle-role"
  dlm_policy_name = "dlm-lifecycle-policy"
  dlm_role_tags   = "${module.label.tags}"
  dlm_description        = "Every 0300 14gen"
  dlm_execution_role_arn = ""
  dlm_schedule_name      = "14 generations snapshot at daily"

  dlm_target_tags {
    dlm_snapshot = "daily-0300-14"
  }

  dlm_copy_tags = true

  dlm_tags_to_add {
    SnapshotCreator = "DLM"
  }

  dlm_interval = "24"
  dlm_times    = ["18:00"] # 03:00 JST
  dlm_count    = "14"
}

#module "dlm_7days" {
#  source = "git::https://github.com/shztki/terraform-aws-dlm.git?ref=2.0.0"
#
#  dlm_description        = "Every 0300 7gen"
#  dlm_execution_role_arn = "${module.dlm_14days.role_arn}"
#  dlm_schedule_name      = "7 generations snapshot at daily"
#
#  dlm_target_tags {
#    dlm_snapshot = "daily-0300-7"
#  }
#
#  dlm_copy_tags = true
#
#  dlm_tags_to_add {
#    SnapshotCreator = "DLM"
#  }
#
#  dlm_interval = "24"
#  dlm_times    = ["18:00"] # 03:00 JST
#  dlm_count    = "7"
#}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| dlm\_copy\_tags | Copy all user-defined tags on a source volume to snapshots of the volume created by this policy. | string | `""` | no |
| dlm\_count | How many snapshots to keep. Must be an integer between 1 and 1000. | string | n/a | yes |
| dlm\_description | A description for the DLM lifecycle policy. | string | n/a | yes |
| dlm\_execution\_role\_arn | The ARN of an IAM role that is able to be assumed by the DLM service. | string | `""` | no |
| dlm\_interval | How often this lifecycle policy should be evaluated. 12 or 24 are valid values. | string | n/a | yes |
| dlm\_interval\_unit | The unit for how often the lifecycle policy should be evaluated. HOURS is currently the only allowed value and also the default value. | string | `"HOURS"` | no |
| dlm\_policy\_name | The name of the role policy. If omitted, Terraform will assign a random, unique name. | string | `"dlm-lifecycle-policy"` | no |
| dlm\_resource\_types | A list of resource types that should be targeted by the lifecycle policy. | string | `"VOLUME"` | no |
| dlm\_role\_name | The name of the role. If omitted, Terraform will assign a random, unique name. | string | `""` | no |
| dlm\_role\_tags | Key-value mapping of tags for the IAM role | map | `<map>` | no |
| dlm\_schedule\_name | A name for the schedule. | string | n/a | yes |
| dlm\_state | Whether the lifecycle policy should be enabled or disabled. ENABLED or DISABLED are valid values. | string | `"ENABLED"` | no |
| dlm\_tags\_to\_add | A mapping of tag keys and their values. DLM lifecycle policies will already tag the snapshot with the tags on the volume. This configuration adds extra tags on top of these. | map | `<map>` | no |
| dlm\_target\_tags | A mapping of tag keys and their values. Any resources that match the resource_types and are tagged with any of these tags will be targeted. | map | n/a | yes |
| dlm\_times | A list of times in 24 hour clock format that sets when the lifecycle policy should be evaluated. Max of 1. | list | `<list>` | no |

## Outputs

| Name | Description |
|------|-------------|
| role\_arn | Please use this ARN after the second one. |

