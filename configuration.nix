# ==============================================================================
#  NixOS Configuration — FriendlyELEC CM3588 NAS
# ==============================================================================
#
# This file is the primary place to customise your installation.
#
{
  lib,
  pkgs,
  ...
}: let
  username = "nixos"; # CHANGE ME
  sshKeys = [
    # CHANGE ME
  ];
in {
  # ── Nix daemon
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
  };

  # ── System packages, add any u see fit
  environment.systemPackages = with pkgs; [
    git
    curl
    lm_sensors
    btop
    mtdutils
    i2c-tools
    minicom
  ];

  # ── SSH
  services.openssh = {
    enable = lib.mkDefault true;
    openFirewall = lib.mkDefault true;
    settings = {
      PasswordAuthentication = lib.mkDefault false;
      PermitRootLogin = lib.mkDefault "no";
    };
  };

  # ── User account
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    openssh.authorizedKeys.keys = sshKeys;
  };

  # ── Sudo
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  # See: https://nixos.org/manual/nixos/stable/options.html#opt-system.stateVersion
  system.stateVersion = "26.05";

  assertions = [
    {
      assertion = sshKeys != [];
      message = ''
        No SSH public keys configured.
        This image disables password authentication — you will be locked out.
        Add at least one SSH key to configuration.nix.
      '';
    }
  ];
}
