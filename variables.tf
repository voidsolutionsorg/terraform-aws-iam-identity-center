################################################################################
# Permission sets
################################################################################
variable "permission_sets" {
  description = "The list of permission sets"
  type = list(object({
    name                      = string,
    description               = optional(string, null)
    relay_state               = optional(string, null)
    session_duration          = optional(string, "PT1H")
    managed_policies          = optional(list(string), [])
    customer_managed_policies = optional(any, [])
    inline_policy             = optional(string, null)
    inline_policy_json_path   = optional(string, null)
    boundary_policy = optional(object({
      type                 = string
      managed_policy_arn   = optional(string)
      customer_policy_name = optional(string)
      customer_policy_path = optional(string)
    }))
  }))
  validation {
    condition = (
      alltrue(
      [for ps in var.permission_sets : length(ps.name) >= 3])
    )
    error_message = "Permission set name must be unique, and must have more than 3 characters!"
  }
  validation {
    condition = (
      alltrue(
        [for ps in var.permission_sets : (
          (ps.inline_policy != null && ps.inline_policy_json_path == null) ||
          (ps.inline_policy_json_path != null && ps.inline_policy == null) ||
          (ps.inline_policy_json_path == null && ps.inline_policy == null)
      )])
    )
    error_message = "An inline policy can be selected either by entering an inline policy in the inline_policy field, or by defining the path to the json file where the policy is located\nIt is impossible to use both!"
  }
  validation {
    condition = (
      alltrue(
        [for ps in var.permission_sets : (
          length(ps.customer_managed_policies) == 0 ? true : alltrue(
            [for cmp in ps.customer_managed_policies : (
              length(try(cmp.name, "")) > 0 && try(cmp.name, null) != null
            )]
          )
      )])
    )
    error_message = "Customer managed policy must be list of object as 1 required field (name) and one optional field (path)"
  }
  validation {
    condition = (
      alltrue(
        [for ps in var.permission_sets : (
          (length(ps.customer_managed_policies) + length(ps.managed_policies)) <= 10
      )])
    )
    error_message = "The total number of customer managed policies and managed policies can be a maximum of 10"
  }
  validation {
    condition = (
      alltrue(
        [for ps in var.permission_sets : (
          (ps.boundary_policy == null || ps.boundary_policy == {}) ? true :
          (ps.boundary_policy.type == "MANAGED" ? try(ps.boundary_policy.managed_policy_arn, null) != null :
          ps.boundary_policy.type == "CUSTOMER_MANAGED" ? try(ps.boundary_policy.customer_policy_name, null) != null : false)
      )])
    )
    error_message = "If you set boundary policy, there are some limitations: \nThe type must be specified, allowed values: MANAGED or CUSTOMER_MANAGED depends on do you want a customer managed policy, or a managed policy from AWS\nIf you set type to MANAGED, you must define managed_policy_arn\nIf you set type to CUSTOMER_MANAGED, you must set customer_policy_name and optionaly customer_policy_path\nboundary_policy object must be in format\n{\n  type= string, \n  managed_policy_arn= optional(string),\n  customer_policy_name= optional(string),\n  customer_policy_path= optional(string)\n}"
  }
  default = []
}
################################################################################
# Groups
################################################################################
variable "groups" {
  description = "The list of groups"
  type = list(object({
    name        = string,
    description = optional(string, null)
    users       = optional(list(string), [])
  }))
  default = []
}

################################################################################
# Attachments
################################################################################
variable "attachments" {
  description = "The list of attachments"
  type = list(object({
    permission_set_arn      = optional(string),
    permission_set_name     = optional(string),
    principal_type          = string,
    principal_id            = optional(string),
    principal_group_name    = optional(string),
    principal_user_username = optional(string),
    target_account_id       = string,
  }))
  validation {
    condition = (
      alltrue(
        [for attachment in var.attachments : (
          (try(attachment.permission_set_arn, null) != null && try(attachment.permission_set_name, null) == null) ||
          (try(attachment.permission_set_arn, null) == null && try(attachment.permission_set_name, null) != null)
      )])
    )
    error_message = "The permission set must be set! You can set it in two ways, either by defining permission_set_arn or using permission_set_name. Both cannot be entered."
  }
  validation {
    condition = (
      alltrue(
        [for attachment in var.attachments : (
          attachment.principal_type == "GROUP" || attachment.principal_type == "ACCOUNT"
      )])
    )
    error_message = "The principal type must be either GROUP or ACCOUNT"
  }
  validation {
    condition = (
      alltrue(
        [for attachment in var.attachments : (
          (length(attachment.target_account_id) >= 10 && length(attachment.target_account_id) <= 12)
      )])
    )
    error_message = "Target account ID isn't entered correctly, must consist of numbers, and must be between 10 and 12 numbers"
  }
  validation {
    condition = (
      alltrue(
        [for attachment in var.attachments : (
          (try(attachment.principal_id, null) != null && try(attachment.principal_group_name, null) == null && try(attachment.principal_user_username, null) == null) ||
          (try(attachment.principal_id, null) == null && try(attachment.principal_group_name, null) != null && try(attachment.principal_user_username, null) == null) ||
          (try(attachment.principal_id, null) == null && try(attachment.principal_group_name, null) == null && try(attachment.principal_user_username, null) != null)
      )])
    )
    error_message = "The principal_id must be set! You can set it in three ways, by entering principal_id, by entering principal principal_group_name, or by entering principal_user_username. More than one way cannot be entered"
  }
  default = []
}
################################################################################
# Users
################################################################################
variable "users" {
  description = "The list of users"
  type = list(object({
    display_name       = string
    user_name          = string
    locale             = optional(string)
    nickname           = optional(string)
    preferred_language = optional(string)
    profile_url        = optional(string)
    timezone           = optional(string)
    title              = optional(string)
    user_type          = optional(string)
    name = object({
      family_name = string
      given_name  = string
    })
    emails = optional(list(object({
      primary = optional(bool)
      type    = optional(string)
      value   = optional(string)
    })))
    phone_numbers = optional(list(object({
      primary = optional(bool)
      type    = optional(string)
      value   = optional(string)
    })))
    addresses = optional(list(object({
      country        = optional(string)
      formatted      = optional(string)
      locality       = optional(string)
      postal_code    = optional(string)
      primary        = optional(string)
      region         = optional(string)
      street_address = optional(string)
      type           = optional(string)
    })))

  }))
  default = []
}
