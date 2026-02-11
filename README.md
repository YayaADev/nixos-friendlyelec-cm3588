# nixos-friendlyelec-cm3588

NixOS image builder for **FriendlyElec CM3588 / NanoPi 6 (RK3588)** boards.

This repository provides a  way to build **bootable SD / eMMC images** for the friendlyelec cm3588 nas board on **NixOS**, with support for:


* Cross-compilation builds on x86_64
* Vendor kernel + device tree

---

## What this repo builds

The output is a **raw disk image** with:

* GPT partition table
* Raw bootloader written to fixed sectors
* ext4 root filesystem containing NixOS
* extlinux bootloader (no GRUB)

The image is suitable for:

* SD cards
* eMMC flashing
* `dd`-style deployment

---

## Supported build modes


### 1. Cross build (x86_64 → aarch64)

Use this on typical development machines (x86_64 laptops / servers).

```sh
nix build
```



## Flashing the image

 **This will destroy data on the target device**

```sh
sudo dd if=result/sd-image/sd-image.img of=/dev/sdX bs=4M status=progress conv=fsync
```

Replace `/dev/sdX` with your SD card or eMMC device.

---

## Repository layout

```
.
├── flake.nix                 # Flake outputs (native + cross builds)
├── hosts/
│   └── cm3588-nas.nix        # Main NixOS host configuration
├── modules/
│   └── sd-image.nix          # Custom Mic92-style GPT image logic
├── pkgs/
│   ├── kernel/               # Vendor kernel packaging
│   ├── u-boot/               # Prebuilt U-Boot blobs
│   └── firmware/             # FriendlyElec + Mali firmware
└── README.md
```

---

## Bootloader & kernel

* **Bootloader**: U-Boot (FriendlyElec-compatible)
* **Kernel**: Vendor RK3588 kernel
* **DTB**: `rockchip/rk3588-nanopi6-rev01.dtb`
* **Boot method**: extlinux

---

## Notes

* GRUB is intentionally disabled
* EFI is not used
* This repo targets RK3588 specifically

---

## Status

This project is functional but still evolving.

