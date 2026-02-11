{ lib
, buildLinux
, fetchFromGitHub
, ...
} @ args:

buildLinux (args // {
  version = "6.1.141";
  modDirVersion = "6.1.141";

  src = fetchFromGitHub {
      owner = "friendlyarm";
      repo = "kernel-rockchip";
      rev = "524e3e035d50fcc8a623cf8e487cfb35d7272ffa";
      hash = "sha256-ihACbK4TkO/frqPnfX6mOu07i/NzH5lgFllkQi8PgUI=";
    };
  defconfig = "nanopi6_linux_defconfig";
  
structuredExtraConfig = with lib.kernel; {
  # BTF disabled for cross
  DEBUG_INFO_BTF = lib.mkForce no;
  DEBUG_INFO_BTF_MODULES = lib.mkForce no;

  # GPU/Mali
  MALI_VALHALL = module;
  MALI_CSF_SUPPORT = yes;
  MALI_DEVFREQ = yes;
  MALI_DMA_BUF_MAP_ON_DEMAND = yes;
  MALI_CSF_INCLUDE_FW = lib.mkForce no;

  # DRM
  DRM = yes;
  DRM_KMS_HELPER = yes;               # support helper
  DRM_PANEL = yes;

  # Rockchip-specific
  DRM_ROCKCHIP = module;              # core
  ROCKCHIP_IOMMU = module;            # dependency of DRM_ROCKCHIP

  # Panels you want
  DRM_PANEL_SIMPLE = module;
  DRM_PANEL_RAYDIUM_RM67191 = module;

  # NPU
  ROCKCHIP_RKNPU = module;

  # Disable problematic wireless
  # You will get kernel failures with this enabled
  BT = lib.mkForce no;
  IWLWIFI = lib.mkForce no;
  RTW88 = lib.mkForce no;
  RTW89 = lib.mkForce no;
  WL_ROCKCHIP = lib.mkForce no;
  AP6XXX = lib.mkForce no;
  BCMDHD = lib.mkForce no;
  RFKILL_RK = lib.mkForce no;
};

  autoModules = false;
  kernelPreferBuiltin = false;
  ignoreConfigErrors = true;
})
