variable "app" {}
variable "client" {}
variable "organization" {}
variable "slack_webhook" {}
variable "env" {}
variable "papertrail_url" {}
variable "region" { default = "us" }

# APP
resource "heroku_app" "web" {
  name = "${var.app}"
  region = "${var.region}"

  organization {
    name = "${var.organization}"
    personal = false
  }

  config_vars = {
    APP_DEBUG = true
    APP_BASE_URL = "https://${var.app}.herokuapp.com/"
    APP_ENVIRONMENT = "${var.env}"
    APP_ENCRYPTION_KEY = "d22KN7l91rx05tGjZEyULM2siHdbJ0WA"
    APP_JWT_SECRET = "c21KN7l91rx05uGjZEyULM2siHdbJ0YR"
    MAIL_HOST = "smtp.sendgrid.net"
    S3_BUCKET_REGION = "us-east-1"
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
resource "heroku_addon" "mysql" {
  app = "${heroku_app.web.name}"
  plan = "jawsdb:kitefin"
}

# REDIS
resource "heroku_addon" "redis" {
  app = "${heroku_app.web.name}"
  plan = "heroku-redis:hobby-dev"
}

# SENDGRID
resource "heroku_addon" "sendgrid" {
  app = "${heroku_app.web.name}"
  plan = "sendgrid:starter"
}

// # NEWRELIC
// resource "heroku_addon" "newrelic" {
//   app = "${heroku_app.web.name}"
//   plan = "newrelic:wayne"
// }

# PAPERTRAIL DRAIN
resource "heroku_drain" "papertrail" {
  app = "${heroku_app.web.name}"
  url = "${var.papertrail_url}"
}

// # DOMAIN
// resource "heroku_domain" "domain" {
//   app = "${heroku_app.pro_cms.name}"
//   hostname = "admin.youatcollege.com"
// }
