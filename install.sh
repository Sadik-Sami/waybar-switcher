#!/usr/bin/env bash
# Usage:
#   ./install.sh                    # interactive
#   ./install.sh --yes              # non-interactive (assume yes)
#   ./install.sh --move-current     # assume yes and move current waybar into styles/default
#   ./install.sh --dry-run          # preview moves (does not change filesystem)
#   ./install.sh --dry-run --yes    # preview + auto-yes
#
set -euo pipefail

# ---------------------------
# Colors / helpers (with safe fallback)
# ---------------------------
if command -v tput >/dev/null 2>&1; then
  RED="$(tput setaf 1)"
  GREEN="$(tput setaf 2)"
  YELLOW="$(tput setaf 3)"
  BLUE="$(tput setaf 4)"
  MAGENTA="$(tput setaf 5)"
  CYAN="$(tput setaf 6)"
  BOLD="$(tput bold)"
  DIM="$(tput dim)"
  RESET="$(tput sgr0)"
else
  RED="\033[31m"
  GREEN="\033[32m"
  YELLOW="\033[33m"
  BLUE="\033[34m"
  MAGENTA="\033[35m"
  CYAN="\033[36m"
  BOLD="\033[1m"
  DIM="\033[2m"
  RESET="\033[0m"
fi

# small UI helpers
info()  { printf "%b\n" "${BLUE}${BOLD}→${RESET} $*"; }
ok()    { printf "%b\n" "${GREEN}${BOLD}✓${RESET} $*"; }
warn()  { printf "%b\n" "${YELLOW}${BOLD}!${RESET} $*"; }
err()   { printf "%b\n" "${RED}${BOLD}✗${RESET} $*" >&2; }
title() {
  printf "%b\n" "${MAGENTA}${BOLD}
   __        __                  _
  / /  ___  / /___  ___  ___    (_)__  ___  ___ ___
 / /__/ _ \\/ / __/ / _ \\/ _ \\  / / _ \\/ _ \\/ -_|_-<
/____/\\___/_/\\__/  \\___/\\___/ /_/\\___/\\___/\\__/___/
${RESET}"
  printf "%b\n" "${CYAN}${BOLD}Omarchy Waybar installer${RESET}\n"
}

# ---------------------------
# parse args
# ---------------------------
AUTO_YES=false
AUTO_MOVE=false
DRY_RUN=false

for arg in "$@"; do
  case "$arg" in
    --yes|-y) AUTO_YES=true ;;
    --move-current) AUTO_MOVE=true; AUTO_YES=true ;;
    --dry-run) DRY_RUN=true ;;
    --help|-h) printf "Usage: %s [--yes] [--move-current] [--dry-run]\n" "$0"; exit 0 ;;
    *) ;;
  esac
done

# ---------------------------
# small prompt helpers
# ---------------------------
_confirm() {
  # _confirm "Question" default_yes_or_no
  local prompt="${1:-Proceed?}"
  local default="${2:-no}"
  if [[ "$AUTO_YES" == "true" ]]; then
    return 0
  fi
  local reply
  if [[ "${default,,}" == "yes" || "${default,,}" == "y" ]]; then
    read -r -p "${prompt} [Y/n]: " reply
    reply="${reply:-y}"
  else
    read -r -p "${prompt} [y/N]: " reply
    reply="${reply:-n}"
  fi
  case "${reply,,}" in
    y|yes) return 0 ;;
    *) return 1 ;;
  esac
}

# ---------------------------
# Determine target user/home (handle sudo)
# ---------------------------
if [[ -n "${SUDO_USER:-}" && "${SUDO_USER}" != "root" ]]; then
  TARGET_USER="$SUDO_USER"
  TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
else
  TARGET_USER="${USER:-$(id -un)}"
  TARGET_HOME="${HOME:-$(getent passwd "$TARGET_USER" | cut -d: -f6)}"
fi

if [[ -z "$TARGET_HOME" || -z "$TARGET_USER" ]]; then
  err "Failed to determine target user or home directory."
  exit 1
fi

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$TARGET_HOME/.local/bin"
WAYBAR_CONFIG_DIR="$TARGET_HOME/.config/waybar"
STYLES_DIR="$WAYBAR_CONFIG_DIR/styles"
CURRENT_SYMLINK="$WAYBAR_CONFIG_DIR/current"

FILES=(omarchy-waybar omarchy-waybar-list omarchy-waybar-current omarchy-waybar-set)

# ---------------------------
# Header
# ---------------------------
title
printf "%b\n" "${DIM}Installing for user:${RESET} ${BOLD}${TARGET_USER}${RESET} — home: ${BOLD}${TARGET_HOME}${RESET}"
printf "%b\n" "${DIM}Repository: ${REPO_DIR}${RESET}"
if [[ "$DRY_RUN" == "true" ]]; then
  warn "DRY RUN enabled — no filesystem changes will be made."
fi
printf "\n"

# ---------------------------
# Sanity checks
# ---------------------------
missing=()
for f in "${FILES[@]}"; do
  if [[ ! -f "$REPO_DIR/$f" ]]; then
    missing+=("$f")
  fi
done
if (( ${#missing[@]} > 0 )); then
  err "Missing files in repo: ${missing[*]}"
  err "Make sure you run this script from the repo root."
  exit 2
fi

# create bin dir (unless dry-run)
if [[ "$DRY_RUN" == "false" ]]; then
  mkdir -p "$BIN_DIR"
  chown --quiet "$TARGET_USER":"$TARGET_USER" "$BIN_DIR" 2>/dev/null || true
fi

ok "Will install helper scripts into ${BOLD}$BIN_DIR${RESET}"

# ---------------------------
# Copy files (or show plan in dry-run)
# ---------------------------
for f in "${FILES[@]}"; do
  src="$REPO_DIR/$f"
  dst="$BIN_DIR/$f"
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    warn "$dst already exists."
    if _confirm "Overwrite $dst?" "no"; then
      if [[ "$DRY_RUN" == "true" ]]; then
        info "[DRY] Would overwrite $dst with $src"
      else
        cp -f --preserve=mode,timestamps "$src" "$dst"
        ok "Overwrote $dst"
      fi
    else
      info "Skipping $dst"
      continue
    fi
  else
    if [[ "$DRY_RUN" == "true" ]]; then
      info "[DRY] Would install $dst from $src"
    else
      cp -f --preserve=mode,timestamps "$src" "$dst"
      ok "Installed $dst"
    fi
  fi

  if [[ "$DRY_RUN" == "false" ]]; then
    chmod +x "$dst"
    if [[ "$(id -un)" == "root" && "$TARGET_USER" != "root" ]]; then
      chown "$TARGET_USER":"$TARGET_USER" "$dst" 2>/dev/null || true
    fi
  fi
done

# quick verification (dry-run: just report)
installed_ok=true
for f in "${FILES[@]}"; do
  if [[ "$DRY_RUN" == "true" ]]; then
    info "[DRY] Would verify executable: $BIN_DIR/$f"
  else
    if [[ ! -x "$BIN_DIR/$f" ]]; then
      err "Failed to install or set executable: $BIN_DIR/$f"
      installed_ok=false
    fi
  fi
done
if [[ "$DRY_RUN" == "false" && "$installed_ok" != "true" ]]; then
  err "One or more files failed to install correctly. Aborting."
  exit 3
fi

if [[ "$DRY_RUN" == "false" ]]; then
  ok "All helper scripts installed and made executable."
else
  ok "[DRY] Installation phase completed (no changes made)."
fi

# ---------------------------
# Ask about styles folder (or dry-run)
# ---------------------------
printf "\n%b\n" "${CYAN}${BOLD}Waybar styles directory setup${RESET}"
printf "%b\n" "${DIM}Waybar themes will live in:${RESET} ${BOLD}$STYLES_DIR${RESET}"

if _confirm "Do you want me to create the styles folder now?" "yes"; then
  if [[ "$DRY_RUN" == "true" ]]; then
    info "[DRY] Would create directory: $STYLES_DIR"
  else
    mkdir -p "$STYLES_DIR"
    chown --quiet "$TARGET_USER":"$TARGET_USER" "$STYLES_DIR" 2>/dev/null || true
    ok "Created (or already existed): $STYLES_DIR"
  fi

  # Option to move current waybar contents
  if [[ -d "$WAYBAR_CONFIG_DIR" && "$(ls -A "$WAYBAR_CONFIG_DIR" 2>/dev/null || true)" != "" ]]; then
    printf "%b\n" "${DIM}Detected existing contents in ${BOLD}$WAYBAR_CONFIG_DIR${RESET}"
    if _confirm "Do you want to move existing $WAYBAR_CONFIG_DIR contents into $STYLES_DIR/default ?" "yes"; then
      DEFAULT_DIR="$STYLES_DIR/default"
      if [[ "$DRY_RUN" == "true" ]]; then
        info "[DRY] Would create: $DEFAULT_DIR"
      else
        mkdir -p "$DEFAULT_DIR"
      fi
      info "Preparing to move files into: $DEFAULT_DIR"
      # Build list of items to move (skip styles dir and default if present)
      to_move=()
      shopt -s dotglob nullglob
      for item in "$WAYBAR_CONFIG_DIR"/* "$WAYBAR_CONFIG_DIR"/.[!.]* "$WAYBAR_CONFIG_DIR"/..?*; do
        [[ -e "$item" ]] || continue
        if [[ "$(realpath -- "$item")" == "$(realpath -- "$STYLES_DIR")" ]] || [[ "$(realpath -- "$item")" == "$(realpath -- "$DEFAULT_DIR")" ]]; then
          continue
        fi
        to_move+=("$item")
      done
      shopt -u dotglob nullglob

      if (( ${#to_move[@]} == 0 )); then
        info "No items to move."
      else
        info "Items to move:"
        for p in "${to_move[@]}"; do
          printf "  %s\n" "$p"
        done

        if [[ "$DRY_RUN" == "true" ]]; then
          info "[DRY] Would move the above items into $DEFAULT_DIR"
        else
          info "Moving files..."
          for p in "${to_move[@]}"; do
            mv -v -- "$p" "$DEFAULT_DIR/" 2>/dev/null || cp -a -- "$p" "$DEFAULT_DIR/" 2>/dev/null || true
          done
          chown -R --quiet "$TARGET_USER":"$TARGET_USER" "$DEFAULT_DIR" 2>/dev/null || true
          ok "Moved existing waybar contents into $DEFAULT_DIR"
        fi
      fi

      # create/update current symlink inside waybar dir to point to default
      if [[ "$DRY_RUN" == "true" ]]; then
        info "[DRY] Would set symlink: $CURRENT_SYMLINK -> $DEFAULT_DIR"
      else
        mkdir -p "$WAYBAR_CONFIG_DIR"
        ln -sfn -- "$DEFAULT_DIR" "$CURRENT_SYMLINK"
        chown --quiet -h "$TARGET_USER":"$TARGET_USER" "$CURRENT_SYMLINK" 2>/dev/null || true
        ok "Set current symlink: $CURRENT_SYMLINK -> $DEFAULT_DIR"
      fi

      # Try to apply Default theme using installed setter (unless dry-run)
      SETTER_PATH="$BIN_DIR/omarchy-waybar-set"
      if [[ "$DRY_RUN" == "true" ]]; then
        info "[DRY] Would run: $SETTER_PATH Default"
      else
        if [[ -x "$SETTER_PATH" ]]; then
          info "Applying 'Default' theme using omarchy-waybar-set..."
          if [[ "$(id -un)" == "root" && "$TARGET_USER" != "root" ]]; then
            sudo -u "$TARGET_USER" -- "$SETTER_PATH" "Default" || warn "omarchy-waybar-set returned non-zero (non-fatal)."
          else
            "$SETTER_PATH" "Default" || warn "omarchy-waybar-set returned non-zero (non-fatal)."
          fi
          ok "'Default' applied (or attempted)."
        else
          warn "omarchy-waybar-set not found or not executable at $SETTER_PATH; skipping auto-apply."
        fi
      fi

    else
      info "Left current waybar contents untouched."
    fi
  else
    info "No existing waybar config contents found; nothing to move."
  fi

else
  info "Skipping creation of styles folder as requested."
fi

# ---------------------------
# Final friendly summary
# ---------------------------
printf "\n%b\n" "${GREEN}${BOLD}All done!${RESET}"
cat <<EOF

${BOLD}What next?${RESET}

1) Bind the launcher to a key in your Hyprland config. Example:
   ${YELLOW}bind = SUPER SHIFT, W, exec, ${BIN_DIR}/omarchy-waybar${RESET}

2) Add new Waybar themes by creating folders under:
   ${YELLOW}$STYLES_DIR/<theme-name>${RESET}
   Example: ${YELLOW}$STYLES_DIR/catppuccin${RESET}
   Each theme folder should contain the theme files (e.g. config.jsonc, style.css, scripts/, modules/).

   ${DIM}Important:${RESET} Avoid spaces in your theme folder names. Use lowercase letters, numbers and dashes/underscores
   (e.g. ${BOLD}my-theme${RESET}, ${BOLD}catppuccin${RESET}, ${BOLD}nord${RESET}).

3) To manually apply a theme:
   ${YELLOW}${BIN_DIR}/omarchy-waybar-set "<Pretty Name>"${RESET}
   Use the pretty name = folder name converted to title case (e.g. ${BOLD}catppuccin -> Catppuccin${RESET}).

4) List installed themes:
   ${YELLOW}${BIN_DIR}/omarchy-waybar-list${RESET}

If you used --dry-run, no changes were made. Rerun without --dry-run to perform the operations.

If you ever want a non-interactive installer or CI-friendly flags, rerun with:
  ${YELLOW}$0 --yes${RESET}
or auto-move current config into default style with:
  ${YELLOW}$0 --move-current${RESET}

EOF

ok "Installer finished — enjoy your Waybar themes! ${CYAN}✨${RESET}"

exit 0
