{ lib, config, pkgs, ... }:

let cfg = config.cookie.metadata;

in with lib; {
  options.cookie.metadata = {
    raw = mkOption { description = "the raw metadata"; };
  };

  config.cookie.metadata = { raw = importTOML ../ext/metadata.toml; };
}
