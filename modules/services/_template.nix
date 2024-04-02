{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.foo;

in with lib; {
  options.cookie.services.foo = {
    enable = mkEnableOption "the foo service";
  };

  config = mkIf cfg.enable { };
}
