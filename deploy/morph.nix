with builtins;

let
  sources = import ../nix/sources.nix;
  networkPkgs = import sources.nixpkgs { allowUnfree = true; };
in {
  network = {
    pkgs = networkPkgs;
    description = "Cookie hosts :^)";
    ordering = { tags = [ "desktops" "servers" ]; };
  };

  # Tailscale hosts
  "bokkusu" = import ../hosts/bokkusu;
  "cookiemonster" = import ../hosts/cookiemonster;
  "drapion" = import ../hosts/drapion;
  "pookieix" = import ../hosts/pookieix;
  "thonkcookie" = import ../hosts/thonkcookie;
  "pansear" = import ../hosts/pansear;
  "installer" = import ../hosts/installer;
}
