{
  lib,
  pkgsCross,
  # pkgs,
}:
let
  pkgs = pkgsCross.aarch64-multiplatform;
  kernelConfig = with lib.kernel; {
    # arch/arm64/Kconfig.platforms
    ARCH_ROCKCHIP = yes;

    # drivers/clocksource/Kconfig
    ROCKCHIP_TIMER = yes;

    # drivers/clk/rockchip/Kconfig
    CLK_RK3588 = yes;

    # drivers/clk/rockchip/Kconfig
    COMMON_CLK_ROCKCHIP = yes;

    # drivers/net/phy/Kconfig
    ROCKCHIP_PHY = yes; # Currently supports the integrated Ethernet PHY.

    # drivers/phy/rockchip/Kconfig
    PHY_ROCKCHIP_EMMC = yes; # Enable this to support the Rockchip EMMC PHY.
    # PHY_ROCKCHIP_INNO_HDMI = yes; # Enable this to support the Rockchip Innosilicon HDMI PHY.
    PHY_ROCKCHIP_INNO_USB2 = yes; # Support for Rockchip USB2.0 PHY with Innosilicon IP block.
    PHY_ROCKCHIP_PCIE = yes; # Enable this to support the Rockchip PCIe PHY.
    PHY_ROCKCHIP_SNPS_PCIE3 = yes; # Enable this to support the Rockchip snps PCIe3 PHY.
    PHY_ROCKCHIP_TYPEC = yes; # Enable this to support the Rockchip USB TYPEC PHY.
    PHY_ROCKCHIP_USB = yes; # Enable this to support the Rockchip USB 2.0 PHY.

    # drivers/gpu/drm/rockchip/Kconfig
    DRM_ROCKCHIP = yes;
    ROCKCHIP_VOP2 = yes;

    # drivers/media/platform/rockchip/rga/Kconfig
    VIDEO_ROCKCHIP_RGA = module; # This is a v4l2 driver for Rockchip SOC RGA 2d graphics accelerator.
    # Rockchip RGA is a separate 2D raster graphic acceleration unit.
    # It accelerates 2D graphics operations, such as point/line drawing,
    # image scaling, rotation, BitBLT, alpha blending and image blur/sharpness.

    # drivers/media/platform/verisilicon/Kconfig
    VIDEO_HANTRO = module; # Enable Hantro VPU driver - hardware video encoding/decoding acceleration for H.264, HEVC, VP8, VP9, JPEG
    VIDEO_HANTRO_HEVC_RFC = yes; # Enable HEVC reference frame compression - saves memory bandwidth but uses more RAM for HEVC codec
    VIDEO_HANTRO_ROCKCHIP = yes;

    # # drivers/soc/rockchip/Kconfig
    # ROCKCHIP_IODOMAIN = yes; # Enable support io domains on Rockchip SoCs.
    # ROCKCHIP_DTPM = yes; # Describe the hierarchy for the Dynamic Thermal Power Management tree
    # # on this platform. That will create all the power capping capable devices.

    # # drivers/gpio/Kconfig
    # GPIO_ROCKCHIP = yes;

    # SND_SOC_ROCKCHIP = yes;            # Enable Rockchip SoC audio framework - core audio support for Rockchip chips
    # SND_SOC_ROCKCHIP_I2S = yes;        # Enable I2S audio driver - digital audio interface for codecs and audio devices
    # SND_SOC_ROCKCHIP_I2S_TDM = yes;    # Enable I2S/TDM driver - multi-channel audio and time division multiplexing support
    # SND_SOC_ROCKCHIP_PDM = yes;        # Enable PDM driver - pulse density modulation for digital MEMS microphones
    # SND_SOC_ROCKCHIP_SPDIF = yes;      # Enable SPDIF driver - Sony/Philips digital audio output for home theater systems

    # # drivers/spi/Kconfig
    # SPI_ROCKCHIP = yes;
    # SPI_ROCKCHIP_SFC = yes;

    # # drivers/pmdomain/rockchip/Kconfig
    # ROCKCHIP_PM_DOMAINS = yes;
  };
in
# pkgs.linuxKernel.packagesFor (
pkgs.linuxKernel.kernels.linux_6_12.override { structuredExtraConfig = kernelConfig; }
# )
