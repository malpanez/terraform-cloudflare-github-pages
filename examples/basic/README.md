# Basic Example

Minimal configuration for a personal site hosted on GitHub Pages. Uses the defaults from the root module and only sets the required variables.

## How to run

```bash
cd examples/basic
cp terraform.tfvars.example terraform.tfvars
export CLOUDFLARE_API_TOKEN="cf_token_here"
terraform init
terraform apply
```

Variables:
- `domain` – apex domain managed in Cloudflare.
- `dns_records` – GitHub Pages A/AAAA records and a `www` CNAME.

This example keeps `zone_settings = null`, so the defaults from the module apply automatically.
