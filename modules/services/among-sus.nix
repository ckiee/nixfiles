{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.services.among-sus;
  util = import ./util.nix { inherit lib config; };
in with lib; {
  options.cookie.services.among-sus = {
    enable = mkEnableOption "Enables the among-sus daemon";
    folder = mkOption {
      type = types.str;
      default = "/var/lib/among-sus";
      description = "path to service home directory";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (util.mkService "among-sus" {
      home = cfg.folder;
      description = "Susifying daemon";
      script = let
        sus = pkgs.among-sus.overrideAttrs (attrs: {
          src = pkgs.fetchFromSourcehut {
            owner = "~martijnbraam";
            repo = "among-sus";
            rev = "554e60bf52e3fa931661b9414189a92bb8f69d78";
            sha256 = "sha256-HOiAwzQYxboEpwE38OxbETZLNoX77+lDLH7DzywqIUg=";
          };
        });
      in ''
        exec ${sus}/bin/among-sus -p 9873
      '';
    })
    { networking.firewall.allowedTCPPorts = [ 9873 ]; }
  ]);
}
