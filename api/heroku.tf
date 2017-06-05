variable "app" {}
variable "client" {}
variable "organization" {}
variable "slack_webhook" {}
variable "env" {}
variable "papertrail_url" {}
variable "database_url" {}
variable "region" { default = "us" }
variable "auth0" { type = "map" }
variable "aws" { type = "map" }

output "appId" {
  value = "${heroku_app.api.id}"
}

# APP
resource "heroku_app" "api" {
  name = "${var.app}"
  region = "${var.region}"

  organization {
    name = "${var.organization}"
    personal = false
  }

  buildpacks = [
    "heroku/nodejs"
  ]

  config_vars = {
    MAIL_HOST = "smtp.sendgrid.net"
    NODE_ENV = "${var.env}"
    DATABASE_URL = "${var.database_url}"
    AUTH0_DOMAIN = "${var.auth0["domain"]}"
    AUTH0_CLIENT_ID = "${var.auth0["clientId"]}"
    AUTH0_CLIENT_SECRET = "${var.auth0["clientSecret"]}"
    AWS_BUCKET = "${var.aws["bucket"]}"
    AWS_ACCESS_KEY_ID = "${var.aws["access_key_id"]}"
    AWS_SECRET_ACCESS_KEY = "${var.aws["secret_access_key"]}"
  }
}

# SLACK HOOK
resource "heroku_addon" "webhook" {
  app = "${heroku_app.api.name}"
  plan = "deployhooks:http"
  config {
    url = "${var.slack_webhook}"
  }
}

// # DATABASE
// resource "heroku_addon" "mysql" {
//   app = "${heroku_app.api.name}"
//   plan = "jawsdb:kitefin"
// }

// # REDIS
resource "heroku_addon" "redis" {
  app = "${heroku_app.api.name}"
  plan = "heroku-redis:hobby-dev"
}

// # SENDGRID
// resource "heroku_addon" "sendgrid" {
//   app = "${heroku_app.api.name}"
//   plan = "sendgrid:starter"
// }

// # NEWRELIC
// resource "heroku_addon" "newrelic" {
//   app = "${heroku_app.api.name}"
//   plan = "newrelic:wayne"
// }

// # PAPERTRAIL DRAIN
resource "heroku_drain" "papertrail" {
  app = "${heroku_app.api.name}"
  url = "${var.papertrail_url}"
}

// # DOMAIN
// resource "heroku_domain" "domain" {
//   app = "${heroku_app.pro_cms.name}"
//   hostname = "admin.youatcollege.com"
// }
