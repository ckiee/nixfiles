{ ... }:

with builtins;

let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs { };

  cBin = pkgs.writeScriptBin "c" (readFile ./bin/c);

  morph = import sources.morph { inherit pkgs; };
  nix-eval-jobs = pkgs.callPackage sources.nix-eval-jobs { };
  myNix = pkgs.nixUnstable;
  #   .overrideAttrs (orig: {
  #   patches = orig.patches ++ [
  #     ./0001-libexpr-improve-invalid-value-error.patch
  #     ./0002-libexpr-add-blackhole-InternalType-to-printValue.patch
  #   ];
  # });
in pkgs.mkShell {
  NIX_PATH = "nixpkgs=${sources.nixpkgs}";
  NIXPKGS_ALLOW_UNFREE = "1";

  buildInputs = with pkgs; [
    niv
    morph
    nix-prefetch-scripts
    nix-prefetch-github
    (nixos-generators.override { nix = myNix; })
    # cBin
    myNix
    jq
    nix-eval-jobs
  ];
}
