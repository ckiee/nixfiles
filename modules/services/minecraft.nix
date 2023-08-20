{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.services.minecraft;
  paper = pkgs.minecraft-server.overrideAttrs (oldAttrs: {
    src = pkgs.fetchurl {
      url = let
        build = 401;
        mc = "1.17.1";
      in "https://papermc.io/api/v2/projects/paper/versions/${mc}/builds/${
        toString build
      }/downloads/paper-${mc}-${toString build}.jar";
      sha256 = "sha256-Qpk/IAg5ExNJ5JbnTZRIZ3+7lRfG/oyafKz755ilf9o=";
    };
  });
  console = pkgs.writeShellScriptBin "mc" ''
    ${pkgs.mcrcon}/bin/mcrcon -p minecraft "$@" || true
  '';
in with lib; {
  options.cookie.services.minecraft = {
    enable = mkEnableOption "Enables the Minecraft server service";
    heapAllocation = mkOption {
      type = types.str;
      default = "2G";
      description = "JVM heap allocation with specifiable size unit";
    };
  };

  config = mkIf cfg.enable {
    services.minecraft-server = {
      enable = true;
      eula = true;
      openFirewall = true;
      package = paper;
      jvmOpts =
        "-Xms${cfg.heapAllocation} -Xmx${cfg.heapAllocation} -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true";
    };

    # dont auto-start it, it uses a lot of resources and rarely
    # actually serves players.
    systemd.services.minecraft-server.wantedBy = mkForce [];

    cookie.restic = let mcExec = c: "${console}/bin/mc ${escapeShellArg c}";
    in {
      paths = [ "/var/lib/minecraft" ];
      preJob = ''
        ${mcExec "bossbar set minecraft:backup visible true"}
        ${mcExec "save-off"}
        ${mcExec "save-all"}
      '';
      postJob = ''
        ${mcExec "bossbar set minecraft:backup visible false"}
        ${mcExec "save-all"}
        ${mcExec "save-on"}
      '';
    };

    cookie.bindfs.minecraft = {
      source = "/var/lib/minecraft";
      dest = "${config.cookie.user.home}/minecraft";
      overlay = false;
      args =
        "--create-for-user=minecraft --create-with-perms=0700 -u ckie -g users -p 0600,u+X";
      wantedBy = [ "minecraft-server.service" ];
    };

    environment.systemPackages = [ console ];
  };
}
