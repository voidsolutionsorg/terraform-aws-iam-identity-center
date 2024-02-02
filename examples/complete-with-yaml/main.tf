#provider "aws" {}

module "iam_identity_center" {
  source = "../.."

  # variables are configured via yaml files inside "conf" folder
}
