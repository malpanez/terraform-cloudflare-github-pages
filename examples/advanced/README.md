# Advanced Example

Full configuration with multiple subdomains, opinionated zone settings, and security headers. Great for small product suites or multi-project portfolios.

## Features

- Apex domain + `www` on GitHub Pages
- `blog` on Hashnode (CNAME)
- `status` on an external status page (A record)
- HSTS preload, nosniff, and strict TLS 1.3 minimum
- Overwrite-safe DNS entries

## How to run

```bash
cd examples/advanced
cp terraform.tfvars.example terraform.tfvars
export CLOUDFLARE_API_TOKEN="cf_token_here"
terraform init
terraform apply
```

Adjust the records to match your stack. Add or remove entries freely—Terraform keeps everything in sync.
