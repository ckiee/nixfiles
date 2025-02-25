{ lib, config, pkgs, ... }:

let cfg = config.cookie.taskwarrior;

in with lib; {
  options.cookie.taskwarrior = {
    enable = mkEnableOption "Enables taskwarrior";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ taskwarrior3 tasksh vit ];

    xdg.configFile."task/taskrc".source = (config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/Sync/taskwarrior/taskrc");

  };
}
