{ lib, stdenv, fetchFromGitHub }:

let sources = import ../../nix/sources.nix;
    src = sources.ckiesite;
in stdenv.mkDerivation rec {
  pname = "ckiesite";
  version = "git";

  inherit src;

  phases = "installPhase";
  installPhase = ''
    mkdir $out
    cp -r $src/public/* $out/
  '';

  meta = with lib; {
    description = "Cookie's porch";
    homepage = "https://ckie.dev";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
