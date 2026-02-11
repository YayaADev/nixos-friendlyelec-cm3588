{
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./base.nix
  ];

  boot = {
    loader.generic-extlinux-compatible.enable = true;
    loader.grub.enable = false;

    kernelPackages = pkgs.linuxPackagesFor (
      pkgs.callPackage ../pkgs/kernel/vendor.nix {
        kernelDefconfig = "nanopi6_linux_defconfig";
      }
    );

    kernelParams = [
      "rootwait"
      "earlycon"
      "consoleblank=0"
      "console=ttyS2,1500000"
      "console=tty1"
      "cgroup_enable=cpuset"
      "cgroup_memory=1"
      "cgroup_enable=memory"
      "swapaccount=1"
    ];

    initrd.availableKernelModules = [
      "nvme"
      "mmc_block"
      "dm_mod"
    ];
  };

  hardware = {
    deviceTree = {
      name = "rockchip/rk3588-nanopi6-rev01.dtb";
      overlays = [];
    };

    firmware = [
      (pkgs.callPackage ../pkgs/firmware/friendlyelec.nix {})
      (pkgs.callPackage ../pkgs/firmware/mali.nix {})
    ];

    enableRedistributableFirmware = true;
  };

  nixpkgs.config.allowUnfree = true;

  # Hardcode boardName
  nixos-rk3588.board.name = "friendlyelec-cm3588-nas";
}
