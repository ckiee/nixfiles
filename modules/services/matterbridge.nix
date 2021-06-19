{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.services.matterbridge;
  sources = import ../../nix/sources.nix;
in with lib; {
  options.cookie.services.matterbridge = {
    enable = mkEnableOption "Enables the Matterbridge service";
  };

  config = mkIf cfg.enable {
    cookie.secrets.matterbridge = {
      source = ../../secrets/matterbridge.toml;
      dest = "/run/keys/matterbridge.toml";
      owner = "matterbridge";
      group = "matterbridge";
      permissions = "0400";
      wantedBy = "matterbridge.service";
    };

    nixpkgs.overlays = [
      (self: super: {
        matterbridge = super.matterbridge.overrideAttrs
          (old: { src = sources.matterbridge; });
      })
    ];

    services.matterbridge = {
      enable = true;
      configPath = config.cookie.secrets.matterbridge.dest;
    };
  };
}
