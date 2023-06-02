{ lib, config, pkgs, ... }:

let cfg = config.cookie.zathura;

in with lib; {
  options.cookie.zathura = {
    enable =
      mkEnableOption "Enables zathura, a vimmy PDF(+probably more) reader";
  };

  config = mkIf cfg.enable {
    programs.zathura = {
      enable = true;
    };

    # sync reading progress and whatnot
    home.file."${config.xdg.dataHome}/zathura".source = (config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/Sync/.zathura");
  };
}
