# cloudflare/ — short install URL

A tiny Cloudflare Worker that serves the dotfiles bootstrap at a short, branded
URL so the one-liner becomes:

```sh
curl https://dotfiles.msanchez.dev/install | bash
```

`worker.js` proxies the latest `bootstrap.sh` from GitHub and returns it with a
**200** (not a redirect — so no `curl -L` is needed). Editing `bootstrap.sh` in
the repo is enough; the Worker never needs redeploying for script changes.

## Deploy with Terraform (provider `cloudflare/cloudflare` v5)

> Field names are for provider v5 — verify against the version your stack pins.

```hcl
resource "cloudflare_workers_script" "dotfiles_install" {
  account_id         = var.cloudflare_account_id
  script_name        = "dotfiles-install"
  content            = file("${path.module}/worker.js") # or vendor the file into your TF repo
  main_module        = "worker.js"
  compatibility_date = "2025-01-01"
}

# Binds dotfiles.msanchez.dev to the Worker AND manages the DNS record.
resource "cloudflare_workers_custom_domain" "dotfiles" {
  account_id  = var.cloudflare_account_id
  zone_id     = var.msanchez_dev_zone_id
  hostname    = "dotfiles.msanchez.dev"
  service     = cloudflare_workers_script.dotfiles_install.script_name
  environment = "production"
}
```

That's the whole thing: one `workers_script` + one `workers_custom_domain`
(which also creates the proxied DNS record — no separate `cloudflare_record`
needed).

## Quick test without Terraform (wrangler)

```sh
# wrangler.toml: name = "dotfiles-install", main = "worker.js",
#                compatibility_date = "2025-01-01"
wrangler deploy
wrangler deployments  # then add the custom domain in the dashboard or via TF
```

## Smoke test after deploy

```sh
curl -s https://dotfiles.msanchez.dev/install | head -5   # should be bootstrap.sh
curl -sI https://dotfiles.msanchez.dev/install | grep -i content-type
```
