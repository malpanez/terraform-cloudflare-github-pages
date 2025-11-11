mock_provider "cloudflare" {
  source = "./tests/mock_providers/cloudflare"
}

run "plan_defaults" {
  command = plan

  variables {
    cloudflare_api_token = "0123456789abcdef0123456789abcdef01234567"
    domain               = "example.com"
    zone_id_override     = "fake-zone-id"
    dns_records = {
      apex = {
        type    = "A"
        content = "185.199.108.153"
        proxied = true
      }
      www = {
        name    = "www"
        type    = "CNAME"
        content = "user.github.io"
        proxied = true
      }
    }
  }

  assert {
    condition     = cloudflare_dns_record.this["apex"].proxied == true
    error_message = "Apex record should be proxied"
  }

  assert {
    condition     = cloudflare_dns_record.this["www"].type == "CNAME"
    error_message = "www record must be a CNAME"
  }

  assert {
    condition     = cloudflare_zone_setting.zone_settings["always_use_https"].value == "on"
    error_message = "always_use_https must default to on"
  }

  assert {
    condition     = cloudflare_zone_setting.zone_settings["ssl"].value == "strict"
    error_message = "TLS mode must default to strict"
  }

  assert {
    condition     = cloudflare_zone_dnssec.this.status == "active"
    error_message = "DNSSEC must remain active"
  }
}
