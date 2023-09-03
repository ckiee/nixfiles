{ sources, lib, config, pkgs, ... }:

let cfg = config.cookie.services.matterbridge;
in with lib; {
  options.cookie.services.matterbridge = {
    enable = mkEnableOption "Matterbridge service";
  };

  config = mkIf cfg.enable {
    cookie.secrets.matterbridge = {
      source = "./secrets/matterbridge.toml";
      dest = "/var/run/matterbridge.toml";
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

    systemd.services.matterbridge.environment.DEBUG = "1";
  };
}
