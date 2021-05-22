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
  # "pookieix.local" = import ./hosts/pookieix;
}
