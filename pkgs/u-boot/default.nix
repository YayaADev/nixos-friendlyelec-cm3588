{stdenv}: let
  # Prebuilt binaries extracted from FriendlyELEC images
  uboot_img = ./linux-u-boot-legacy-cm3588/uboot.img;
  idbloader_img = ./linux-u-boot-legacy-cm3588/idbloader.img;
in
  stdenv.mkDerivation {
    pname = "u-boot-cm3588-prebuilt";
    version = "2017.09-nanopi6";

    # We install BOTH files so the SD image builder can access them
    buildCommand = ''
      install -Dm444 ${uboot_img} $out/uboot.img
      install -Dm444 ${idbloader_img} $out/idbloader.img
    '';
  }
