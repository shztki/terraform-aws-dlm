variable "dlm_role_name" {
  type        = "string"
  description = "The name of the role. If omitted, Terraform will assign a random, unique name."
  default     = ""
}

variable "dlm_policy_name" {
  type        = "string"
  description = "The name of the role policy. If omitted, Terraform will assign a random, unique name."
  default     = "dlm-lifecycle-policy"
}

variable "dlm_role_tags" {
  type        = "map"
  description = "Key-value mapping of tags for the IAM role"
  default     = {}
}

variable "dlm_description" {
  type        = "string"
  description = "A description for the DLM lifecycle policy."
}

variable "dlm_execution_role_arn" {
  type        = "string"
  description = "The ARN of an IAM role that is able to be assumed by the DLM service."
  default     = ""
}

variable "dlm_state" {
  type        = "string"
  description = "Whether the lifecycle policy should be enabled or disabled. ENABLED or DISABLED are valid values."
  default     = "ENABLED"
}

# Policy Details arguments
variable "dlm_resource_types" {
  type        = "string"
  description = "A list of resource types that should be targeted by the lifecycle policy."
  default     = "VOLUME"
}

variable "dlm_schedule_name" {
  type        = "string"
  description = "A name for the schedule. "
}

variable "dlm_target_tags" {
  type        = "map"
  description = "A mapping of tag keys and their values. Any resources that match the resource_types and are tagged with any of these tags will be targeted."
}

# Schedule arguments
variable "dlm_copy_tags" {
  type        = "string"
  description = "Copy all user-defined tags on a source volume to snapshots of the volume created by this policy."
  default     = ""
}

variable "dlm_tags_to_add" {
  type        = "map"
  description = "A mapping of tag keys and their values. DLM lifecycle policies will already tag the snapshot with the tags on the volume. This configuration adds extra tags on top of these."
  default     = {}
}

# Create Rule arguments
variable "dlm_interval" {
  type        = "string"
  description = "How often this lifecycle policy should be evaluated. 12 or 24 are valid values."
}

variable "dlm_interval_unit" {
  type        = "string"
  description = "The unit for how often the lifecycle policy should be evaluated. HOURS is currently the only allowed value and also the default value."
  default     = "HOURS"
}

variable "dlm_times" {
  type        = "list"
  description = "A list of times in 24 hour clock format that sets when the lifecycle policy should be evaluated. Max of 1."
  default     = []
}

# Retain Rule arguments
variable "dlm_count" {
  type        = "string"
  description = "How many snapshots to keep. Must be an integer between 1 and 1000."
}
