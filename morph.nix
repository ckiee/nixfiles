let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs { };
in {
  network = {
    inherit pkgs;
    description = "Cookie hosts :^)";
    ordering = { tags = [ "desktops" "servers" ]; };
  };

  # Tailscale hosts
  "bokkusu" = import ./hosts/bokkusu;
  "cookiemonster" = import ./hosts/cookiemonster;
  "drapion" = import ./hosts/drapion;
  "thonkcookie" = import ./hosts/thonkcookie;
  # Legacy hosts
  "aquamarine.local" = import ./hosts/aquamarine;
  # "pookieix.local" = import ./hosts/pookieix;
}
