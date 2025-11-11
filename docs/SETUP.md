# Complete Setup Guide

Welcome! This guide walks you from zero to a fully automated Cloudflare + GitHub Pages deployment in about 15 minutes. No Terraform experience required. ☕

## 1. Prerequisites Checklist

- ✅ Cloudflare account (free tier is perfect)
- ✅ Domain added to Cloudflare (nameservers already pointing at Cloudflare)
- ✅ GitHub account with a repository ready for Pages
- ✅ Terraform ≥ 1.3.0 installed locally **or** devcontainer ready
- ✅ Cloudflare API token with DNS + Zone permissions

### Quick version checks

```bash
terraform -version
cloudflared --version 2>/dev/null || echo "cloudflared optional"
```

If Terraform is missing, follow the [official install guide](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli).

## 2. Clone the Repository

```bash
git clone https://github.com/homelabforge/cloudflare-terraform-github-pages.git
cd cloudflare-terraform-github-pages
```

If you are using VS Code, open the folder and optionally use the **Dev Container** extension to get a pre-baked Terraform environment.

## 3. Prepare Cloudflare

1. Log in to [dash.cloudflare.com](https://dash.cloudflare.com) and select your domain.
2. Confirm the status banner says *Active* (nameservers pointing correctly).
3. Note the **Account ID** (right sidebar) – handy if you ever need it for advanced setups.

### Create an API token (with screenshots in words)

1. Visit **Profile → API Tokens**.
2. Click **Create Token** → choose **Edit zone DNS** template.
3. On the **Permissions** step, add:
   - `Zone → Zone → Read`
   - `Zone → Zone Settings → Edit`
   - `Zone → DNS → Edit`
4. Under **Zone Resources**, pick **Include → Specific zone → your domain**.
5. Give it a descriptive name like `terraform-github-pages`.
6. Click **Continue to summary** and then **Create Token**.
7. Copy the token right away – you will not see it again.

Picture it like this:
`[Image: Cloudflare API token wizard showing Zone.DNS (Edit) and Zone.Zone Settings (Edit)]`

Export the token so Terraform can use it:

```bash
export CLOUDFLARE_API_TOKEN="cf_token_from_dashboard"
```

Add that line to your shell profile if you do not want to paste it again every time.

## 4. Configure Terraform Variables

Copy the sample file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Open `terraform.tfvars` in your editor and customize:

- `domain` → replace with your apex domain (`example.com`).
- `dns_records` → update the `www` record to point to `yourusername.github.io`.
- Optional: remove the `blog` record if you do not need it.
- Optional: tweak `zone_settings` if you have special requirements.

> Tip: Keep the structure as-is. Terraform’s map syntax is strict about commas. When in doubt, run `terraform fmt`.

## 5. Initialize Terraform

Terraform needs to download providers and set up the working directory.

```bash
terraform init
```

You should see output similar to:

```
- Downloading cloudflare/cloudflare v5.x.x...
- Installing cloudflare/cloudflare v5.x.x...
Terraform has been successfully initialized!
```

If you get an authentication error, double-check that `CLOUDFLARE_API_TOKEN` is exported in the same shell.

## 5b. Import existing DNS records (only if Cloudflare already has them)

Cloudflare provider v5 removed the `allow_overwrite` flag, so Terraform cannot replace DNS records that already exist in the zone. If you previously configured the DNS records manually (common when migrating), import them into state _before_ running `terraform plan`/`apply`.

1. Export your zone ID (from the dashboard or `terraform output zone_id` after a dry run):
   ```bash
   export ZONE_ID=0b5f73b1e10beb841fac981cbe5f16a8
   ```
2. List the existing DNS records and note their IDs:
   ```bash
   curl -s "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?per_page=100" \
     -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
     -H "Content-Type: application/json" \
     | jq -r '.result[] | [.name, .type, .content, .id] | @tsv'
   ```
3. Import each record that already exists (repeat for every key you defined inside `dns_records`):
   ```bash
   terraform import 'cloudflare_dns_record.this["apex_a_1"]' $ZONE_ID/<record_id>
   terraform import 'cloudflare_dns_record.this["apex_a_2"]' $ZONE_ID/<record_id>
   terraform import 'cloudflare_dns_record.this["apex_a_3"]' $ZONE_ID/<record_id>
   terraform import 'cloudflare_dns_record.this["apex_a_4"]' $ZONE_ID/<record_id>
   terraform import 'cloudflare_dns_record.this["apex_aaaa_1"]' $ZONE_ID/<record_id>
   # ...and so on for AAAA/CNAME records
   ```
4. Re-run `terraform plan`. Terraform should now treat those records as managed resources instead of trying to recreate them.

## 6. Validate the Plan

Always preview what Terraform will do:

```bash
terraform plan
```

Look for:

- Creation of 8 A/AAAA records
- CNAME for `www` (and any extras you defined)
- Zone settings
- DNSSEC enabling

Everything looks good? Apply!

```bash
terraform apply
```

Confirm with `yes` when prompted.

## 7. Run Terraform tests (optional but helpful)

Terraform 1.5 introduced a built-in test runner. Use it to catch mistakes before production:

```bash
terraform test
```

> Note: the tests use the same Cloudflare token as `terraform plan`. Export `CLOUDFLARE_API_TOKEN` (or define `cloudflare_api_token` in your tfvars) before running them.

Extend the tests later to cover custom modules or policies.

## 8. Verify the Deployment

### DNS records

- Run `dig +short example.com` and make sure the GitHub Pages IPs are returned.
- Run `dig +short www.example.com` and confirm you see `yourusername.github.io`.

### HTTPS + HSTS

- Visit `https://yourdomain.com`.
- In browser devtools, check **Security** → certificate issued by Cloudflare.
- Inspect response headers for `Strict-Transport-Security` and `x-content-type-options`.

### DNSSEC

- In the Cloudflare dashboard, go to **DNS → DNSSEC**.
- Status should say **Enabled**.
- If your registrar requires manual DS records, copy the values from `terraform output dnssec_ds_records`.

## 9. Keep Terraform State Safe

This FREE starter keeps state locally. Add these best practices:

- `.gitignore` already protects `terraform.tfstate`.
- For teams, use Terraform Cloud, S3, or any remote backend.
- If you switch computers, copy `terraform.tfstate` (securely) or re-import resources.

## 10. Updating and Destroying

### Update DNS or settings

1. Edit `terraform.tfvars`.
2. Run `terraform plan` to double-check.
3. Apply with `terraform apply`.

### Tear everything down

```bash
terraform destroy
```

Say `yes` and Cloudflare reverts to a blank slate.

## 11. Troubleshooting Highlights

- `Error: HTTP status 403` → Token missing permissions or expired.
- `Error: not found` → Make sure the domain exists in Cloudflare and matches `var.domain`.
- Records not proxied? → Ensure `proxied = true` and Cloudflare orange cloud is enabled.
- SSL pending? → Wait up to 15 minutes. Certificates are issued automatically once DNS resolves.

Full list: see [docs/TROUBLESHOOTING.md](TROUBLESHOOTING.md).

---

You just automated hours of repetitive Cloudflare setup. 🎉
Next step: explore the [Advanced example](../examples/advanced) for subdomains and overrides.
