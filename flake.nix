{
  description = "My Neon Zombie NixOS Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";


    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      # --- Stage 1: Define basic variables ---
      username = "zombie";
      system = "x86_64-linux";
      lib = nixpkgs.lib;

      # --- Stage 2: Restructured Theme Logic ---
      availableThemes = lib.attrNames (builtins.readDir ./theming);
      currentThemeName =
        let
          themeFilePath = "/home/${username}/.config/current-theme";
        in
          if builtins.pathExists themeFilePath
          then builtins.readFile themeFilePath
          else "green";

      activeThemeName =
        if lib.elem currentThemeName availableThemes
        then currentThemeName
        else "green";

      # --- Stage 3: Define active theme assets ---
      activeThemePath = ./theming + "/${activeThemeName}";
      activePalette = import (activeThemePath + "/palette.nix");
      activeWallpaper = activeThemePath + "/wallpaper.png"; # Updated to png
      activeIcon = activeThemePath + "/icon.png";

    in
    {
      nixosConfigurations = {
        laptop = lib.nixosSystem {
          inherit system;

          specialArgs = {
            palette = activePalette;
            wallpaper = activeWallpaper;
            icon = activeIcon;
            inherit username;
            inherit lib;
          };

          modules = [
            ./nixos/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./home/home.nix;

              home-manager.extraSpecialArgs = {
                palette = activePalette;
                wallpaper = activeWallpaper;
                icon = activeIcon;
                inherit username;
              };
            }
          ];
        };
      };
    };
}
