variable "app" {}
variable "client" {}
variable "organization" {}
variable "slack_webhook" {}
variable "salt" { type = "map" }

provider "heroku" {}
provider "aws" {}
provider "cloudflare" {}

// # STATE
// data "terraform_remote_state" "state" {
//   backend = "s3"
//   config {
//     bucket = "bauscode-terraform"
//     key = "tti/chemowave.tfstate"
//     region = "us-east-1"
//   }
// }

module "dev_site" {
  source = "./web"

  app = "${var.app}"
  client = "${var.client}"
  env = "dev"
  organization = "${var.organization}"
  salt = "${var.salt["dev"]}"
  slack_webhook = "${var.slack_webhook}"
}

module "sta_site" {
  source = "./web"

  app = "${var.app}"
  client = "${var.client}"
  env = "sta"
  organization = "${var.organization}"
  salt = "${var.salt["sta"]}"
  slack_webhook = "${var.slack_webhook}"
}
