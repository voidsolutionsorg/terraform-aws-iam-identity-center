locals {
  # config folder
  config_folder = "conf"

  # config paths
  permission_sets_prepath = "${local.config_folder}/permission_sets"
  permission_sets_path    = fileexists("${local.permission_sets_prepath}.yaml") ? "${local.permission_sets_prepath}.yaml" : fileexists("${local.permission_sets_prepath}.yml") ? "${local.permission_sets_prepath}.yml" : ""

  groups_prepath = "${local.config_folder}/groups"
  groups_path    = fileexists("${local.groups_prepath}.yaml") ? "${local.groups_prepath}.yaml" : fileexists("${local.groups_prepath}.yml") ? "${local.groups_prepath}.yml" : ""

  attachments_prepath = "${local.config_folder}/attachments"
  attachments_path    = fileexists("${local.attachments_prepath}.yaml") ? "${local.attachments_prepath}.yaml" : fileexists("${local.attachments_prepath}.yml") ? "${local.attachments_prepath}.yml" : ""

  users_prepath = "${local.config_folder}/users"
  users_path    = fileexists("${local.users_prepath}.yaml") ? "${local.users_prepath}.yaml" : fileexists("${local.users_prepath}.yml") ? "${local.users_prepath}.yml" : ""

  # import config settings
  config = {
    permission_sets = tolist([for ps in try(
      yamldecode(file(local.permission_sets_path))["permission_sets"],
      var.permission_sets
      ) : {
      name                      = ps.name
      description               = try(ps.description, null)
      relay_state               = try(ps.relay_state, null)
      session_duration          = try(ps.session_duration, "PT1H")
      managed_policies          = tolist(try(ps.managed_policies, []))
      customer_managed_policies = try(ps.customer_managed_policies, [])
      inline_policy             = try(ps.inline_policy, null)
      inline_policy_json_path   = try(ps.inline_policy_json_path, null)
      boundary_policy = try(object({
        type                 = ps.boundary_policy.type
        managed_policy_arn   = try(ps.boundary_policy.managed_policy_arn, null)
        customer_policy_name = try(ps.boundary_policy.customer_policy_name, null)
        customer_policy_path = try(ps.boundary_policy.customer_policy_path, null)
      }), null)
    }])

    groups = tolist([for g in try(
      yamldecode(file(local.groups_path))["groups"],
      var.groups
      ) : {
      name        = g.name
      description = try(g.description, null)
      users       = tolist(try(g.users, []))
    }])

    attachments = tolist([for a in try(
      yamldecode(file(local.attachments_path))["attachments"],
      var.attachments
      ) : {
      permission_set_arn      = try(a.permission_set_arn, null)
      permission_set_name     = try(a.permission_set_name, null)
      principal_type          = a.principal_type
      principal_id            = try(a.principal_id, null)
      principal_group_name    = try(a.principal_group_name, null)
      principal_user_username = try(a.principal_user_username, null)
      target_account_id       = a.target_account_id
    }])

    users = tolist([for u in try(
      yamldecode(file(local.users_path))["users"],
      var.users
      ) : {
      display_name       = u.display_name
      user_name          = u.user_name
      locale             = try(u.locale, null)
      nickname           = try(u.nickname, null)
      preferred_language = try(u.preferred_language, null)
      profile_url        = try(u.profile_url, null)
      timezone           = try(u.timezone, null)
      title              = try(u.title, null)
      user_type          = try(u.user_type, null)
      name = object({
        family_name = u.name.family_name
        given_name  = u.name.given_name
      })

      emails = tolist(try([for e in u.emails : object({
        primary = try(e.primary, null)
        type    = try(e.type, null)
        value   = try(e.value, null)
      })]))

      phone_numbers = tolist(try([for pn in u.phone_numbers : object({
        primary = try(pn.primary, null)
        type    = try(pn.type, null)
        value   = try(pn.value, null)
      })]))

      addresses = tolist(try([for a in u.addresses : object({
        country        = try(a.country, null)
        formatted      = try(a.formatted, null)
        locality       = try(a.locality, null)
        postal_code    = try(a.postal_code, null)
        primary        = try(a.primary, null)
        region         = try(a.region, null)
        street_address = try(a.street_address, null)
        type           = try(a.type, null)
      })]))
    }])
  }
}
