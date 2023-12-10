with builtins;

__trace "morph eval" (

let
  sources = import ../nix/sources.nix;
  networkPkgs = import sources.nixpkgs { allowUnfree = true; };
in {
  network = {
    pkgs = networkPkgs;
    description = "Cookie hosts :^)";
    ordering = { tags = [ "desktops" "servers" ]; };
  };

  # Do not change the order of these entries! Always append at the
  # bottom as the wireguard module depends on this order in order to choose IPs.
  "bokkusu" = import ../hosts/bokkusu;
  "cookiemonster" = import ../hosts/cookiemonster;
  "drapion" = import ../hosts/drapion;
  "pookieix" = import ../hosts/pookieix;
  "thonkcookie" = import ../hosts/thonkcookie;
  "pansear" = import ../hosts/pansear;
  "installer" = import ../hosts/installer;
  "hmporter" = import ../hosts/hmporter;
  "virt" = import ../hosts/virt;
  "kyurem" = import ../hosts/kyurem;
  "eg" = import ../hosts/eg;
  "kibako" = import ../hosts/kibako;
  "flowe" = import ../hosts/flowe;
}

)
