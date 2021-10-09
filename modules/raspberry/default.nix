{ lib, config, ... }:

let
  cfg = config.cookie.raspberry;
  sources = import ../../nix/sources.nix;
  system = "aarch64-linux";
  pkgs = import sources.nixpkgs {
    config = { };
    inherit system;
  };
  inherit (sources) nixos-hardware;
in with lib; {
  options.cookie.raspberry = {
    enable = mkEnableOption "Enables Raspberry Pi support";
    version = mkOption {
      type = types.enum [ 3 4 ];
      description = "Which RPi revision to use";
    };
  };

  imports = [ ./sd-image.nix ];

  config = mkMerge [
    (mkIf cfg.enable {
      # Set target arch
      nixpkgs = {
        inherit pkgs;
        localSystem.system = system;
      };
      # Bootloader crap
      boot.loader.raspberryPi = {
        enable = true;
        inherit (cfg) version;
      };

      ##
      ## Pasted from /nixpkgs/nixos/modules/installer/sd-card/sd-image-aarch64.nix
      ##

      boot.loader.grub.enable = false;
      boot.loader.generic-extlinux-compatible.enable = true;

      boot.consoleLogLevel = lib.mkDefault 7;

      # The serial ports listed here are:
      # - ttyS0: for Tegra (Jetson TX1)
      # - ttyAMA0: for QEMU's -machine virt
      boot.kernelParams =
        [ "console=ttyS0,115200n8" "console=ttyAMA0,115200n8" "console=tty0" ];

      sdImage = {
        populateFirmwareCommands = let
          configTxt = pkgs.writeText "config.txt" ''
            [pi3]
            kernel=u-boot-rpi3.bin

            [pi4]
            kernel=u-boot-rpi4.bin
            enable_gic=1
            armstub=armstub8-gic.bin

            # Otherwise the resolution will be weird in most cases, compared to
            # what the pi3 firmware does by default.
            disable_overscan=1

            [all]
            # Boot in 64-bit mode.
            arm_64bit=1

            # U-Boot needs this to work, regardless of whether UART is actually used or not.
            # Look in arch/arm/mach-bcm283x/Kconfig in the U-Boot tree to see if this is still
            # a requirement in the future.
            enable_uart=1

            # Prevent the firmware from smashing the framebuffer setup done by the mainline kernel
            # when attempting to show low-voltage or overtemperature warnings.
            avoid_warnings=1
          '';
        in ''
          (cd ${pkgs.raspberrypifw}/share/raspberrypi/boot && cp bootcode.bin fixup*.dat start*.elf $NIX_BUILD_TOP/firmware/)

          # Add the config
          cp ${configTxt} firmware/config.txt

          # Add pi3 specific files
          cp ${pkgs.ubootRaspberryPi3_64bit}/u-boot.bin firmware/u-boot-rpi3.bin

          # Add pi4 specific files
          cp ${pkgs.ubootRaspberryPi4_64bit}/u-boot.bin firmware/u-boot-rpi4.bin
          cp ${pkgs.raspberrypi-armstubs}/armstub8-gic.bin firmware/armstub8-gic.bin
          cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/bcm2711-rpi-4-b.dtb firmware/
        '';
        populateRootCommands = ''
          mkdir -p ./files/boot
          ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
        '';
      };
    })
    (mkIf (cfg.enable && cfg.version == 4) {
      ##
      ## Pasted from /nixos-hardware/raspberry-pi/4/default.nix
      ##

      boot = {
        kernelPackages = lib.mkDefault pkgs.linuxPackages_rpi4;
        initrd.availableKernelModules = [ "usbhid" "usb_storage" "vc4" ];

        loader = {
          grub.enable = lib.mkDefault false;
          generic-extlinux-compatible.enable = lib.mkDefault true;
        };
      };

      hardware.deviceTree.filter = "bcm2711-rpi-*.dtb";

      # Required for the Wireless firmware
      hardware.enableRedistributableFirmware = true;
    })
  ];
}
