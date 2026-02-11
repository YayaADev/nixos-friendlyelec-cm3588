# modules/image/sd-image.nix
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: let
  uboot = pkgs.ubootCM3588NAS;
in {
  imports = [
    (modulesPath + "/installer/sd-card/sd-image.nix")
  ];

  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/installer/sd-card/sd-image.nix
  boot.growPartition = true;

  sdImage = {
    imageBaseName = lib.mkDefault "friendlyelec-cm3588-sd-image";
    compressImage = false;
    firmwarePartitionOffset = 16;
    firmwareSize = 1;
    populateFirmwareCommands = "";

    populateRootCommands = ''
      mkdir -p ./files/boot
      ${config.boot.loader.generic-extlinux-compatible.populateCmd} \
        -c ${config.system.build.toplevel} \
        -d ./files/boot
    '';

    postBuildCommands = ''
      echo "=== Mic92-style GPT image build ==="

      # =================================================================
      # FIX: Increase Image Buffer to 1GB
      # The original +1M was too small, causing the "No space left"
      # crash before the resize service could finish.
      # +1G ensures the system can boot and write logs safely.
      # =================================================================
      truncate -s +1G $img

      # ── Step 2: Write bootloader blobs to raw sectors ──
      dd if=${uboot}/idbloader.img of=$img seek=64    bs=512 conv=notrunc
      dd if=${uboot}/u-boot.itb    of=$img seek=16384 bs=512 conv=notrunc

      # ── Step 3: Calculate root partition size ──
      IMGSIZE=$(stat -c '%s' $img)
      IMGSECTORS=$((IMGSIZE / 512))
      ROOT_START=34816
      ROOT_SIZE=$((IMGSECTORS - ROOT_START - 34))

      echo "Image: $IMGSECTORS sectors, root: start=$ROOT_START size=$ROOT_SIZE"

      # ── Step 4: Write fresh GPT with sfdisk ──
      # NOTE: Type 0FC63DAF... is 'Linux Filesystem Data'.
      # The grow-partition service explicitly looks for this type.
      ${pkgs.util-linux}/bin/sfdisk --force --no-reread $img <<EOF
      label: gpt
      unit: sectors
      first-lba: 64
      start=64,        size=16320,       type=0FC63DAF-8483-4772-8E79-3D69D8477DE4, name="idbloader"
      start=16384,     size=16384,       type=0FC63DAF-8483-4772-8E79-3D69D8477DE4, name="uboot"
      start=$ROOT_START, size=$ROOT_SIZE, type=0FC63DAF-8483-4772-8E79-3D69D8477DE4, name="nixos", attrs="LegacyBIOSBootable"
      EOF

      # ── Step 5: Verify ──
      ${pkgs.util-linux}/bin/sfdisk --dump   $img
      ${pkgs.util-linux}/bin/sfdisk --verify $img
    '';
  };
}
