{
  description = "NixOS SD image and Config for FriendlyELEC CM3588 NAS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: {
    # 1. Native Configuration (For use ON the CM3588)
    nixosConfigurations.cm3588 = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        ./hosts/cm3588-nas.nix
        # It defaults to the system defined above (aarch64), which is native.
      ];
    };

    packages.x86_64-linux = let
      crossConfig = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ./hosts/cm3588-nas.nix
          {
            # This forces the build to happen on x86, targeting ARM
            nixpkgs.buildPlatform = "x86_64-linux";
            nixpkgs.hostPlatform = "aarch64-linux";
          }
        ];
      };
    in {
      sdImage = crossConfig.config.system.build.sdImage;
      default = crossConfig.config.system.build.sdImage;
    };
  };
}
