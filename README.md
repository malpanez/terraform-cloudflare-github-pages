# Cloudflare + GitHub Pages: Infrastructure as Code

> Stop clicking through Cloudflare's UI. Automate your static site infrastructure in 5 minutes.

![GitHub Repo stars](https://img.shields.io/github/stars/malpanez/terraform-cloudflare-github-pages?style=social)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Terraform >=1.3](https://img.shields.io/badge/Terraform-%3E%3D%201.3.0-623CE4?logo=terraform)

**What this does:** Automated DNS, SSL, security headers, and performance optimization for static sites hosted on GitHub Pages.

**Time saved:** 2 hours of clicking → 5 minutes of code

## 😫 The Problem

Setting up Cloudflare for a static site means:

1. Adding 8+ DNS records manually
2. Configuring SSL/TLS settings
3. Setting up security headers
4. Enabling performance features
5. Testing everything
6. **Repeating this for every project**

And if you need to change something? Back to clicking through the UI.

## ✨ The Solution

This Terraform configuration automates everything:

```bash
terraform apply
# That's it. Your infrastructure is live.
```

### What You Get (FREE)

#### DNS Configuration
- ✅ GitHub Pages (4x A + 4x AAAA records)
- ✅ www subdomain (auto-configured)
- ✅ Custom subdomains (blog, docs, etc.)
- ✅ DNSSEC enabled

#### Security
- ✅ SSL/TLS Full (Strict)
- ✅ HSTS with preload support
- ✅ X-Content-Type-Options: nosniff
- ✅ Always HTTPS redirect

#### Performance
- ✅ Brotli compression
- ✅ HTTP/3 + 0-RTT
- ✅ Early Hints
- ✅ Browser cache optimization

#### Free Tier Optimized
- ✅ All features work on Cloudflare Free plan
- ✅ No enterprise features required
- ✅ Battle-tested in production

## 🏠 Real-World Example

I use this exact setup for [homelabforge.dev](https://homelabforge.dev):

**Stack:**
- GitHub Pages for hosting
- Cloudflare for CDN + security
- Terraform for automation

**Results:**
- ⚡ Lighthouse Performance: 98/100
- 🔒 A+ SSL Labs rating
- 🚀 First Contentful Paint: <1s
- 🔄 Zero manual maintenance

**Maintenance time:** 0 hours/month (it just works)

[Read the full story →](docs/SETUP.md)

## 🚀 Quick Start

### Prerequisites

- Cloudflare account (free tier works)
- Domain added to Cloudflare
- GitHub Pages site (or any static host)
- Terraform >= 1.3.0

### Step 1: Clone

```bash
git clone https://github.com/homelabforge/cloudflare-terraform-github-pages.git
cd cloudflare-terraform-github-pages
```

### Step 2: Configure

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
domain = "yourdomain.com"

dns_records = {
  # GitHub Pages IPv4
  "apex-a-1" = {
    name    = "@"
    type    = "A"
    content = "185.199.108.153"
    proxied = true
  }
  # ... more records ...
}
```

### Step 3: Get Cloudflare API Token

1. Go to [Cloudflare Dashboard → API Tokens](https://dash.cloudflare.com/profile/api-tokens)
2. Create Token → Edit zone DNS
3. Permissions: `Zone.DNS (Edit)`, `Zone.Zone Settings (Edit)`, `Zone.Zone (Read)`
4. Zone Resources: Include → Specific zone → Your domain

```bash
export CLOUDFLARE_API_TOKEN="your_token_here"
```

### Step 4: Deploy

```bash
terraform init
terraform plan    # Review changes
terraform test    # Run infrastructure tests
terraform apply   # Deploy
```

**Done.** Your infrastructure is live.

> ℹ️ `terraform test` uses your Cloudflare credentials. Export `CLOUDFLARE_API_TOKEN` (or set it via `.tfvars`) before running it.

> ⚠️ **Migrating an existing zone?** The Cloudflare provider v5 removed `allow_overwrite`, so Terraform cannot replace DNS records that already exist. Import those records into state (or delete them manually) before running `terraform apply`.

#### Import existing DNS records (only if Cloudflare already has them)
1. Grab your zone ID (from the Cloudflare dashboard or `terraform output zone_id` after a plan).
2. List current records and capture their IDs:
   ```bash
   export ZONE_ID=your_zone_id
   curl -s "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?per_page=100" \
     -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
     -H "Content-Type: application/json" \
     | jq -r '.result[] | [.name, .type, .content, .id] | @tsv'
   ```
3. Import each record so Terraform manages it (repeat for every entry in `dns_records`):
   ```bash
   terraform import 'cloudflare_dns_record.this["apex_a_1"]' $ZONE_ID/<record_id>
   terraform import 'cloudflare_dns_record.this["apex_a_2"]' $ZONE_ID/<record_id>
   # ...and so on for A/AAAA/CNAME records
   ```
4. Re-run `terraform plan` to ensure Terraform no longer tries to recreate those records.

### Optional: open in the Terraform dev container

This repository bundles the [malpanez/ansible-devcontainer-vscode](https://github.com/malpanez/ansible-devcontainer-vscode) Terraform stack so you can spin up a fully tooled environment (Terraform, Terragrunt, TFLint, SOPS, `uv`, and pre-commit) in a single click.

1. Install Docker Desktop/CLI and the [VS Code Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers).
2. Open this folder in VS Code and choose **Reopen in Container**.
3. The dev container builds the same image defined upstream, copies in the Terraform pre-commit template, and runs `ensure-precommit` automatically (creating `.pre-commit-config.yaml` if you don’t have one).

All commands (`terraform test`, `terraform apply`, etc.) run inside the container while your files stay on the host filesystem. Export `CLOUDFLARE_API_TOKEN` inside the container shell before testing/applying.

### Step 5: Configure GitHub Pages

In your GitHub repo:
1. Settings → Pages
2. Custom domain: `yourdomain.com`
3. Enforce HTTPS ✅

Wait 1-5 minutes for DNS propagation. Test: `https://yourdomain.com`

## 📦 What's Included

### DNS Records (All GitHub Pages IPs)

**IPv4 (A Records):**
- 185.199.108.153
- 185.199.109.153
- 185.199.110.153
- 185.199.111.153

**IPv6 (AAAA Records):**
- 2606:50c0:8000::153
- 2606:50c0:8001::153
- 2606:50c0:8002::153
- 2606:50c0:8003::153

**Subdomains:**
- www → your-user.github.io (CNAME)
- blog → hashnode.network (optional)
- Custom subdomains supported

### Zone Settings (Optimized)

All Cloudflare Free tier features enabled:
- Always Use HTTPS
- Automatic HTTPS Rewrites
- TLS 1.2 minimum
- TLS 1.3 enabled
- Browser Integrity Check
- Brotli compression
- HTTP/3
- 0-RTT Connection Resumption
- Early Hints

### Security Headers

```http
Strict-Transport-Security: max-age=31536000; includeSubDomains
X-Content-Type-Options: nosniff
```

Optional (configure in `zone_settings`):
- Content Security Policy
- X-Frame-Options
- Referrer-Policy

### DNSSEC

Automatically enabled for enhanced DNS security.

## 🆚 FREE vs PRO

This is the **FREE** version. Perfect for:
- Personal blogs
- Portfolio sites
- Small projects
- Learning Terraform

| Feature | FREE | PRO |
|---------|------|-----|
| DNS + SSL Setup | ✅ | ✅ |
| Security Headers | ✅ Basic | ✅ Advanced |
| DNSSEC | ✅ | ✅ |
| Zone Settings | ✅ | ✅ |
| Documentation | ✅ Good | ✅ Excellent |
| DevContainer | ✅ | ✅ Pre-configured |
| GitHub Actions | ❌ | ✅ Auto-deploy |
| Drift Detection | ❌ | ✅ Weekly checks |
| Auto-Healing | ❌ | ✅ Self-fixing |
| State Encryption | ❌ | ✅ SOPS + Age |
| Pre-commit Hooks | ❌ | ✅ 8+ checks |
| Advanced Rulesets | ❌ | ✅ Cache, redirects |
| Email Support | ❌ | ✅ 30 days |

**Want PRO?** [Join the waitlist →](https://homelabforge.dev/pro-waitlist) (launching soon)

### Why PRO?

The FREE version requires manual `terraform apply` and state management.

PRO adds:
- 🔄 **Auto-healing:** Infrastructure checks itself weekly, auto-fixes drift
- 🐳 **DevContainer:** Zero local setup, everything pre-installed
- ⚙️ **CI/CD:** Push to main = auto-deploy
- 🔐 **Secrets:** Encrypted state with SOPS
- 🛡️ **Security:** 8+ pre-commit hooks catch issues before deploy

**Use case:** "I set it up once and forgot about it for 6 months. It just works." - Me

This is exactly what I use for homelabforge.dev.

## 📚 Documentation

**Getting Started:**
- [Complete Setup Guide](docs/SETUP.md)
- [GitHub Pages Integration](docs/GITHUB_PAGES.md)
- [Cloudflare Configuration](docs/CLOUDFLARE.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)

**Examples:**
- [Basic Setup](examples/basic/) - Minimal configuration
- [Advanced Setup](examples/advanced/) - Multiple subdomains

**Blog Posts:**
- [How I Automated My Blog Infrastructure](https://blog.homelabforge.dev/cloudflare-terraform-free)
- [Terraform + Cloudflare Best Practices](https://blog.homelabforge.dev/terraform-cloudflare-guide)

## 🤝 Contributing

Contributions welcome! This is actively maintained.

**How to contribute:**
1. Fork the repo
2. Create a feature branch
3. Test your changes
4. Submit a PR

**Ideas wanted:**
- More examples
- Better documentation
- Integration guides
- Bug fixes

Please open an issue first to discuss major changes.

## ❓ FAQ

**Q: Does this work with Netlify/Vercel?**
A: Yes! Just change the DNS records to point to your host. The rest stays the same.

**Q: What about Cloudflare Pages?**
A: This is for external hosting. Cloudflare Pages has its own setup.

**Q: Can I use this with a subdomain?**
A: Absolutely. Just adjust the `domain` variable.

**Q: Is the state stored in Git?**
A: No. Add `terraform.tfstate` to `.gitignore`. Use Terraform Cloud or S3 backend.

**Q: What if I have multiple domains?**
A: Use Terraform workspaces or separate state files.

**Q: Does this cost money?**
A: Nope. Cloudflare Free + GitHub Pages Free = $0/month.

**Q: Can I customize the settings?**
A: Yes! Edit `zone_settings` in `terraform.tfvars`.

**Q: How do I revert changes?**
A: `terraform destroy` removes everything. Or manually in Cloudflare.

**Q: Where's the state stored?**
A: Local by default. Configure remote backend for production.

## 💬 Support

**Free Support:**
- [GitHub Issues](https://github.com/malpanez/terraform-cloudflare-github-pages/issues) - Bug reports
- [Discussions](https://github.com/malpanez/terraform-cloudflare-github-pages/discussions) - Questions
- [Examples](examples/) - Working code

**Paid Support:**
- PRO version includes 30-day email support
- Custom setup available ([Contact](mailto:miguel@homelabforge.dev))

**Community:**
- Follow [@malpanez](https://twitter.com/malpanez) for updates
- Join [Discord](https://homelabforge.dev/discord) (coming soon)

## 📄 License

MIT License - use freely for personal or commercial projects.

## 🙏 Credits

Built by [Miguel Alpañez Alcalde](https://homelabforge.dev)

**Resources:**
- [Cloudflare Terraform Provider](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs)
- [GitHub Pages Documentation](https://docs.github.com/en/pages)

**Inspired by:**
- The pain of clicking through Cloudflare UI 100 times
- My ADHD brain forgetting to check configurations

## ⭐ Star History

If this saved you time, please star the repo!

[![Star History Chart](https://api.star-history.com/svg?repos=malpanez/terraform-cloudflare-github-pages&type=Date)](https://star-history.com/#homelabforge/cloudflare-terraform-github-pages)

---

**Built with ☕ and automation** | [Blog](https://blog.homelabforge.dev) | [Newsletter](https://homelabforge.dev/newsletter) | [LinkedIn](https://www.linkedin.com/in/miguel-alpa%C3%B1ez/)
