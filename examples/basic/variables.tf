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
  description = "DNS records for GitHub Pages"
  type = map(object({
    name    = string
    type    = string
    content = string
    proxied = optional(bool, false)
    ttl     = optional(number, 1)
    comment = optional(string)
  }))
}
