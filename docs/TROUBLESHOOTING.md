# Troubleshooting Guide

Hit a snag? Here are the most common issues (and fixes) when automating Cloudflare + GitHub Pages with Terraform. 🛠️

## DNS Issues

### DNS records not propagating
- **Symptom:** `dig example.com` still returns old IPs.
- **Fix:** Wait up to 5 minutes. Cloudflare updates instantly, but global DNS resolvers may cache previous values. Use `dig @1.1.1.1 example.com` to query Cloudflare directly.
- **Extra:** Verify `terraform state list` shows the records. If missing, re-run `terraform apply`.

### CNAME returns `github.map.fastly.net`
- **Symptom:** `www.example.com` shows a Fastly endpoint instead of GitHub Pages.
- **Fix:** GitHub recently migrated Pages to Fastly. This is expected and works fine with Cloudflare.

### DNSSEC errors at registrar
- **Symptom:** Registrar rejects DS records.
- **Fix:** Confirm your registrar supports DNSSEC. Use the `digest`, `algorithm`, and `key_tag` from `terraform output dnssec_ds_records`. If they require upper-case hex or spaces, format accordingly.

## HTTPS / SSL Problems

### Cloudflare pending certificate
- **Symptom:** The edge certificate status sits at *Pending*.
- **Fix:** DNS must already point at Cloudflare AND GitHub must serve the site. Wait 15-30 minutes. Check **SSL/TLS → Edge Certificates** in Cloudflare for progress.

### GitHub Pages shows certificate mismatch
- **Symptom:** Visiting the site shows a GitHub certificate, not Cloudflare.
- **Fix:** Ensure Cloudflare proxy (orange cloud) is enabled for the CNAME. Terraform sets `proxied = true`, but if someone toggled it off in the UI, edit the record back to proxied or re-apply Terraform.

### HSTS locked me out
- **Symptom:** Browser refuses to load the site after disabling HTTPS.
- **Fix:** HSTS is sticky. Re-enable HTTPS and wait for the `max-age` to expire. For local testing, use a different subdomain or browser profile.

## Terraform Errors

### `Error 403: insufficient_permissions`
- **Cause:** API token missing permissions.
- **Fix:** Recreate the token with `Zone.DNS (Edit)`, `Zone.Zone Settings (Edit)`, `Zone.Zone (Read)`. Update your environment variable.

### `Error 404: zone not found`
- **Cause:** The domain is not in your Cloudflare account or you selected the wrong account.
- **Fix:** Double-check `var.domain`, ensure the zone is active in the dashboard, and confirm your token is scoped to the right zone.

### `Error: record already exists`
- **Cause:** DNS record already exists in Cloudflare outside Terraform.
- **Fix:** Delete the manual record (or import it into state) before running Terraform. Provider v5 no longer supports `allow_overwrite`, so Terraform cannot automatically replace live records.

### Terraform state drift
- **Cause:** Manual changes in Cloudflare.
- **Fix:** Run `terraform plan` regularly. If differences appear, decide whether to accept the manual change (by exporting/importing state) or revert it via Terraform.

## Performance Issues

### Site loads slowly on first visit
- **Fix:** Enable GitHub Pages' native build optimizations (minify CSS/JS) or serve pre-compressed assets. Cloudflare caches static files but cannot optimize bulky bundles.

### Assets not updating after deploy
- **Fix:** GitHub Pages may cache aggressively. Append a version hash to asset filenames or query strings. You can also purge Cloudflare cache via dashboard (under **Caching → Configuration → Purge Cache**).

## API Rate Limits

### `HTTP status 429 Too Many Requests`
- **Cause:** Terraform apply loops or dozens of records at once.
- **Fix:** Wait 30 seconds and rerun. Breaking changes into smaller batches helps. Cloudflare Free plan allows 1,200 requests per five minutes per token.

## GitHub Pages Specific

### 404 after deploying
- **Cause:** Repository lacks `index.html` or the build failed.
- **Fix:** Check the **Pages** deployment in GitHub Actions or `Settings → Pages → Latest deployments`.

### Custom 404 not showing
- **Cause:** Cloudflare caches the previous version.
- **Fix:** Purge the cache. Or set a `Cache-Control` header on `404.html` to a small `max-age`.

## Still Stuck?

1. Run `terraform plan` and copy the error output.
2. Gather logs/screenshots from Cloudflare or GitHub.
3. Open an issue: [GitHub Issues](https://github.com/homelabforge/cloudflare-terraform-github-pages/issues).

Include:
- Terraform version (`terraform version`)
- Cloudflare zone name (if you can share it)
- Steps to reproduce

Paid users get email support at [hello@homelabforge.dev](mailto:hello@homelabforge.dev). 💌
