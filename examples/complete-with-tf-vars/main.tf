#provider "aws" {}

module "iam_identity_center" {
  source = "../.."

  permission_sets = [
    { # managed policy and customer_managed_policy
      name             = "AdministratorAccess",
      description      = "Description for administrator access",
      managed_policies = ["arn:aws:iam::aws:policy/AdministratorAccess"],
      customer_managed_policies = [
        {
          name = "customized_billing_policy" # imagine we have a policy in IAM
          path = "/"
        }
      ]
      session_duration = "PT4H"
    },
    { # example for inline with json path
      name                    = "CustomizedS3ReadAccessJsonPath",
      description             = "S3 read only",
      inline_policy_json_path = "./policies/S3ReadCustomizedBucket.json"
      session_duration        = "PT4H"
      boundary_policy = {
        type                 = "CUSTOMER_MANAGED"
        customer_policy_name = "s3_boundary_customer_managed_policy" # imagine we have a policy in IAM
        customer_policy_path = "/"
      }
    },
    { # example for inline with json path
      name             = "CustomizedS3ReadAccessInline",
      description      = "S3 read only",
      inline_policy    = <<EOF
      {
        "Version":"2012-10-17",
        "Statement":[
          {
              "Effect":"Allow",
              "Action":[
                "s3:GetObject",
                "s3:GetObjectVersion"
              ],
              "Resource":"arn:aws:s3:::example/*"
          }
        ]
      }
      EOF
      session_duration = "PT4H"
      boundary_policy = {
        type               = "MANAGED"
        managed_policy_arn = "arn:aws:iam::aws:policy/S3ReadOnly"
      }
    }
  ]

  users = [
    {
      display_name = "Display Name"
      user_name    = "test.admin"
      name = {
        family_name = "Display"
        given_name  = "Name"
      }
      emails = [
        {
          primary = true
          type    = "AnyType"
          value   = "example1@example.com"
        }
      ]
    },
    {
      display_name = "Display Name"
      user_name    = "teamA.user1"
      name = {
        family_name = "Display"
        given_name  = "Name"
      }
      emails = [
        {
          primary = true
          type    = "AnyType"
          value   = "example2@example.com"
        }
      ]
    },
    {
      display_name = "Display Name"
      user_name    = "teamA.user2"
      name = {
        family_name = "Display"
        given_name  = "Name"
      }
      emails = [
        {
          primary = true
          type    = "AnyType"
          value   = "example3@example.com"
        }
      ]
    },
    {
      display_name = "Display Name"
      user_name    = "teamB.user1"
      name = {
        family_name = "Display"
        given_name  = "Name"
      }
      emails = [
        {
          primary = true
          type    = "AnyType"
          value   = "example4@example.com"
        }
      ]
    }
  ]

  groups = [
    {
      name        = "Admin",
      description = "Description for admin group",
      users       = ["test.admin"]
    },
    {
      name        = "TeamA",
      description = "Description for team A",
      users       = ["teamA.user1", "teamA.user2"]
    },
    {
      name        = "TeamB",
      description = "Description for team B",
      users       = ["teamB.user1", "teamB.user2"]
    }
  ]

  attachments = [
    {
      permission_set_name  = "AdministratorAccess",
      principal_type       = "GROUP",
      principal_group_name = "Admin",
      target_account_id    = "ACCOUNT_ID" # account id
    },
    {
      permission_set_name  = "CustomizedS3ReadAccessJsonPath",
      principal_type       = "GROUP",
      principal_group_name = "TeamA",
      target_account_id    = "ACCOUNT_ID" # account id
    },
    {
      permission_set_name  = "CustomizedS3ReadAccessInline",
      principal_type       = "GROUP",
      principal_group_name = "TeamB",
      target_account_id    = "ACCOUNT_ID" # account id
    }
  ]
}