locals {
  attachments = local.config.attachments == null ? [] : local.config.attachments

  customized_attachments = flatten([
    for attachment in local.attachments :
    {
      key = join("_", [attachment.principal_type, coalesce(attachment.permission_set_arn, attachment.permission_set_name), coalesce(attachment.principal_id, attachment.principal_group_name), attachment.target_account_id])

      principal_type = attachment.principal_type

      permission_set_arn = try(attachment.permission_set_arn, null) != null ? attachment.permission_set_arn : aws_ssoadmin_permission_set.permission_sets[attachment.permission_set_name].arn
      principal_id       = try(attachment.principal_id, null) != null ? attachment.principal_id : (try(attachment.principal_group_name, null) != null ? aws_identitystore_group.groups[attachment.principal_group_name].group_id : null)

      target_type = "AWS_ACCOUNT"
      target_id   = attachment.target_account_id
    }
  ])
}

resource "aws_ssoadmin_account_assignment" "attachments" {
  for_each = { for attachment in local.customized_attachments : attachment.key => attachment }

  permission_set_arn = each.value.permission_set_arn

  principal_id   = each.value.principal_id
  principal_type = each.value.principal_type

  target_id   = each.value.target_id
  target_type = each.value.target_type

  instance_arn = tolist(data.aws_ssoadmin_instances.this.arns)[0]
}
