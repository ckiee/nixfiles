{ config, lib, pkgs, ... }:
with lib;
with builtins; {
  /* Converts a list of service names to a full email address.

     Type: process :: string [string] -> [string]

     Example:
     process "hunter2" [ "github" "twitter" ]
     => [ "github-184831f@ckie.dev" "twitter-123834f@ckie.dev" ]
  */
  process = salt: aliases:
    (map (x:
      (x + "-" + (substring 0 7 (hashString "sha512" "${x}${salt}"))
        + "@ckie.dev")) aliases);

  default-aliases = import ../../../secrets/mailserver-default-aliases.nix;
}
