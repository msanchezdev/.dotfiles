# shellcheck shell=bash
# Phase 10 — install packages from the YAML manifests.
# Shared manifest first, then the device manifest (extra packages for this host).

step "Packages ($PROFILE)"

install_manifest() {
  local file="$1"
  [ -f "$file" ] || { skip "no manifest: ${file#$DOTFILES/}"; return; }
  info "manifest: ${file#$DOTFILES/}"

  # yq converts YAML->JSON, jq flattens each package into one field-separated
  # row. The separator is the ASCII unit separator ( / \037), not a tab:
  # tab is an IFS *whitespace* char, so `read` would collapse consecutive tabs
  # and drop empty fields (e.g. a row with no `bin`).  never collapses
  # and never appears in package data.
  # Fields: via  name  bin  repo  dest  only
  local rows; rows="$(yq -o=json '.packages // []' "$file" | jq -r '
    .[] | [.via, .name, (.bin // ""), (.repo // ""), (.dest // ""),
           ((.only // []) | join(",")), (.cmd // "")] | join("\u001f")')"

  local via name bin repo dest only cmd
  while IFS=$'\037' read -r via name bin repo dest only cmd; do
    [ -z "${via:-}" ] && continue
    if ! platform_match "$only"; then
      skip "$name (skipped on $(os_id))"; continue
    fi
    if [ "$via" = bun ] && ! has bun; then warn "skip $name (bun missing)"; continue; fi
    dispatch_package "$via" "$name" "$bin" "$repo" "$dest" "$cmd"
  done <<< "$rows"
}

install_manifest "$DOTFILES/manifest/packages.yaml"
install_manifest "$DOTFILES/manifest/devices/$PROFILE.yaml"
