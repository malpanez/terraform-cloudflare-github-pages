# GitHub Pages Integration

This guide shows how to connect your Cloudflare-managed domain to a GitHub Pages site. Whether you use the classic user/organization site or a project site, the steps are the same. 🚀

## 1. Pick Your Pages Mode

| Type | URL Pattern | Best For | Notes |
|------|-------------|----------|-------|
| **User/Org** | `username.github.io` | Personal sites | One per account |
| **Project** | `username.github.io/project` | App docs, product microsites | Supports custom domains |

Both are supported. The Terraform example assumes a user site because that is the fastest path to a root custom domain.

## 2. Enable GitHub Pages

1. Open your repository on GitHub.
2. Go to **Settings → Pages**.
3. Choose a source:
   - **Deploy from a branch**: select `main` and `/ (root)`.
   - Alternatively, use GitHub Actions for more control.
4. Click **Save** and wait for the confirmation banner.

> Tip: If you are deploying a static site generator (Hugo, Astro, etc.) use the built-in GitHub Actions workflow to build and publish automatically.

## 3. Add the Custom Domain

Still under **Settings → Pages**:

1. Enter your apex domain (e.g., `example.com`) in **Custom domain**.
2. Click **Save**.
3. GitHub will issue a DNS check. Ignore it for now—we are about to create the DNS records with Terraform.

Once the DNS propagates, GitHub will set up Let’s Encrypt certificates automatically. Leave **Enforce HTTPS** checked; Cloudflare handles the edge certificate while GitHub secures the origin.

## 4. Configure DNS via Terraform

In `terraform.tfvars` define the records:

```hcl
dns_records = {
  apex_a_1 = { name = "@", type = "A",    content = "185.199.108.153", proxied = true }
  apex_a_2 = { name = "@", type = "A",    content = "185.199.109.153", proxied = true }
  apex_aaaa_1 = { name = "@", type = "AAAA", content = "2606:50c0:8000::153", proxied = true }

  www = {
    name    = "www"
    type    = "CNAME"
    content = "yourusername.github.io"
    proxied = true
  }
}
```

Apply with:

```bash
terraform init
terraform apply
```

Cloudflare now routes every request through its CDN before forwarding to GitHub Pages.

## 5. Verify Everything

### DNS

```bash
dig +short example.com
dig +short AAAA example.com
dig +short www.example.com
```

Expect GitHub’s IPs for the apex and a CNAME pointing to `yourusername.github.io` for `www`.

### HTTPS

1. Visit `https://www.example.com` and `https://example.com`.
2. Check the certificate (browser lock icon). Issuer should be Cloudflare.
3. Use [https://www.ssllabs.com/ssltest/](https://www.ssllabs.com/ssltest/) for an external scan (takes a few minutes).

### Redirects

- By default GitHub will redirect `www → apex`. Terraform leaves room for your own redirect rules if you upgrade to the PRO version.

## 6. Managing Subdomains

Need `docs.example.com` or `status.example.com`?

1. Add another entry to `dns_records` (CNAME or A/AAAA).
2. Point it to the appropriate host (could be another Pages project, Vercel, Netlify, etc.).
3. `terraform apply`.

Cloudflare will cover SSL and performance automatically as long as the record is proxied.

## 7. Continuous Deployment

GitHub Pages reacts to:

- Pushing to the selected branch.
- Merging PRs into that branch.
- Triggering manual redeploys from the **Pages** settings.

If your repository uses `main`, the cycle is:

1. Commit code.
2. Push to GitHub.
3. GitHub builds the site.
4. Cloudflare serves it instantly (no manual clear-cache needed thanks to smart caching).

## 8. Useful Extras

- **Custom 404/redirects**: create a `404.html` or `_redirects` file (static site generator dependent).
- **Analytics**: enable Cloudflare Web Analytics (zero code) under **Analytics → Web Analytics**.
- **Webhooks**: if you want Terraform to run automatically, add a GitHub Actions workflow in the PRO version.

---

You now have an automated pipeline from GitHub commit to globally cached site under your own domain. 🎉
