let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs { };
in {
  network = {
    inherit pkgs sources;
    description = "Cookie hosts :^)";
    ordering = { tags = [ "desktops" "servers" ]; };
  };

  "thonkcookie.local" = import ./hosts/thonkcookie;
  "cookiemonster.local" = import ./hosts/cookiemonster;
  "bokkusu.ronthecookie.me" = import ./hosts/bokkusu;
  # "pookieix.local" = import ./hosts/pookieix;
}
