variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  type        = string
  sensitive   = true
}

variable "domain" {
  description = "Apex domain managed in Cloudflare"
  type        = string
}

variable "dns_records" {
  description = "DNS records to manage"
  type = map(object({
    name    = string
    type    = string
    content = string
    proxied = optional(bool, false)
    ttl     = optional(number, 1)
    comment = optional(string)
  }))
}

variable "zone_settings" {
  description = "Zone settings"
  type = object({
    always_use_https         = optional(string)
    automatic_https_rewrites = optional(string)
    min_tls_version          = optional(string)
    tls_1_3                  = optional(string)
    browser_check            = optional(string)
    brotli                   = optional(string)
    http3                    = optional(string)
    zero_rtt                 = optional(string)
    early_hints              = optional(string)
    rocket_loader            = optional(string)
    ssl                      = optional(string)
    security_header = optional(object({
      enabled            = bool
      max_age            = number
      include_subdomains = optional(bool)
      preload            = optional(bool)
      nosniff            = optional(bool)
    }))
  })
}
