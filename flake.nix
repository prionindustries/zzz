# /etc/nixos/flake.nix
{
  description = "My Neon Zombie NixOS Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # --- Re-enabled with the correct GitHub SSH URL ---
    # This is the standard way to access private repositories.
    zzz = {
      url = "git+ssh://git@github.com/prionindustries/zzz.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      # --- Basic variables ---
      username = "zombie";
      system = "x86_64-linux";
      lib = nixpkgs.lib;

      # --- Theme Logic ---
      themesPath = ./theming/themes;
      availableThemes = lib.attrNames (builtins.readDir themesPath);
      currentThemeName =
        let
          themeFilePath = "/home/${username}/.config/current-theme";
        in
          if builtins.pathExists themeFilePath
          then builtins.readFile themeFilePath
          else "zombie_cyan"; # Default theme
      activeThemeName =
        if lib.elem currentThemeName availableThemes
        then currentThemeName
        else "zombie_cyan";
      activePalette = import (themesPath + "/${activeThemeName}/palette.nix");

    in
    {
      nixosConfigurations = {
        laptop = lib.nixosSystem {
          inherit system;

          specialArgs = {
            palette = activePalette;
            inherit username;
            # Pass all inputs down, including the now-active 'zzz'
            inherit inputs;
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
                inherit username;
              };
            }
          ];
        };
      };
    };
}
