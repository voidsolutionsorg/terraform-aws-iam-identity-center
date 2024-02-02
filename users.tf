locals {
  users = local.config.users == null ? [] : local.config.users

  customized_users = flatten([
    for user in local.users : {
      user_name    = user.user_name,
      display_name = user.display_name,

      locale             = try(user.locale, null),
      nickname           = try(user.nickname, null),
      preferred_language = try(user.preferred_language, null),
      profile_url        = try(user.profile_url, null),
      timezone           = try(user.timezone, null),
      title              = try(user.title, null),
      user_type          = try(user.user_type, null),

      name          = try(user.name, {}) != null ? user.name : {},
      emails        = try(user.emails, []) != null ? user.emails : [],
      phone_numbers = try(user.phone_numbers, []) != null ? user.phone_numbers : [],
      addresses     = try(user.addresses, []) != null ? user.addresses : []
  }])
}

resource "aws_identitystore_user" "users" {
  for_each = { for user in local.customized_users : user.user_name => user }

  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]

  display_name       = each.value.display_name
  user_name          = each.value.user_name
  locale             = each.value.locale
  nickname           = each.value.nickname
  preferred_language = each.value.preferred_language
  profile_url        = each.value.profile_url
  timezone           = each.value.timezone
  title              = each.value.title
  user_type          = each.value.user_type

  name {
    family_name = each.value.name.family_name
    given_name  = each.value.name.given_name
  }

  dynamic "emails" {
    for_each = each.value.emails
    iterator = email

    content {
      primary = email.value.primary
      type    = email.value.type
      value   = email.value.value
    }
  }

  dynamic "addresses" {
    for_each = each.value.addresses
    iterator = address

    content {
      country        = address.value.country
      formatted      = address.value.formatted
      locality       = address.value.locality
      postal_code    = address.value.postal_code
      primary        = address.value.primary
      region         = address.value.region
      street_address = address.value.street_address
      type           = address.value.type
    }
  }

  dynamic "phone_numbers" {
    for_each = each.value.phone_numbers
    iterator = phone_number

    content {
      primary = phone_number.value.primary
      type    = phone_number.value.type
      value   = phone_number.value.value
    }
  }
}
