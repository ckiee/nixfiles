{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.services.minecraft;
  paper = pkgs.minecraft-server.override {
    src = pkgs.fetchurl {
      url =
        "https://papermc.io/api/v2/projects/paper/versions/1.16.5/builds/753/downloads/paper-1.16.5-753.jar";
      sha256 = "19pcz9cdwnnb4g645pkjfcskxmr8wcrkzyvq6a30af7yd4gjw102";
    };
  };

in with lib; {
  options.cookie.services.minecraft = {
    enable = mkEnableOption "Enables the Minecraft server service";
  };

  config = mkIf cfg.enable {
    services.minecraft-server = {
      enable = true;
      eula = true;
      openFirewall = true;
      dataDir = "/cookie/minecraft";
      package = paper;
    };
  };
}
