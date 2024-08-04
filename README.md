# AWS IAM Identity Center Terraform Module

## Usage

In this example with yaml conf...

```terraform
module "iam_identity_center" {
  source  = "voidsolutionsorg/iam-identity-center/aws"
  version = "1.0.0"

  # variables are configured via yaml files inside "conf" folder
}
```

```yaml
# conf/attachments.yaml
---
# attachments
attachments:
  - permission_set_name: "AdministratorAccess"
    principal_type: "GROUP"
    principal_group_name: "Admin"
    target_account_id: "ACCOUNT_ID" # account id
  - permission_set_name: "CustomizedS3ReadAccessJsonPath"
    principal_type: "GROUP"
    principal_group_name: "TeamA"
    target_account_id: "ACCOUNT_ID" # account id
```

```yaml
# conf/groups.yaml
---
# groups
groups:
  - name: "Admin"
    description: "Description for admin group"
    users: ["test.admin"]
  - name: "TeamA"
    description: "Description for team A"
    users: ["teamA.user1", "teamA.user2"]
```

```yaml
# conf/permission_sets.yaml
---
# permission_sets
permission_sets:
  # managed policy and customer_managed_policy
  - name: "AdministratorAccess"
    description: "Description for administrator access"
    managed_policies: ["arn:aws:iam::aws:policy/AdministratorAccess"]
    customer_managed_policies:
      - name: "customized_billing_policy" # imagine we have a policy in IAM
        path: "/"
    session_duration: "PT4H"
  # example for inline with json path
  - name: "CustomizedS3ReadAccessJsonPath"
    description: "S3 read only"
    inline_policy_json_path: "./policies/S3ReadCustomizedBucket.json"
    session_duration: "PT4H"
    boundary_policy:
      type: "CUSTOMER_MANAGED"
      customer_policy_name: "s3_boundary_customer_managed_policy" # imagine we have a policy in IAM
      customer_policy_path: "/"
```

```yaml
# conf/users.yaml
---
# users
users:
  - display_name: "Display Name"
    user_name: "test.admin"
    name:
      family_name: "Display"
      given_name: "Name"
    emails:
      - primary: true
        type: "AnyType"
        value: "example1@example.com"
  - display_name: "Display Name"
    user_name: "teamA.user1"
    name:
      family_name: "Display"
      given_name: "Name"
    emails:
      - primary: true
        type: "AnyType"
        value: "example2@example.com"
  - display_name: "Display Name"
    user_name: "teamA.user2"
    name:
      family_name: "Display"
      given_name: "Name"
    emails:
      - primary: true
        type: "AnyType"
        value: "example3@example.com"
```

In this example with standard tf variables...

```terraform
module "iam_identity_center" {
  source                        = "voidsolutionsorg/iam-identity-center/aws"
  version                       = "1.0.0"

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
```

## Examples

- [Complete IAM Identity Center using yaml config files](examples/complete-with-yaml)
- [Complete IAM Identity Center using Terraform variables](examples/complete-with-tf-vars)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_identitystore_group.groups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/identitystore_group) | resource |
| [aws_identitystore_group_membership.membership](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/identitystore_group_membership) | resource |
| [aws_identitystore_user.users](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/identitystore_user) | resource |
| [aws_ssoadmin_account_assignment.attachments](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_account_assignment) | resource |
| [aws_ssoadmin_customer_managed_policy_attachment.customer_managed_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_customer_managed_policy_attachment) | resource |
| [aws_ssoadmin_managed_policy_attachment.managed_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_managed_policy_attachment) | resource |
| [aws_ssoadmin_permission_set.permission_sets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permission_set) | resource |
| [aws_ssoadmin_permission_set_inline_policy.inline_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permission_set_inline_policy) | resource |
| [aws_ssoadmin_permissions_boundary_attachment.customer_managed_boundary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permissions_boundary_attachment) | resource |
| [aws_ssoadmin_permissions_boundary_attachment.managed_boundary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permissions_boundary_attachment) | resource |
| [aws_ssoadmin_instances.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_instances) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attachments"></a> [attachments](#input\_attachments) | The list of attachments | <pre>list(object({<br>    permission_set_arn      = optional(string),<br>    permission_set_name     = optional(string),<br>    principal_type          = string,<br>    principal_id            = optional(string),<br>    principal_group_name    = optional(string),<br>    principal_user_username = optional(string),<br>    target_account_id       = string,<br>  }))</pre> | `[]` | no |
| <a name="input_groups"></a> [groups](#input\_groups) | The list of groups | <pre>list(object({<br>    name        = string,<br>    description = optional(string, null)<br>    users       = optional(list(string), [])<br>  }))</pre> | `[]` | no |
| <a name="input_permission_sets"></a> [permission\_sets](#input\_permission\_sets) | The list of permission sets | <pre>list(object({<br>    name                      = string,<br>    description               = optional(string, null)<br>    relay_state               = optional(string, null)<br>    session_duration          = optional(string, "PT1H")<br>    managed_policies          = optional(list(string), [])<br>    customer_managed_policies = optional(any, [])<br>    inline_policy             = optional(string, null)<br>    inline_policy_json_path   = optional(string, null)<br>    boundary_policy = optional(object({<br>      type                 = string<br>      managed_policy_arn   = optional(string)<br>      customer_policy_name = optional(string)<br>      customer_policy_path = optional(string)<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_users"></a> [users](#input\_users) | The list of users | <pre>list(object({<br>    display_name       = string<br>    user_name          = string<br>    locale             = optional(string)<br>    nickname           = optional(string)<br>    preferred_language = optional(string)<br>    profile_url        = optional(string)<br>    timezone           = optional(string)<br>    title              = optional(string)<br>    user_type          = optional(string)<br>    name = object({<br>      family_name = string<br>      given_name  = string<br>    })<br>    emails = optional(list(object({<br>      primary = optional(bool)<br>      type    = optional(string)<br>      value   = optional(string)<br>    })))<br>    phone_numbers = optional(list(object({<br>      primary = optional(bool)<br>      type    = optional(string)<br>      value   = optional(string)<br>    })))<br>    addresses = optional(list(object({<br>      country        = optional(string)<br>      formatted      = optional(string)<br>      locality       = optional(string)<br>      postal_code    = optional(string)<br>      primary        = optional(string)<br>      region         = optional(string)<br>      street_address = optional(string)<br>      type           = optional(string)<br>    })))<br><br>  }))</pre> | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Authors

Module is maintained by [Aleksa Siriški](https://github.com/aleksasiriski) with help from the [VoidSolutions team](https://github.com/voidsolutionsorg).

Module was originally made by [Nikola Kolović](https://github.com/nikolakolovic) with help from the [CyberLab team](https://github.com/cyberlabrs).

## License

Apache 2 Licensed. See [LICENSE](LICENSE) for full details.
