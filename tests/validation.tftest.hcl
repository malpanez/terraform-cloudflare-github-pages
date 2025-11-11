variable "domain" {
  description = "Reusable domain for validation-only tests"
  default     = "example.com"
}

mock_provider "cloudflare" {
  source = "./tests/mock_providers/cloudflare"
}

run "rejects_invalid_domain" {
  command = plan

  variables {
    domain = "not a domain"
    zone_id_override = "fake-zone-id"
  }

  expect_failures = [
    var.domain
  ]
}

run "rejects_unknown_record_type" {
  command = plan

  variables {
    domain = var.domain
    zone_id_override = "fake-zone-id"
    dns_records = {
      bad_record = {
        type    = "WRONG"
        content = "value"
      }
    }
  }

  expect_failures = [
    var.dns_records
  ]
}

run "rejects_priority_on_non_mx" {
  command = plan

  variables {
    domain = var.domain
    zone_id_override = "fake-zone-id"
    dns_records = {
      apex = {
        type     = "A"
        content  = "1.2.3.4"
        priority = 1
      }
    }
  }

  expect_failures = [
    var.dns_records
  ]
}

run "rejects_blank_content" {
  command = plan

  variables {
    domain = var.domain
    zone_id_override = "fake-zone-id"
    dns_records = {
      apex = {
        type    = "A"
        content = ""
      }
    }
  }

  expect_failures = [
    var.dns_records
  ]
}

run "rejects_invalid_min_tls_version" {
  command = plan

  variables {
    domain = var.domain
    zone_id_override = "fake-zone-id"
    zone_settings = {
      min_tls_version = "0.9"
    }
  }

  expect_failures = [
    var.zone_settings
  ]
}

run "rejects_invalid_security_header_max_age" {
  command = plan

  variables {
    domain = var.domain
    zone_id_override = "fake-zone-id"
    zone_settings = {
      security_header = {
        enabled = true
        max_age = 0
      }
    }
  }

  expect_failures = [
    var.zone_settings
  ]
}

run "rejects_invalid_ssl_mode" {
  command = plan

  variables {
    domain = var.domain
    zone_id_override = "fake-zone-id"
    zone_settings = {
      ssl = "invalid"
    }
  }

  expect_failures = [
    var.zone_settings
  ]
}
