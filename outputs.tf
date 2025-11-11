output "zone_id" {
  description = "Cloudflare Zone ID"
  value       = local.zone_id
}

output "zone_name" {
  description = "Zone name"
  value       = data.cloudflare_zone.main.name
}

output "nameservers" {
  description = "Cloudflare nameservers for this zone"
  value       = data.cloudflare_zone.main.name_servers
}

output "dns_records_created" {
  description = "List of DNS records created"
  value       = { for k, v in cloudflare_dns_record.this : k => "${v.name} (${v.type})" }
}

output "dnssec_status" {
  description = "DNSSEC status"
  value       = cloudflare_zone_dnssec.this.status
}

output "dnssec_ds_records" {
  description = "DS records for DNSSEC (add to domain registrar)"
  value       = cloudflare_zone_dnssec.this.ds
}

output "site_url" {
  description = "Your site URL"
  value       = "https://${var.domain}"
}
