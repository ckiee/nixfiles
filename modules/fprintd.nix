{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.fprintd;
  sources = import ../nix/sources.nix;
in with lib; {
  options.cookie.fprintd = { enable = mkEnableOption "fingerprint @ T480s"; };

  imports = [
    ((import sources.nixos-06cb-009a-fingerprint-sensor).overrideInputs {
      nixpkgs = pkgs.path;
    }).nixosModules."06cb-009a-fingerprint-sensor"
  ];

  config = mkIf cfg.enable {
    services."06cb-009a-fingerprint-sensor" = {
      enable = true;
      # backend = "python-validity"; to enroll..
      backend = "libfprint-tod";
      calib-data-file = ../secrets/fprintd-calib-data-thinkpad.bin;
    };

    security.pam.services = {
      lightdm.fprintAuth = mkForce false;
      lightdm-autologin.fprintAuth = mkForce false;
      lightdm-greeter.fprintAuth = mkForce false;
      login.fprintAuth = mkForce false;
      other.fprintAuth = mkForce false;
      chpasswd.fprintAuth = mkForce false;
      chfn.fprintAuth = mkForce false;
    };
  };
}
