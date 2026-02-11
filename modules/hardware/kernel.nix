{pkgs, ...}: {
  boot.kernelPackages = pkgs.linuxPackagesFor (
    pkgs.callPackage ../../pkgs/kernel/vendor.nix {
      kernelDefconfig = "nanopi6_linux_defconfig";
    }
  );
}
