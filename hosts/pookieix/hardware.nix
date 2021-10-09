{ config, lib, pkgs, modulesPath, ... }:

let
  sources = import ../../nix/sources.nix;
  inherit (sources) nixos-hardware;
in {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    "${nixos-hardware}/raspberry-pi/4"
  ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  # ttyAMA0 is the serial console broken out to the GPIO
  boot.kernelParams = [
    "8250.nr_uarts=1" # may be required only when using u-boot
    "console=ttyAMA0,115200"
    "console=tty1"
  ];

  # vcgencmd shall be free from root
  services.udev.extraRules = ''
    SUBSYSTEM=="vchiq",GROUP="video",MODE="0660"
    SUBSYSTEM=="vc-sm",GROUP="video",MODE="0660"
    SUBSYSTEM=="bcm2708_vcio",GROUP="video",MODE="0660"
  '';
}
