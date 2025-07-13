# zZz

"Neon zombie" theme for NixOs. Consider it a darker version of dracula theme.
# ZZZ Flake Guide

Welcome to **ZZZ** – a NixOS flake that applies a "neon-horrified" twist on the traditional Dracula theme. If you enjoy deep purples and vibrant highlights but want something even darker and more intense, this flake is for you.

## Features

* Dracula-inspired colors taken to the extreme
* Flexible theming with switchable palettes
* Works with the `nixos-theme-switcher.nix` script

## Installation

1. Make sure you have [NixOS](https://nixos.org/) with flakes enabled.
2. Clone the repository:

   ```bash
   git clone https://github.com/prionindustries/zzz.git zzz
   cd zzz
   ```
3. Switch to the configuration:

   ```bash
   sudo nixos-rebuild switch --flake .#laptop
   ```

The flake expects the current user to be `zombie` and will read a theme name from `~/.config/current-theme`. By default, the active theme is `green`. Use the provided `nixos-theme-switcher.nix` script to switch themes interactively.

## Usage

Run the theme switcher and rebuild to apply your chosen palette:

```bash
./nixos-theme-switcher.nix
```

Pick the desired theme, wait for the rebuild, and enjoy the neon-horrified look.

