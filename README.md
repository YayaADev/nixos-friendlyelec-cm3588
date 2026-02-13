# nixos-friendlyelec-cm3588

NixOS image builder for the **FriendlyElec CM3588 NAS (RK3588)**.

Builds a bootable SD card / eMMC image via cross-compilation from an x86_64 machine.

---

## Prerequisites

- Any Linux machine with [Nix installed](https://nixos.org/download/) and flakes enabled
- An SD card and a way to write to it
- Your SSH public key (`~/.ssh/id_ed25519.pub` or similar)

---

## Quick start

### 1. Clone the repo

```sh
git clone git@github.com:YayaADev/nixos-friendlyelec-cm3588.git
cd nixos-friendlyelec-cm3588
```

### 2. Edit `configuration.nix`

Open `configuration.nix` and make two changes:

**Add your SSH public key** (required — password auth is disabled):

```nix
sshKeys = [
  "ssh-ed25519 AAAA... you@yourhost"
];
```

**Optionally change the username** (defaults to `nixos`):

```nix
username = "nixos"; # change to whatever you like
```

> The build will fail if `sshKeys` is left empty — this is intentional to prevent
> you from being locked out of the device.

### 3. Update flake inputs

```sh
nix flake update
```

### 4. Build the image

```sh
nix build
```

This cross-compiles for `aarch64`. The output image will be at:

```
result/sd-image/sd-image.img
```

### 5. Flash to SD card

Find your SD card device (e.g. with `lsblk`), then:

```sh
sudo dd if=result/sd-image/sd-image.img of=/dev/sdX bs=4M status=progress conv=fsync
```

Replace `/dev/sdX` with your actual SD card device.

> **This will erase all data on the target device. Double-check the device path.**

---

## Booting

Insert the SD card into your CM3588 NAS and power it on. Once booted, SSH in using the username and key you configured:

```sh
ssh nixos@<board-ip>
```

---

## Repository layout

```
.
├── configuration.nix         # Start here — username & SSH keys
├── flake.nix                 # Flake outputs
├── hosts/
│   └── cm3588-nas.nix        # Host-level NixOS configuration
├── modules/
│   └── sd-image.nix          # GPT image logic
└── pkgs/
    ├── kernel/               # Vendor RK3588 kernel
    ├── u-boot/               # Prebuilt U-Boot blobs
    └── firmware/             # FriendlyElec + Mali firmware
```

---

## Notes

- Bootloader: [`ubootCM3588NAS`](https://search.nixos.org/packages?channel=25.11&query=cm3588&show=ubootCM3588NAS) from nixpkgs
- Kernel: Vendor RK3588 kernel with device tree `rk3588-nanopi6-rev09.dtb`
- Boot method: extlinux (no GRUB, no EFI)
- The image works for both SD cards and eMMC flashing

---

## License

MIT
