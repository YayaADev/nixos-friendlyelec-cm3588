{
  description = "NixOS for FriendlyELEC CM3588 NAS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    nixosConfigurations.cm3588-nas = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        ./configuration.nix
        ./modules/board.nix
        ({ pkgs, ... }: {
          nixpkgs.overlays = [
            (final: prev: {
              uboot = prev.callPackage ./pkgs/u-boot/default.nix {};
            })
          ];
        })
      ];
    };

    packages.aarch64-linux.sdImage = self.nixosConfigurations.cm3588-nas.config.system.build.sdImage;
  };
}
