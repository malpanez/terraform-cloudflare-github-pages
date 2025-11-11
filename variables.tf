variable "cloudflare_api_token" {
  description = "Cloudflare API token with Zone.DNS and Zone.Zone Settings permissions"
  type        = string
  sensitive   = true
}

variable "domain" {
  description = "Domain name managed in Cloudflare (e.g., example.com)"
  type        = string

  validation {
    condition     = can(regex("^([a-zA-Z0-9-]+\\.)+[A-Za-z]{2,}$", var.domain))
    error_message = "domain must be a valid hostname such as example.com."
  }
}

variable "dns_records" {
  description = "Map of DNS records to create"
  type = map(object({
    name     = optional(string)
    type     = string
    content  = string
    proxied  = optional(bool, false)
    ttl      = optional(number, 1)
    priority = optional(number)
    comment  = optional(string)
  }))

  validation {
    condition = alltrue([
      for record in values(var.dns_records) :
      contains(["A", "AAAA", "CNAME", "MX", "TXT", "CAA", "NS", "SRV"], upper(record.type))
    ])
    error_message = "Each DNS record type must be one of: A, AAAA, CNAME, MX, TXT, CAA, NS, SRV."
  }

  validation {
    condition = alltrue([
      for record in values(var.dns_records) :
      length(trimspace(record.content)) > 0
    ])
    error_message = "Each DNS record content value must be a non-empty string."
  }

  validation {
    condition = alltrue([
      for record in values(var.dns_records) :
      (try(record.priority, null) == null || upper(record.type) == "MX")
    ])
    error_message = "Record priority is only supported for MX records."
  }
}

variable "zone_settings" {
  description = "Zone-level settings override"
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
  default = null

  validation {
    condition = (
      var.zone_settings == null ||
      try(var.zone_settings.min_tls_version, null) == null ||
      contains(["1.0", "1.1", "1.2", "1.3"], var.zone_settings.min_tls_version)
    )
    error_message = "zone_settings.min_tls_version must be one of: 1.0, 1.1, 1.2, 1.3."
  }

  validation {
    condition = (
      var.zone_settings == null ||
      try(var.zone_settings.security_header, null) == null ||
      try(var.zone_settings.security_header.max_age, 0) > 0
    )
    error_message = "zone_settings.security_header.max_age must be greater than 0."
  }

  validation {
    condition = (
      var.zone_settings == null ||
      try(var.zone_settings.ssl, null) == null ||
      contains(["off", "flexible", "full", "strict"], var.zone_settings.ssl)
    )
    error_message = "zone_settings.ssl must be one of: off, flexible, full, strict."
  }
}

variable "zone_id_override" {
  description = "Optional explicit zone_id (used for tests/mocks; leave null in production)"
  type        = string
  default     = null
}
