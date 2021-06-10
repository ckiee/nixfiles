{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.weechat;
  # https://github.com/xe/nixos-configs/commit/36fc81b#diff-8f732ff9aa6533343d2b0f42228f4091570a67c74472a2dce97786f89407d07dR83
  weechat = with pkgs.weechatScripts;
    pkgs.weechat.override {
      configure = { availablePlugins, ... }: {
        scripts = [ weechat-autosort weechat-matrix ];
        extraBuildInputs =
          [ availablePlugins.python.withPackages (_: [ weechat-matrix ]) ];
      };
    };
in with lib; {
  options.cookie.weechat = {
    enable = mkEnableOption "Installs and configures weechat";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ weechat ];
    home.file.".weechat".source = (config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/Sync/.weechat");
  };
}
