{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.collections.chat;

  element = (pkgs.element-desktop.override {
    element-web = config.cookie.services.matrix.elementRoot;
  });
in with lib; {
  options.cookie.collections.chat = {
    enable = mkEnableOption "Enables a collection of chat apps";
  };

  config = mkIf cfg.enable {
    home-manager.users.ckie = { ... }: {
      home.packages = with pkgs; [
        discord
        #schildichat-desktop # broken, removed
        element-desktop # NOTE: using the unmodified nixpkgs element again!
        signal-desktop
        mumble
        nheko
      ];
      cookie.weechat.enable = true; # more or less unused now
    };

    programs.firejail.wrappedBinaries = with pkgs;
      let inherit (config.cookie.firejail) mk;
      in mkMerge [
        # not good enough to be useful (yet), and is a nuisance
        # (mk "element-desktop" { pkg = element; })
        # (mk "Discord" { pkg = discord; })
      ];
  };
}
