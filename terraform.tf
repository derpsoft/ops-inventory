variable "app" {}
variable "client" {}
variable "organization" {}
variable "slack_webhook" {}
variable "papertrailUrl" {}
variable "salt" { type = "map" }
variable "databaseUrl" { type = "map" }
variable "auth0" { type = "map" }

provider "heroku" {}
provider "aws" {
  region = "us-east-1"
}
provider "cloudflare" {}

module "dev_bucket" {
  source = "./bucket"

  app = "${var.app}-dev-${var.salt["dev"]}"
  client = "${var.client}"
  organization = "${var.organization}"
  env = "development"
}

module "dev_site" {
  source = "./web"

  app = "${var.app}-web-dev-${var.salt["dev"]}"
  client = "${var.client}"
  env = "development"
  organization = "${var.organization}"
  slack_webhook = "${var.slack_webhook}"
}

module "dev_api" {
  source = "./api"

  app = "${var.app}-api-dev-${var.salt["dev"]}"
  client = "${var.client}"
  env = "development"
  organization = "${var.organization}"
  slack_webhook = "${var.slack_webhook}"
  papertrail_url = "${var.papertrailUrl}"
  database_url = "${var.databaseUrl["dev"]}"
  auth0 = "${var.auth0}"
  aws {
    bucket = "${module.dev_bucket.bucket}"
    access_key_id = "${module.dev_bucket.access_key_id}"
    secret_access_key = "${module.dev_bucket.secret_access_key}"
    region = "${module.dev_bucket.region}"
  }
}

module "sta_site" {
  source = "./web"

  app = "${var.app}-web-sta-${var.salt["sta"]}"
  client = "${var.client}"
  env = "staging"
  organization = "${var.organization}"
  slack_webhook = "${var.slack_webhook}"
}

resource "heroku_pipeline" "web" {
  name = "inventory-web"
}

resource "heroku_pipeline" "api" {
  name = "inventory-api"
}

resource "heroku_pipeline_coupling" "dev-site" {
  app = "${module.dev_site.appId}"
  pipeline = "${heroku_pipeline.web.id}"
  stage = "development"
}

resource "heroku_pipeline_coupling" "dev-api" {
  app = "${module.dev_api.appId}"
  pipeline = "${heroku_pipeline.api.id}"
  stage = "development"
}
