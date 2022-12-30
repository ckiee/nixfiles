{ lib, config, pkgs, ... }:

let cfg = config.cookie.collections.chat;

in with lib; {
  options.cookie.collections.chat = {
    enable = mkEnableOption "Enables a collection of chat apps";
  };

  config = mkIf cfg.enable {
    cookie.weechat.enable = true; # more or less unused now

    programs.firejail.wrappedBinaries = let
      element = (element-desktop.override {
        element-web = config.cookie.services.matrix.elementRoot;
      });
      inherit (config.cookie.firejail) mk;
    in mkMerge [
      (mk "element-desktop" { pkg = element; })
      (mk "Discord" { pkg = discord; })
    ];
  };
}
