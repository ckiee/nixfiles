{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.services.minecraft;
  paper = pkgs.minecraft-server.overrideAttrs (oldAttrs: {
    src = pkgs.fetchurl {
      url =
        "https://papermc.io/api/v2/projects/paper/versions/1.16.5/builds/753/downloads/paper-1.16.5-753.jar";
      sha256 = "19pcz9cdwnnb4g645pkjfcskxmr8wcrkzyvq6a30af7yd4gjw102";
    };
  });
  console = pkgs.writeShellScriptBin "mc" ''
    ${pkgs.mcrcon}/bin/mcrcon localhost -p minecraft "$@"
  '';
in with lib; {
  options.cookie.services.minecraft = {
    enable = mkEnableOption "Enables the Minecraft server service";
  };

  config = mkIf cfg.enable {
    services.minecraft-server = {
      enable = true;
      eula = true;
      openFirewall = true;
      package = paper;
    };

    users = {
      groups.minecraft = { };
      users = {
        ron.extraGroups =
          [ "minecraft" ]; # I need to have read-write for /var/lib/minecraft
        minecraft.group = "minecraft";
      };
    };
    systemd.services.minecraft-server.serviceConfig = {
      Group = "minecraft";
      ExecStartPre = [
        "${pkgs.coreutils}/bin/chmod -R g+s /var/lib/minecraft"
        "${pkgs.coreutils}/bin/chown -R minecraft:minecraft /var/lib/minecraft"
      ];
    };

    environment.systemPackages = [ console ];
  };
}
