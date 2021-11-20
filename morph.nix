let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs { allowUnfree = true; };
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
  "pookieix" = import ./hosts/pookieix;
  "thonkcookie" = import ./hosts/thonkcookie;
  "installer" = import ./hosts/installer;
  # Legacy hosts
  "aquamarine.local" = import ./hosts/aquamarine;
  # "pookieix.local" = import ./hosts/pookieix;
}
