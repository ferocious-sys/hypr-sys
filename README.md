# hypr-sys

Small, composable Hyprland dotfiles for a Wayland desktop. Start with the quick setup, then copy only the pieces you want. The color picker and song recognition work as standalone additions to an existing Hyprland and Quickshell setup.

## Credits

This configuration is based on [end-4's Hyprland dotfiles](https://github.com/end-4/dots-hyprland) and the Illogical Impulse setup. This repository is a small, personal derivative containing selected customizations and portable feature snippets. Credit and thanks to end-4 and the upstream contributors.

## Features

- **Color picker** — `Super` + `Shift` + `C` samples a pixel with `hyprpicker` and copies its hex value to the clipboard.
- **Song recognition** — Quickshell can listen to the default output monitor or microphone through SongRec, then show the recognized track.
- **Workspace bend animation** — an optional Lua hook that briefly bends a custom shader after rapid workspace switching.

## Completely new? Use the quick installer

This one-command setup adds the hypr-sys features to an existing Arch Linux desktop with Hyprland and end-4's Illogical Impulse Quickshell config. It does not install a complete desktop from a fresh operating system. If you have not set up Hyprland yet, follow the [end-4 setup guide](https://end-4.github.io/dots-hyprland-wiki/en/) first.

Clone this repo and run the installer:

```sh
git clone https://github.com/ferocious-sys/hypr-sys.git
cd hypr-sys
./install.sh
```

The installer checks for the end-4 configuration, offers to install missing Arch packages, installs Quickshell with `paru` or `yay` when available, and backs up files before replacing them. It installs the color picker binding, song recognition helper, and workspace animation files. Restart Hyprland and Quickshell after setup.

The script supports Arch Linux. It uses `sudo` for system packages and needs an AUR helper if Quickshell is missing. Review [`install.sh`](install.sh) before running it.

### Manual setup

Install `hyprpicker`, `songrec`, `jq`, `pipewire-pulse`, and `wl-clipboard` with your package manager. Install Quickshell separately if needed. Add the color picker binding from [`hypr/custom/color-picker.lua`](hypr/custom/color-picker.lua) to a Lua config loaded by Hyprland.

Copy [`quickshell/musicRecognition/recognize-music.sh`](quickshell/musicRecognition/recognize-music.sh) to `~/.config/quickshell/ii/scripts/musicRecognition/recognize-music.sh` and make it executable. The end-4 music recognition service calls it with `-s monitor` or `-s input`.

Copy [`hypr/custom/workspace-bend.lua`](hypr/custom/workspace-bend.lua) and the shaders in [`hypr/custom/shaders/`](hypr/custom/shaders/) to their matching paths under `~/.config/hypr/custom/`.

## Build dependencies from source

The dotfiles themselves do not need compilation. These steps build the upstream tools used by the snippets. Package manager installation is usually simpler.

### Build SongRec on Arch Linux

Install Rust and SongRec's Linux build dependencies:

```sh
sudo pacman -S --needed base-devel cargo rust pkgconf blueprint-compiler git \\
  gtk4 libadwaita libsoup3 alsa-lib libpulse libpipewire clang openssl \\
  ffmpeg gettext sed grep
```

Build the upstream application in release mode with microphone, PipeWire, and PulseAudio support:

```sh
git clone https://github.com/marin-m/songrec.git
cd songrec
cargo build --release --no-default-features -F gui,ffmpeg,pulse,pipewire,mpris
```

The command-line executable is `target/release/songrec`. Put it somewhere on your `PATH`, then confirm `songrec --help` works. Song recognition sends audio fingerprints to Shazam for matching. See the [SongRec project documentation](https://github.com/marin-m/SongRec#privacy) for details.

### Build Quickshell from source

Quickshell uses CMake and Ninja and links against private Qt APIs, so build it against the Qt version installed on your system. Install the dependencies listed in the [upstream build guide](https://github.com/quickshell-mirror/quickshell/blob/master/BUILD.md), then run:

```sh
git clone https://github.com/quickshell-mirror/quickshell.git
cd quickshell
cmake -GNinja -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build
sudo cmake --install build
```

The full dependency list and optional feature flags are maintained in Quickshell's [BUILD.md](https://github.com/quickshell-mirror/quickshell/blob/master/BUILD.md). If you install new Qt libraries or update Qt, rebuild Quickshell against that Qt version.

### Build hyprpicker from source

The upstream project provides current source and build instructions in its [README](https://github.com/hyprwm/hyprpicker). On Arch Linux, installing the packaged version is:

```sh
sudo pacman -S hyprpicker
```

## Script usage

```sh
./quickshell/musicRecognition/recognize-music.sh -s monitor
./quickshell/musicRecognition/recognize-music.sh -s input
```

The script listens for up to 30 seconds by default, checking every 2 seconds. Change those defaults with `-t SECONDS` and `-i SECONDS`.

## Requirements

- A running Hyprland session for the key binding and workspace animation.
- Quickshell for integration with its music recognition toggle.
- `hyprpicker` and a Wayland clipboard tool for color sampling.
- `songrec`, `pactl`, `jq`, and Bash for song recognition.

## Contributing

Issues and pull requests are welcome. Please include your distro, Hyprland version, and relevant command output when reporting setup problems. Avoid posting logs that contain personal paths, hostnames, or other private details.

## License

This repository is distributed under the GNU General Public License v3.0, following its end-4 dotfiles base. See [LICENSE](LICENSE). Third-party tools such as SongRec, Quickshell, and Hyprpicker retain their own licenses.
