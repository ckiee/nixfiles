{ config, lib, pkgs, ... }:

let cfg = config.cookie.systemd-boot;
in with lib; {
  options.cookie.systemd-boot = {
    enable = mkEnableOption "Enables the systemd-boot bootloader";
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
        "${pkgs.memtest86plus}/memtest.efi";
      extraEntries."memtest86plus.conf" = ''
        title MemTest86+
        efi   /efi/memtest86plus/memtest.efi
      '';
    };
  };
}
