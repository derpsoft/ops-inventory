variable "app" {}
variable "client" {}
variable "organization" {}
variable "slack_webhook" {}
variable "env" {}
variable "region" { default = "us" }

output "appId" {
  value = "${heroku_app.web.id}"
}

# APP
resource "heroku_app" "web" {
  name = "${var.app}"
  region = "${var.region}"

  organization {
    name = "${var.organization}"
    personal = false
  }

  config_vars = {
    NODE_ENV = "${var.env}"
    NPM_CONFIG_PRODUCTION = "false"
    NODE_MODULES_CACHE = "false"
  }
}

# SLACK HOOK
resource "heroku_addon" "webhook" {
  app = "${heroku_app.web.name}"
  plan = "deployhooks:http"
  config {
    url = "${var.slack_webhook}"
  }
}

# DATABASE
// resource "heroku_addon" "mysql" {
//   app = "${heroku_app.web.name}"
//   plan = "jawsdb:kitefin"
// }

# REDIS
// resource "heroku_addon" "redis" {
//   app = "${heroku_app.web.name}"
//   plan = "heroku-redis:hobby-dev"
// }

# SENDGRID
// resource "heroku_addon" "sendgrid" {
//   app = "${heroku_app.web.name}"
//   plan = "sendgrid:starter"
// }

// # NEWRELIC
// resource "heroku_addon" "newrelic" {
//   app = "${heroku_app.web.name}"
//   plan = "newrelic:wayne"
// }

# PAPERTRAIL DRAIN
// resource "heroku_drain" "papertrail" {
//   app = "${heroku_app.web.name}"
//   url = "${var.papertrail_url}"
// }

// # DOMAIN
// resource "heroku_domain" "domain" {
//   app = "${heroku_app.pro_cms.name}"
//   hostname = "admin.youatcollege.com"
// }
