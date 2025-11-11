# Cloudflare Configuration Deep Dive

This document explains what the Terraform module configures inside Cloudflare, why it matters, and how you can extend it. Everything here works on the Free plan. 🛡️

## 1. Zone Settings Overview

Terraform applies a curated set of [zone settings](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/zone_setting). Each setting is selected to maximize security and performance without breaking GitHub Pages.

| Setting | Value | Why it matters |
|---------|-------|----------------|
| `always_use_https` | `on` | Redirects every HTTP request to HTTPS automatically. |
| `automatic_https_rewrites` | `on` | Fixes mixed-content issues by rewriting `http` links to `https`. |
| `min_tls_version` | `1.2` | Blocks legacy TLS for stronger security. |
| `tls_1_3` | `on` | Enables faster TLS handshakes with modern browsers. |
| `browser_check` | `on` | Drops requests from known bad bots. |
| `brotli` | `on` | Compresses text-based assets better than gzip. |
| `http3` | `on` | Activates QUIC/HTTP3 for improved latency on flaky networks. |
| `zero_rtt` | `on` | Allows returning visitors to resume sessions instantly. |
| `early_hints` | `on` | Tells browsers which assets to preload before the response completes. |
| `rocket_loader` | `off` | Avoids script reordering issues that sometimes break static sites. |
| `ssl` | `strict` | Forces Cloudflare to require a valid certificate at the origin. |

You can override any of these in `terraform.tfvars`. For example:

```hcl
zone_settings = {
  min_tls_version = "1.3"
  rocket_loader    = "on"
}
```

## 2. Security Headers

Cloudflare can inject HTTP response headers at the edge. The default FREE profile keeps it simple:

```http
Strict-Transport-Security: max-age=31536000; includeSubDomains
X-Content-Type-Options: nosniff
```

Configure your own via:

```hcl
zone_settings = {
  security_header = {
    enabled            = true
    max_age            = 63072000
    include_subdomains = true
    preload            = true
    nosniff            = true
  }
}
```

Want CSP, X-Frame-Options, or Referrer-Policy? Those require **Transform Rules** (available in the PRO upgrade). For this FREE version, add them directly in your static site if needed.

## 3. DNSSEC

Terraform enables [DNSSEC](https://developers.cloudflare.com/dns/dnssec/) automatically via `cloudflare_zone_dnssec`. Benefits:

- Protects against DNS spoofing.
- Works with any registrar that supports DS records.

Steps to finish setup:

1. Run `terraform output dnssec_ds_records`.
2. Copy the DS record values.
3. Paste them into your domain registrar (not Cloudflare, the origin registrar).

Cloudflare handles the rest. Propagation can take up to 24 hours; expect a green **Enabled** badge afterward.

## 4. Analytics and Caching

Although this repo does not configure analytics directly, you get a lot for free:

- **Analytics → Web Analytics**: privacy-first insights without JavaScript.
- **Cache → Cache Rules**: default caching works well for static assets. For finer control (e.g., bypass caching on `/admin`), upgrade to the PRO version for rule automation.
- **Speed → Optimization**: Brotli, HTTP/3, and Early Hints are already enabled.

## 5. Free Plan Limits to Remember

- **Rulesets**: Single Redirect rules are limited. This FREE template does not create redirects, so you stay within limits.
- **Workers**: Not used here. You can add them manually later.
- **Rate Limiting**: Absent on Free. Consider upgrading if you expect high traffic or attacks.

## 6. Extending the Setup

Here are safe additions you can layer on without leaving the Free plan:

- **Page Rules**: Add a rule for `/*` to set cache level to *Cache Everything* for static sites.
- **Firewall Rules**: Simple IP allow/deny rules.
- **Access Rules**: Country-level blocking/allowing.

If you move to the PRO tier for Terraform:

- Use `cloudflare_ruleset` resources for Single Redirects.
- Automate cache behaviors with Transform and Cache rules.
- Add Workers for custom logic (API protection, scheduled tasks).

## 7. Change Management Tips

- Run `terraform plan` before every `apply`. Cloudflare APIs are fast; mistakes propagate instantly.
- Use [Cloudflare Audit Logs](https://developers.cloudflare.com/fundamentals/setup/account/account-logs/) (available on higher tiers) to track manual changes.
- For teams, enable account-level 2FA and consider SCIM provisioning.

---

You now understand exactly how Terraform configures Cloudflare. For common issues, jump to [TROUBLESHOOTING.md](TROUBLESHOOTING.md). Ready to showcase your work? Deploy the [Advanced example](../examples/advanced). 💪
