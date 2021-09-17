{ lib, config, pkgs, ... }:

let cfg = config.cookie.metadata;

in with lib; {
  options.cookie.metadata = {
    raw = mkOption {
      description = "the raw metadata";
      readOnly = true;
      default = importTOML ../ext/metadata.toml;
    };
  };
}
