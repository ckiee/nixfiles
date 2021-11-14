{ options, lib, config, pkgs, ... }:

with lib; {
  options.cookie.user = mkOption {
    type = options.users.users.type.functor.wrapped;
    description = "My user";
  };
  config = { users.users."ckie" = mkAliasDefinitions options.cookie.user; };
}
