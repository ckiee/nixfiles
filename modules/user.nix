{ options, lib, config, pkgs, ... }:

with lib; {
  options.cookie.user = mkOption {
    # type broke between d460e0095e54149099805025c99b112da4471ac6..277bbfb1454da4342105eaca4a82fa8ede08617d
    # type = options.users.users.type.functor.wrapped;
    description = "My user";
  };
  config = {
    users.users."ckie" = mkAliasDefinitions options.cookie.user;

    cookie.user = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "dialout" "docker" ];
      hashedPassword = (import ../secrets/unix-password.nix).ckie;
      home =
        "/home/ckie"; # The alias makes it think my username is "user" here.
    };
  };
}
