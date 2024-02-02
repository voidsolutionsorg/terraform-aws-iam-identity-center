locals {
  groups = local.config.groups == null ? [] : local.config.groups

  user_group_membership = flatten([
    for group in local.groups :
    [for user in group.users : {
      key        = join("_", [group.name, user])
      group_name = group.name,
      user_name  = user
      }
    ]
  ])
}

resource "aws_identitystore_group" "groups" {
  for_each = { for group in local.groups : group.name => group }

  display_name = each.value.name
  description  = try(each.value.description, null)

  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
}

resource "aws_identitystore_group_membership" "membership" {
  for_each = { for membership in local.user_group_membership : membership.key => membership }

  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]

  group_id  = aws_identitystore_group.groups[each.value.group_name].group_id
  member_id = aws_identitystore_user.users[each.value.user_name].user_id
}
