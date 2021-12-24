{ ... }:

let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs { };

  # throw is a keyword
  throwDeriv = pkgs.writeScriptBin "throw" ''
    "$(morph build morph.nix --on=_metadata 2>/dev/null)"/_metadata
    morph deploy morph.nix switch --passwd --on ${"\${@:-$(hostname)}"}
  '';

  morph = import sources.morph { inherit pkgs; };
in pkgs.mkShell {
  NIX_PATH = "nixpkgs=${pkgs.path}";

  buildInputs = with pkgs; [
    niv
    morph
    nix-prefetch-scripts
    nix-prefetch-github
    throwDeriv
    nixos-generators
  ];
}
