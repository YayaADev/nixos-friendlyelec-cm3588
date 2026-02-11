{
  fetchFromGitHub,
  stdenvNoCC,
  lib,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "friendlyelec-firmware";
  version = "2024.02.08";

  dontBuild = true;
  dontFixup = true;
  compressFirmware = false;

  src = fetchFromGitHub {
    owner = "friendlyarm";
    repo = "kernel-rockchip";
    rev = "524e3e035d50fcc8a623cf8e487cfb35d7272ffa";
    hash = "sha256-ihACbK4TkO/frqPnfX6mOu07i/NzH5lgFllkQi8PgUI=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/firmware
    cp -a firmware/* $out/lib/firmware/ 2>/dev/null || true

    runHook postInstall
  '';

  meta = {
    description = "Firmware files for FriendlyElec CM3588 NAS (RK3588)";
    platforms = ["aarch64-linux"];
    license = lib.licenses.unfreeRedistributableFirmware;
  };
}
