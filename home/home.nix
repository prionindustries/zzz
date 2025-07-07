# /etc/nixos/home/home.nix
{ config, pkgs, palette, username, ... }:

let
  c = color: "#${color}";
in
{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.05"; # Set to your NixOS version

  home.packages = with pkgs; [
    # Core desktop
    swww waybar alacritty wofi libnotify nixos-rebuild thunar

    # Theming packages
    qt6ct kvantum (catppuccin-gtk.override { accents = ["green"]; })
    adwaita-icon-theme
  ];

  # --- Theme Switcher Script ---
  home.file.".local/bin/theme-switcher" = {
    executable = true;
    source = ../nixos-theme-switcher-script.nix;
  };

  # --- Correct Hyprland Configuration for Home Manager ---
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mainMod" = "SUPER";
      # ... other binds ...
      bind = [
        "$mainMod, Q, exec, alacritty"
        "$mainMod, C, killactive,"
        "$mainMod, M, exit,"
        "$mainMod, E, exec, thunar"
        "$mainMod, R, exec, wofi --show drun"
      ];

      # Startup programs
      exec-once = [
        "waybar"
        "swww init"
        "swww img ${palette.wallpaper}"
      ];

      # Theming
      general = {
        "col.active_border" = "rgb(${palette.primary}) rgb(${palette.cyan}) 45deg";
        "col.inactive_border" = "rgb(${palette.bg})";
        "layout" = "dwindle";
      };
    };
    # Set environment variables for Qt theming
    extraConfig = ''
      env = QT_QPA_PLATFORMTHEME,qt6ct
      env = QT_STYLE_OVERRIDE,kvantum
    '';
  };

  # --- Application Theming ---
  programs.alacritty = {
    enable = true;
    settings.colors = {
      primary = { background = c palette.bg; foreground = c palette.fg; };
      normal = {
        black = c palette.bg; red = c palette.red; green = c palette.green;
        yellow = c palette.yellow; blue = c palette.blue; magenta = c palette.pink;
        cyan = c palette.cyan; white = c palette.fg;
      };
    };
  };

  programs.waybar = {
    enable = true;
    style = ''
      * { font-family: "JetBrainsMono Nerd Font"; }
      window#waybar { background-color: ${c palette.bg}; color: ${c palette.fg}; }
      #workspaces button.active { color: ${c palette.primary}; }
      #custom-theme { padding: 0 10px; }
    '';
    settings."custom/theme" = {
      format = "<img src='{}' height='24'/>";
      exec = "echo ${palette.icon}";
      on-click = "~/.local/bin/theme-switcher";
      tooltip = true;
      tooltip-format = "Current theme: {exec_once}";
      exec_once = "cat ~/.config/current-theme";
    };
  };

  # --- GTK & Qt Theming ---
  gtk = {
    enable = true;
    theme.name = "Catppuccin-Mocha-Standard-Green-Dark";
    iconTheme.name = "Adwaita";
  };
  qt = {
    enable = true;
    platformTheme = "qt6ct";
    # --- THIS IS THE FIX ---
    # The 'style' option needs to be an attribute set.
    style = {
      name = "kvantum";
      package = pkgs.kvantum;
    };
  };

  programs.home-manager.enable = true;
}
