# dotfiles

Manifest-driven, idempotent setup. Configs are symlinked with GNU stow;
packages are declared in YAML and installed by the right tool (brew/bun/apt/git).
Shared config is committed; per-device bits layer on top.

## Fresh machine

One line — installs git if needed, clones to `~/.dotfiles`, runs the installer:

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/msanchezdev/.dotfiles/main/bootstrap.sh)"
```

Use this `bash -c "$(...)"` form rather than `curl ... | bash`: it keeps your
terminal attached, so Homebrew can prompt for your **sudo password on macOS**
(a pipe has no TTY and fails with "Need sudo access"). Your user must be an
Administrator.

Or manually:

```sh
git clone https://github.com/msanchezdev/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

`install.sh` runs five idempotent phases (run one at a time by name, e.g.
`./install.sh packages`):

| phase         | what it does                                                        |
|---------------|---------------------------------------------------------------------|
| `bootstrap`   | ensure Homebrew + `yq`/`jq` (manifest parser) + `bun`               |
| `packages`    | install everything in the manifests                                 |
| `stow`        | symlink config packages into `$HOME`                                |
| `env`         | assemble `~/.config/dotfiles/env.sh`, source it from `~/.zshrc`      |
| `postinstall` | tmux plugins (tpm) + `nvim` headless `:Lazy sync`                    |

`stow` runs before `env` deliberately: stowing the `zsh` package creates
`~/.zshrc` (which already embeds the env-sourcing block), so `env` then finds
it and skips. Running `env` first would create `~/.zshrc` as a real file and
the `zsh` stow would conflict.

## Testing on a clean machine

`test/run.sh` boots a bare Ubuntu container, copies in the working tree (minus
`.git` and `*.local.env`, i.e. a fresh-clone view), and runs the full installer
as an unprivileged user — then verifies symlinks, tools, and idempotency.
Requires Docker.

## Layout

```
install.sh                          entrypoint
install/                            lib, installers, phases/
manifest/
  packages.yaml                     shared packages (committed)
  devices/<profile>.yaml            per-device extra packages (committed)
env/
  shared.env                        shared env (committed, non-secret)
  devices/<profile>.env             per-device env (committed, non-secret)
  devices/<profile>.local.env       per-device secrets (gitignored)
nvim/  tmux/  ...                    shared stow packages
devices/<profile>/                  per-device stow overlay packages
```

## Profiles (per-device)

The active device is named by `~/.config/dotfiles/profile` (gitignored; seeded
from the hostname on first run — edit to rename). The installer then layers
`devices/<profile>` files on top of the shared ones.

## Adding a package

Add a row to `manifest/packages.yaml` (or `manifest/devices/<profile>.yaml`):

```yaml
- { via: brew, name: ripgrep, bin: rg }          # bin = skip-if-present check
- { via: bun,  name: "@biomejs/biome", bin: biome }
- { via: apt,  name: build-essential, bin: gcc, only: [linux] }
- { via: git,  name: tpm, repo: "https://github.com/tmux-plugins/tpm", dest: "~/.tmux/plugins/tpm" }
```

`via` picks the installer; `bin` makes the row a fast no-op when already
installed; `only` gates by platform (`linux`/`macos`).

## Not auto-installed

`~/.local/src/surrealql-nvim` is a local dogfood checkout with no git remote, so
the installer only warns if it's missing — clone/restore it manually.
