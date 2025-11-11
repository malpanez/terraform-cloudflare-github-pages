mock_data "cloudflare_zone" {
  defaults = {
    id                    = "fake-zone-id"
    zone_id               = "fake-zone-id"
    name                  = "example.com"
    status                = "active"
    paused                = false
    type                  = "full"
    development_mode      = 0
    vanity_name_servers   = []
    original_name_servers = ["ns1.example.com", "ns2.example.com"]
    name_servers          = ["ns1.example.com", "ns2.example.com"]
  }
}

mock_resource "cloudflare_dns_record" {
  defaults = {
    id       = "record-id"
    hostname = "example.com"
    type     = "A"
    content  = "185.199.108.153"
    proxied  = true
  }
}

mock_resource "cloudflare_zone_setting" {
  defaults = {
    id         = "zone-settings-id"
    setting_id = "always_use_https"
    value      = "on"
  }
}

mock_resource "cloudflare_zone_dnssec" {
  override_during = plan
  defaults = {
    id     = "dnssec-id"
    status = "active"
    ds     = "ds-record"
  }
}
