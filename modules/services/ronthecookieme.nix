{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.ronthecookieme;

in with lib; {
  options.cookie.services.ronthecookieme = {
    enable = mkEnableOption "Enables ronthecookie.me service";
    host = mkOption {
      type = types.str;
      default = "devel.ronthecookie.me";
      description = "the host. wow.";
      example = "ronthecookie.me";
    };
  };

  config = mkIf cfg.enable {
    assertions = [{
      assertion = config.cookie.services.nginx.enable;
      message = "nginx required";
    }];

    services.nginx = {
      virtualHosts."${cfg.host}" = {
        locations."/" = { root = "${pkgs.cookie.ronthecookieme}"; };
      };
    };
  };
}
