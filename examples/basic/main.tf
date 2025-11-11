terraform {
  required_version = ">= 1.3.0"
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

module "cloudflare_github_pages" {
  source = "../.."

  cloudflare_api_token = var.cloudflare_api_token
  domain               = var.domain
  dns_records          = var.dns_records
  zone_settings        = null
}
