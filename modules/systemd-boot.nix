{ config, lib, pkgs, ... }:

let cfg = config.cookie.systemd-boot;
in with lib; {
  options.cookie.systemd-boot = {
    enable = mkEnableOption "systemd-boot bootloader";
    memtest = mkEnableOption "memtest86" // {
      default = lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.memtest86plus;
    };
  };

  config = mkIf cfg.enable {
    boot.loader.systemd-boot = {
      enable = true;
      editor = false;
      configurationLimit = 16;
      # From https://matrix.to/#/!sgkZKRutwatDMkYBHU:nixos.org/$iKnJUt1L_7E5bq7hStDPwv6_2HTBvNjwfcWxlKlF-k8?via=nixos.org&via=matrix.org&via=nixos.dev
      # There's a dedicated NixOS option but it uses the propietary memtest86, not memtest86+
      # TODO: Fix?
      extraFiles."efi/memtest86plus/memtest.efi" =
        mkIf cfg.memtest "${pkgs.memtest86plus}/memtest.efi";
      extraEntries."memtest86plus.conf" = mkIf cfg.memtest ''
        title MemTest86+
        efi   /efi/memtest86plus/memtest.efi
      '';
    };
  };
}
