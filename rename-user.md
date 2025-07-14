# Renaming a User in NixOS

This guide explains how to rename your primary user account on a NixOS system.

1. **Edit `flake.nix` or your configuration**
   - In your flake or configuration, locate the variable that defines the user name. In this repository it is in `flake.nix`:
     ```nix
     username = "zombie"; # change this to the new name
     ```

2. **Update your Home Manager configuration**
   - Ensure that any modules referencing the old user are updated. For example, `home/home.nix` expects a `username` argument.

3. **Rebuild the system**
   - After updating the configuration, run:
     ```bash
     sudo nixos-rebuild switch --flake .#laptop
     ```
   - This command will create the new user, migrate services, and set up the home directory under `/home/<newname>`.

4. **Remove the old user**
   - Once you verify everything works, remove the old account:
     ```bash
     sudo userdel -r <oldname>
     ```
   - Be careful to back up any important files before deletion.

These steps rename your user by editing configuration and rebuilding the system. The new user will keep the same privileges defined in `configuration.nix`.
