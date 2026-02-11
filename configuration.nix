{
  lib,
  pkgs,
  ...
}: let
  username = "nixos";
  hashedPassword = "$y$j9T$V7M5HzQFBIdfNzVltUxFj/$THE5w.7V7rocWFm06Oh8eFkAKkUFb5u6HVZvXyjekK6";
in {
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
  };

  environment.systemPackages = with pkgs; [
    git curl neofetch lm_sensors btop
    mtdutils i2c-tools minicom
  ];

  # Enable SSH
  services.openssh = {
    enable = lib.mkDefault true;
    settings = {
      X11Forwarding = lib.mkDefault true;
      PasswordAuthentication = lib.mkDefault false;   # disable password auth
      PermitRootLogin = lib.mkDefault "no";           # disable root login
    };
    openFirewall = lib.mkDefault true;
  };

  # Primary user (as before)
  users.users."${username}" = {
    inherit hashedPassword;
    isNormalUser = true;
    home = "/home/${username}";
    extraGroups = ["users" "wheel"];
  };

  # Add your own SSH public key *instead of* leaving PasswordAuthentication on
  users.users.youruser = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" ];
    openssh.authorizedKeys.keys = [
      # paste your full public SSH key here
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHLUrFC69L74u5KdfkHJpkXd7v8uk4MOVLNzjwqlK2Pa pop-os-pc"
    ];
  };

  # Allow wheel group sudo without password
  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;

  # Keep the defined state version
  system.stateVersion = "26.05";
}
