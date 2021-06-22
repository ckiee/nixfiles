let
  sources = import ./nix/sources.nix;
  pkgs = import /home/ckie/git/nixpkgs { };
in {
  network = {
    inherit pkgs sources;
    description = "Cookie hosts :^)";
    ordering = { tags = [ "desktops" "servers" ]; };
  };

  "thonkcookie.local" = import ./hosts/thonkcookie;
  "cookiemonster.local" = import ./hosts/cookiemonster;
  "bokkusu.ckie.dev" = import ./hosts/bokkusu;
  # "pookieix.local" = import ./hosts/pookieix;
}
