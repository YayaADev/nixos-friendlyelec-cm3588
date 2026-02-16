# nixos-friendlyelec-cm3588

NixOS image builder for the FriendlyElec CM3588 board.

Builds a bootable SD / eMMC image via cross-compilation from x86_64, with full hardware support including:

- FriendlyElec vendor kernel 6.1.141 (latest as of writing)
- Hardware video transcoding (RKMPP)
- NPU acceleration RKNN v0.9.8 (latest as of writing)
- RGA 2D acceleration
- Mali G610 GPU support
- 4x NVMe PCIe Gen3, 2.5GbE, eMMC, HDMI

## Quick Start

### 1. Clone and configure

```bash
git clone https://github.com/YayaADev/nixos-friendlyelec-cm3588
cd nixos-friendlyelec-cm3588
```

Before building, open `configuration.nix` and make these changes:

**Required — add your SSH public key** (the build will fail without this):
```nix
sshKeys = [
  "ssh-ed25519 AAAA... you@host"
];
```

**Optional:**
- Change the username (default: `nixos`)
- Add or remove system packages under `environment.systemPackages`

### 2. Build

```bash
nix build
```

Cross-compiles on x86_64 → aarch64. Output: `./result/sd-image/friendlyelec-cm3588-sd-image.img`

> If you have [direnv](https://direnv.net) installed, `direnv allow` will auto-load the Nix dev shell. It is not required — `nix build` works without it.

### 3. Flash to SD card

> **Warning:** This will destroy all data on the target device.

```bash
sudo dd if=result/sd-image/friendlyelec-cm3588-sd-image.img of=/dev/sdX bs=4M status=progress conv=fsync
```

Replace `/dev/sdX` with your SD card (check with `lsblk`). Insert into the CM3588 and power on.

### SSH in

Password authentication is disabled. Log in with your SSH key:

```bash
ssh nixos@<board-ip>
```

Replace `nixos` with whatever username you set in `configuration.nix`.

---

## Flash to eMMC

Boot from the SD card first, then copy to eMMC from within the board:

```bash
# Identify devices — SD is usually mmcblk1, eMMC is mmcblk0
lsblk

# Copy SD image to eMMC
sudo dd if=/dev/mmcblk1 of=/dev/mmcblk0 bs=16M status=progress conv=fsync

# Resize the root partition to fill the eMMC
sudo e2fsck -f /dev/mmcblk0p3
sudo resize2fs /dev/mmcblk0p3

# Power off, remove SD card, power back on
sudo poweroff
```


---

## Repository Layout

```
.
├── flake.nix                    # Flake outputs, cross-compilation setup
├── configuration.nix            # Edit this: SSH keys, username, packages
├── hosts/
│   └── cm3588-nas.nix           # Host entry point, imports all modules
├── modules/
│   ├── hardware/
│   │   ├── board.nix            # DTB, firmware, boot params
│   │   └── kernel.nix           # Loads vendor kernel
│   └── image/
│       └── sd-image.nix         # GPT image builder
└── pkgs/
    ├── kernel/vendor.nix        # FriendlyArm kernel 6.1.141
    ├── u-boot/                  # Prebuilt bootloader blobs
    └── firmware/                # FriendlyElec + Mali firmware
```

---

## Use as a Flake Module

To use the board support in your own NixOS config:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    friendlyelecCM3588 = {
      url = "github:YayaADev/nixos-friendlyelec-cm3588";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, friendlyelecCM3588 }: {
    nixosConfigurations.my-cm3588 = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        friendlyelecCM3588.nixosModules.cm3588  # board + kernel support
        ({ ... }: {
          networking.hostName = "cm3588-nas";
          # your config here
        })
      ];
    };
  };
}
```

---

## Comparison

| Project | Kernel | CM3588 Support | Status |
|---|---|---|---|
| **This repo** | FriendlyElec BSP 6.1 | ✅ Native | ✅ Active |
| [nixos-aarch64-images](https://github.com/Mic92/nixos-aarch64-images) | Mainline | ⚠️ No built-in CM3588 support | ⚠️ Missing HW acceleration |
| [ryan4yin/nixos-rk3588](https://github.com/ryan4yin/nixos-rk3588) | Armbian fork | ⚠️ Generic RK3588 | ❌ Archived |
| [gnull/nixos-rk3588](https://github.com/gnull/nixos-rk3588) | Armbian fork | ⚠️ Generic RK3588 | ⚠️ Doesnt support this board |

---

## Tested Hardware

Tested and actively used on a FriendlyElec CM3588+ NAS Kit (32GB RAM, 64GB eMMC).

## Acknowledgments

- [gnull/nixos-rk3588](https://github.com/gnull/nixos-rk3588) — build system foundation
- [ryan4yin/nixos-rk3588](https://github.com/ryan4yin/nixos-rk3588) — original RK3588 NixOS work
- [Mic92/nixos-aarch64-images](https://github.com/Mic92/nixos-aarch64-images) — image building approach
- FriendlyElec — hardware and BSP kernel

## License

MIT — see [LICENSE](LICENSE)
