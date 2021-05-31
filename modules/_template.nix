{ lib, config, pkgs, ... }:

let cfg = config.cookie.foo;

in with lib; {
  options.cookie.foo = {
    enable = mkEnableOption "Enables magical foo service";
  };

  config = mkIf cfg.enable { };
}
