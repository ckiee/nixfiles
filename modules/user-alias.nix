{ options, lib, config, pkgs, ... }:

with lib; {
  options.cookie.user =
    mkOption { type = options.users.users.type.functor.wrapped; };
  config = { users.users."ckie" = mkAliasDefinitions options.cookie.user; };
}
