{ options, lib, config, pkgs, ... }:

with lib; {
  options.cookie.user = mkOption {
    type = options.users.users.type.functor.wrapped;
    description = "My user";
  };
  config = {
    users.users."ckie" = mkAliasDefinitions options.cookie.user;

    cookie.secrets.unix-password = {
      source = "./secrets/unix-password.nix";
      runtime = false;
    };

    cookie.user = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "dialout" ];
      hashedPassword = (import ../secrets/unix-password.nix).ckie;
      home =
        "/home/ckie"; # The alias makes it think my username is "user" here.
    };
  };
}
