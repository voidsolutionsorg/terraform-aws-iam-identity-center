locals {
  permission_sets = local.config.permission_sets == null ? [] : local.config.permission_sets

  managed_policies_attachments = flatten([
    for ps in local.permission_sets :
    [for managed_policy_arn in ps.managed_policies : {
      key                 = join("_", [ps.name, managed_policy_arn])
      permission_set_name = ps.name,
      managed_policy_arn  = managed_policy_arn
      }
    ] if length(ps.managed_policies) > 0
  ])

  customer_managed_policies_attachments = flatten([
    for ps in local.permission_sets :
    [for cmp in ps.customer_managed_policies : {
      key                 = join("_", [ps.name, cmp.name]),
      permission_set_name = ps.name,
      name                = cmp.name,
      path                = try(cmp.path, "/") != null ? try(cmp.path, "/") : "/"
    }]
  ])

  inline_policies_attachments = flatten([
    for ps in local.permission_sets :
    {
      key                 = ps.name,
      permission_set_name = ps.name,
      inline_policy       = ps.inline_policy != null ? ps.inline_policy : file(ps.inline_policy_json_path)
    } if ps.inline_policy != null || ps.inline_policy_json_path != null
  ])

  customer_boundary_policies_attachments = flatten([
    for ps in local.permission_sets :
    {
      key                           = ps.name,
      permission_set_name           = ps.name,
      customer_boundary_policy_name = try(ps.boundary_policy.customer_policy_name, "")
      customer_boundary_policy_path = try(ps.boundary_policy.customer_policy_path, "/") != null ? try(ps.boundary_policy.customer_policy_path, "/") : "/"
    } if ps.boundary_policy != null && ps.boundary_policy != {} && try(ps.boundary_policy.type, "") == "CUSTOMER_MANAGED"
  ])

  managed_boundary_policies_attachments = flatten([
    for ps in local.permission_sets :
    {
      key                 = ps.name,
      permission_set_name = ps.name,
      managed_policy_arn  = try(ps.boundary_policy.managed_policy_arn, "")
    } if ps.boundary_policy != null && ps.boundary_policy != {} && try(ps.boundary_policy.type, "") == "MANAGED"
  ])
}

resource "aws_ssoadmin_permission_set" "permission_sets" {
  for_each = { for ps in local.permission_sets : ps.name => ps }

  instance_arn = tolist(data.aws_ssoadmin_instances.this.arns)[0]

  name             = each.value.name
  description      = try(each.value.description, null)
  relay_state      = try(each.value.relay_state, null)
  session_duration = try(each.value.session_duration, "PT1H")
}

resource "aws_ssoadmin_managed_policy_attachment" "managed_policies" {
  for_each = { for mp in local.managed_policies_attachments : mp.key => mp }

  instance_arn = tolist(data.aws_ssoadmin_instances.this.arns)[0]

  managed_policy_arn = each.value.managed_policy_arn
  permission_set_arn = aws_ssoadmin_permission_set.permission_sets[each.value.permission_set_name].arn
}

resource "aws_ssoadmin_customer_managed_policy_attachment" "customer_managed_policies" {
  for_each = { for cmp in local.customer_managed_policies_attachments : cmp.key => cmp }

  instance_arn = tolist(data.aws_ssoadmin_instances.this.arns)[0]

  permission_set_arn = aws_ssoadmin_permission_set.permission_sets[each.value.permission_set_name].arn

  customer_managed_policy_reference {
    name = each.value.name
    path = each.value.path
  }
}

resource "aws_ssoadmin_permission_set_inline_policy" "inline_policy" {
  for_each = { for ip in local.inline_policies_attachments : ip.key => ip }

  instance_arn = tolist(data.aws_ssoadmin_instances.this.arns)[0]

  inline_policy      = each.value.inline_policy
  permission_set_arn = aws_ssoadmin_permission_set.permission_sets[each.value.permission_set_name].arn
}

resource "aws_ssoadmin_permissions_boundary_attachment" "customer_managed_boundary" {
  for_each = { for cmb in local.customer_boundary_policies_attachments : cmb.key => cmb }

  instance_arn = tolist(data.aws_ssoadmin_instances.this.arns)[0]

  permission_set_arn = aws_ssoadmin_permission_set.permission_sets[each.value.permission_set_name].arn

  permissions_boundary {
    customer_managed_policy_reference {
      name = each.value.customer_boundary_policy_name
      path = each.value.customer_boundary_policy_path
    }
  }
}

resource "aws_ssoadmin_permissions_boundary_attachment" "managed_boundary" {
  for_each = { for mb in local.managed_boundary_policies_attachments : mb.key => mb }

  instance_arn = tolist(data.aws_ssoadmin_instances.this.arns)[0]

  permission_set_arn = aws_ssoadmin_permission_set.permission_sets[each.value.permission_set_name].arn
  permissions_boundary {
    managed_policy_arn = each.value.managed_policy_arn
  }
}
