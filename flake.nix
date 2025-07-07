# /etc/nixos/flake.nix
{
  description = "My Neon Zombie NixOS Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
       zzz = {
      url = "git+https://gitlab.com/nixos1213727/zZz.git";
      #	url = "git+ssh://git@gitlab.com/nixos1213727/zZz.git";

      # --- THIS IS THE FIX ---
      # Tell this flake to use the same nixpkgs as the main flake,
      # which prevents a circular dependency.
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      # --- Basic variables ---
      username = "zombie";
      system = "x86_64-linux";
      lib = nixpkgs.lib;

      # --- Theme Logic (Updated for new structure) ---
      # Path to the directory containing theme folders
      themesPath = ./theming/themes;

      # Get a list of available themes from the directory names
      availableThemes = lib.attrNames (builtins.readDir themesPath);

      # Read the desired theme name from the user's config file
      currentThemeName =
        let
          themeFilePath = "/home/${username}/.config/current-theme";
        in
          if builtins.pathExists themeFilePath
          then builtins.readFile themeFilePath
          else "zombie_cyan"; # Default theme

      # Determine the active theme, falling back to the default
      activeThemeName =
        if lib.elem currentThemeName availableThemes
        then currentThemeName
        else "zombie_cyan";

      # --- Active Palette ---
      # Import the active palette file directly
      activePalette = import (themesPath + "/${activeThemeName}/palette.nix");

    in
    {
      nixosConfigurations = {
        laptop = lib.nixosSystem {
          inherit system;

          specialArgs = {
            # Pass the entire palette object down
            palette = activePalette;
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
                # Pass the palette to home-manager as well
                palette = activePalette;
                inherit username;
              };
            }
          ];
        };
      };
    };
}
