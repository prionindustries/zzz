# /etc/nixos/nixos/configuration.nix
{ config, lib, pkgs, username, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "quetzal";
  networking.networkmanager.enable = true;

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  programs.hyprland.enable = true;

  hardware.opengl.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ]; # Adjust if needed

  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session.command = "${pkgs.greetd.regreet}/bin/regreet --command Hyprland";
    };
  };

  # Allow passwordless sudo for the theme switcher script
  security.sudo.enable = true;
  security.sudo.extraRules = [{
    users = [ username ];
    commands = [{
      command = "${pkgs.nixos-rebuild}/bin/nixos-rebuild";
      options = [ "NOPASSWD" ];
    }];
  }];

  users.users.${username} = {
    isNormalUser = true;
    description = "Quetzalcoatl";
    extraGroups = [ "networkmanager" "wheel" "video" ];
  };

  environment.systemPackages = with pkgs; [ git vim wget firefox htop ];
  services.blueman.enable = true;
  services.tlp.enable = true;
  system.stateVersion = "25.05"; # Set to your NixOS version
}
