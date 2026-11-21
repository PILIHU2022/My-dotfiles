# Repository Guidelines

GNU Stow-managed Arch Linux/Hyprland dotfiles; each top-level package mirrors its deployment path.

## Project Structure & Module Organization

- Top-level directories (`hypr/`, `nvim/`, `waybar/`, `zsh/`, etc.) are Stow packages mapping to `$HOME`; `etc/` and `mihomo/` map to `/`.
- Package scripts stay beside their configs, such as `waybar/.config/waybar/scripts/`.
- `docs/` holds troubleshooting notes and reviewed diagnostic/repair scripts; it is not deployed.
- `zi-deprecated/` vendors plugins as submodules. Keep runtime data, secrets, and media out of Git.

## Build, Test, and Development Commands

No compile step or test runner exists; GNU Stow and system packages are prerequisites.

```bash
git submodule update --init --recursive
stow -d . -t ~ -n -v <package>
stow -d . -t ~ --restow <package>
sudo stow -d . -t / -n -v --no-folding etc
```

Preview deployments first. Apply system packages with `sudo stow -d . -t / --no-folding etc`; run helper scripts with `--dry-run` or `--check` when available.

## Coding Style & Naming Conventions

- Preserve package names and destination paths; names are case-sensitive (`Code`, `gtk3.0`).
- Use two spaces in Lua/shell and four in Python; preserve upstream syntax for vendor-style configs.
- StyLua rules are in `hypr/.config/hypr/.stylua.toml` and `nvim/.config/nvim/.stylua.toml`; run `stylua --check <path>` when installed.
- Use Bash for shell entry points, quote variables, and prefer `set -euo pipefail`.

## Testing Guidelines

No automated suite or coverage requirement exists. Validate with syntax checks, Stow simulation, and manual testing in the affected session.

- Run `bash -n` on changed scripts and `python3 -m py_compile audiosnoop/.local/bin/audiosnoop` after Python edits.
- Check Lua with `luac -p`; test Stow deployment and rollback (`stow -D`) on a disposable target.

## Commit & Pull Request Guidelines

Use Conventional Commits with imperative summaries and package/topic scopes: `feat(waybar): add DND module`, `fix(hypr): update screenshot binding`, `docs: clarify Stow setup`. Keep commits focused and revertible; explain non-obvious behavior in the body.

No PR template or CI exists. PRs should list affected packages, deployment targets, validation, linked issues, and rollback steps.

## Security & Configuration Tips

- Replace personal data with `README.md` placeholders; never commit tokens, real hostnames, private paths, or subscription URLs.
- Never force-add ignored runtime data or media; keep `mihomo/config.yaml` and `profiles/` local.
- `etc/` and `mihomo/` require root; review links and use `--no-folding`.
- Do not Stow `nvim` and `nvim_ds-lazyvim` together; both target `~/.config/nvim`.
