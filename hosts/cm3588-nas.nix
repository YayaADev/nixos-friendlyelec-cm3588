{
  imports = [
    ../modules/hardware/kernel.nix
    ../modules/hardware/board.nix
    ../modules/image/sd-image.nix
    ../configuration.nix
  ];

  networking.hostName = "cm3588-nas";
  sdImage.imageBaseName = "cm3588-nas-sd-image";
}
