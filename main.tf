terraform {
  required_version = ">= 1.3.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

data "cloudflare_zone" "main" {
  filter = {
    name   = var.domain
    status = "active"
  }
}

resource "cloudflare_dns_record" "this" {
  for_each = var.dns_records

  zone_id = local.zone_id
  name    = coalesce(try(each.value.name, null), var.domain)
  type    = each.value.type
  content = each.value.content
  proxied = lookup(each.value, "proxied", false)
  ttl     = lookup(each.value, "ttl", 1)
  comment = lookup(each.value, "comment", "Managed by Terraform")

  priority = try(each.value.priority, null)

}

locals {
  zone_id = coalesce(
    var.zone_id_override,
    try(data.cloudflare_zone.main.zone_id, null),
    try(data.cloudflare_zone.main.id, null),
  )

  default_zone_settings = {
    always_use_https         = "on"
    automatic_https_rewrites = "on"
    min_tls_version          = "1.2"
    tls_1_3                  = "on"
    browser_check            = "on"
    brotli                   = "on"
    http3                    = "on"
    zero_rtt                 = "on"
    early_hints              = "on"
    rocket_loader            = "off"
    ssl                      = "strict"
  }

  user_zone_settings = var.zone_settings == null ? tomap({}) : tomap({
    for setting, value in var.zone_settings :
    setting => value
    if setting != "security_header"
  })

  merged_zone_settings = merge(local.default_zone_settings, local.user_zone_settings)

  zone_setting_targets = {
    for setting, value in local.merged_zone_settings :
    setting => {
      setting_id = setting == "zero_rtt" ? "0rtt" : setting
      value      = value
    }
    if setting != "security_header" && value != null
  }

  security_header_payload = (
    var.zone_settings != null && try(var.zone_settings.security_header, null) != null ?
    {
      strict_transport_security = {
        enabled            = var.zone_settings.security_header.enabled
        max_age            = var.zone_settings.security_header.max_age
        include_subdomains = lookup(var.zone_settings.security_header, "include_subdomains", false)
        preload            = lookup(var.zone_settings.security_header, "preload", false)
        nosniff            = lookup(var.zone_settings.security_header, "nosniff", false)
      }
    } :
    null
  )
}

resource "cloudflare_zone_setting" "zone_settings" {
  for_each = local.zone_setting_targets

  zone_id    = local.zone_id
  setting_id = each.value.setting_id
  value      = each.value.value
}

resource "cloudflare_zone_setting" "security_header" {
  count = local.security_header_payload == null ? 0 : 1

  zone_id    = local.zone_id
  setting_id = "security_header"
  value      = local.security_header_payload
}

resource "cloudflare_zone_dnssec" "this" {
  zone_id = local.zone_id
  status  = "active"
}
