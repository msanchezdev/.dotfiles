#!/usr/bin/env bash
# WSL: install Surrealist as the Windows app — the latest from GitHub (winget's
# StarlaneStudios.Surrealist is far behind). Silent NSIS install via interop,
# per-user (no admin). Idempotent.
set -euo pipefail

grep -qiE '(microsoft|wsl)' /proc/version 2>/dev/null || { echo "surrealist-windows: WSL only"; exit 0; }
command -v cmd.exe >/dev/null 2>&1 || { echo "surrealist-windows: no Windows interop"; exit 1; }

localappdata="$(wslpath "$(cmd.exe /c 'echo %LOCALAPPDATA%' 2>/dev/null | tr -d '\r')")"
[ -x "$localappdata/Surrealist/surrealist.exe" ] && exit 0 # already installed

url="$(curl -fsSL https://api.github.com/repos/surrealdb/surrealist/releases/latest \
  | grep -oE 'https://[^"]+_x64-setup\.exe' | head -1)"
[ -n "$url" ] || { echo "surrealist-windows: no x64-setup.exe in the latest release" >&2; exit 1; }

# Download into the Windows %TEMP% so the Windows installer can run it.
wtmp="$(wslpath "$(cmd.exe /c 'echo %TEMP%' 2>/dev/null | tr -d '\r')")"
setup="$wtmp/Surrealist-setup.exe"
curl -fsSL -o "$setup" "$url"
"$setup" /S # Tauri NSIS: /S = silent, per-user install to %LOCALAPPDATA%\Programs
rm -f "$setup"
