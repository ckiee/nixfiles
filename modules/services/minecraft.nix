{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.services.minecraft;
  paper = pkgs.minecraft-server.overrideAttrs (oldAttrs: {
    src = pkgs.fetchurl {
      url = let build = 30;
      in "https://papermc.io/api/v2/projects/paper/versions/1.17/builds/${
        toString build
      }/downloads/paper-1.17-${toString build}.jar";
      sha256 = "sha256:00myh0zyfq4632h00gajin3f7md3avddplkvrrkd6pi64rr8yz5g";
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
        ckie.extraGroups =
          [ "minecraft" ]; # I need to have read-write for /var/lib/minecraft
        minecraft.group = "minecraft";
      };
    };
    # We need a separate unit so we can use root privileges for this
    systemd.services.minecraft-server-perms = {
      description = "Setup permissions for /var/lib/minecraft";
      script = ''
        ${pkgs.coreutils}/bin/chmod -R 2777 /var/lib/minecraft
        ${pkgs.coreutils}/bin/chown -R minecraft:minecraft /var/lib/minecraft
      '';
      wantedBy = [ "minecraft-server.service" ];
    };

    environment.systemPackages = [ console ];
  };
}
