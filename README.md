# Hyprland configuration snippets

A small, portable set of Hyprland and Quickshell configuration pieces. The files avoid machine-specific monitor names, home directory paths, wallpaper choices, and account identifiers.

## Included features

- **Pick a color:** `hypr/custom/color-picker.lua` binds `Super+Shift+C` to `hyprpicker -a`, which copies the selected color to the clipboard. Install `hyprpicker` and `wl-clipboard`.
- **Recognize music:** `quickshell/musicRecognition/recognize-music.sh` listens through `songrec` and PipeWire/PulseAudio. Install `songrec`, `pipewire-pulse` (or PulseAudio), `jq`, and `bash`. Quickshell can call it with `-s monitor` to recognize desktop audio or `-s input` to recognize microphone input. The script chooses the default audio device automatically.
- **Workspace animation:** `hypr/custom/workspace-bend.lua` is an optional workspace switch effect. Its shader path uses the `HOME` environment variable and expects matching shader files under `~/.config/hypr/custom/shaders/`.

## Setup

Copy the color picker binding into your Hyprland Lua configuration and ensure `hyprpicker` is installed. Make the music recognition script executable, then connect it to your Quickshell music recognition service or toggle. This repository does not include the Quickshell framework itself.

Review key bindings for conflicts before adding them to an existing configuration.
