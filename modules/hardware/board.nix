{
  lib,
  pkgs,
  ...
}: {
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  boot = {
    supportedFilesystems = lib.mkForce [
      "vfat"
      "fat32"
      "exfat"
      "ext4"
      "btrfs"
    ];

    growPartition = true;

    initrd.includeDefaultModules = lib.mkForce false;

    initrd.availableKernelModules = lib.mkForce [
      # NVMe
      "nvme"

      # SD cards and internal eMMC drives.
      "mmc_block"

      # Support USB keyboards, in case the boot fails and we only have
      # a USB keyboard, or for LUKS passphrase prompt.
      "hid"

      # For LUKS encrypted root partition.
      # (https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/system/boot/luksroot.nix)
      "dm_mod" # for LVM & LUKS
      "dm_crypt" # for LUKS
      "input_leds"
    ];

    loader.generic-extlinux-compatible.enable = true;
    loader.grub.enable = false;

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
  };

  hardware = {
    deviceTree.name = "rockchip/rk3588-nanopi6-rev01.dtb";
    firmware = [
      (pkgs.callPackage ../../pkgs/firmware/friendlyelec.nix {})
      (pkgs.callPackage ../../pkgs/firmware/mali.nix {})
    ];
    enableRedistributableFirmware = lib.mkForce true;
  };

  nixpkgs.config.allowUnfree = true;
}
