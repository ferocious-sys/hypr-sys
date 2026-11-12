#!/usr/bin/env bash
set -Eeuo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
HYPR_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/hypr"
QS_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/ii"
KEYBINDS="$HYPR_CONFIG/custom/keybinds.lua"
STAMP="$(date +%Y%m%d-%H%M%S)"

say() { printf '\n==> %s\n' "$*"; }
fail() { printf 'Error: %s\n' "$*" >&2; exit 1; }

[[ -r /etc/arch-release ]] || fail "This quick installer currently supports Arch Linux. See the README for manual setup."
[[ -d "$HYPR_CONFIG" ]] || fail "Hyprland config not found at $HYPR_CONFIG. Install and start Hyprland first."
[[ -d "$QS_CONFIG" ]] || fail "Quickshell Illogical Impulse config not found at $QS_CONFIG. Set up end-4's dots-hyprland first, then rerun this installer."

install_packages() {
    local -a missing=()
    local package
    for package in hyprpicker songrec jq pipewire-pulse wl-clipboard; do
        pacman -Q "$package" >/dev/null 2>&1 || missing+=("$package")
    done

    if ((${#missing[@]})); then
        printf 'Missing packages: %s\n' "${missing[*]}"
        read -r -p "Install them with pacman? [Y/n] " answer
        if [[ "$answer" =~ ^([nN]|[nN][oO])$ ]]; then
            fail "Install the listed packages and rerun this script."
        fi
        sudo pacman -S --needed "${missing[@]}"
    fi

    if ! command -v quickshell >/dev/null 2>&1; then
        if command -v paru >/dev/null 2>&1; then
            paru -S --needed quickshell
        elif command -v yay >/dev/null 2>&1; then
            yay -S --needed quickshell
        else
            fail "Quickshell is missing. Install it from the AUR with paru or yay, then rerun this script."
        fi
    fi
}

backup_if_present() {
    local path="$1"
    if [[ -e "$path" ]]; then
        cp -a -- "$path" "${path}.backup-${STAMP}"
        printf 'Backed up %s\n' "$path"
    fi
}

install_packages

say "Installing the song recognition helper"
mkdir -p "$QS_CONFIG/scripts/musicRecognition"
backup_if_present "$QS_CONFIG/scripts/musicRecognition/recognize-music.sh"
install -m 755 "$REPO_DIR/quickshell/musicRecognition/recognize-music.sh" \
    "$QS_CONFIG/scripts/musicRecognition/recognize-music.sh"

say "Installing Hyprland snippets"
mkdir -p "$HYPR_CONFIG/custom/shaders"
backup_if_present "$HYPR_CONFIG/custom/workspace-bend.lua"
install -m 644 "$REPO_DIR/hypr/custom/workspace-bend.lua" \
    "$HYPR_CONFIG/custom/workspace-bend.lua"
for shader in "$REPO_DIR"/hypr/custom/shaders/workspace-bend-*.frag; do
    install -m 644 "$shader" "$HYPR_CONFIG/custom/shaders/"
done

mkdir -p "$(dirname -- "$KEYBINDS")"
if [[ -e "$KEYBINDS" ]] && ! grep -Fq 'hypr-sys color picker' "$KEYBINDS"; then
    backup_if_present "$KEYBINDS"
fi
touch "$KEYBINDS"
if ! grep -Fq 'hypr-sys color picker' "$KEYBINDS"; then
    cat >> "$KEYBINDS" <<'LUA'

-- hypr-sys color picker
hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd("hyprpicker -a"),
    { description = "Utilities: Pick color #RRGGBB >> clipboard" })

-- hypr-sys workspace animation
require("custom.workspace-bend")
LUA
fi

say "Setup complete"
printf 'Color picker: Super + Shift + C\n'
printf 'Song recognition: available through the end-4 Quickshell music toggle.\n'
printf 'Workspace bend: enabled through custom.keybinds.lua.\n'
printf 'Restart Hyprland or reload its config, then restart Quickshell.\n'
