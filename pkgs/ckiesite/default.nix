{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "ckiesite";
  version = "git";

  src = fetchFromGitHub {
    owner = "ckiee";
    repo = "ckiesite";
    rev = "3fbad2cd568b2c06c8cb6efc94aa23d99d70a264";
    sha256 = "ZfjWveDMuMVQm+ffvvW8g061FAe1Oc2cKnMHc8Lzj1k=";
  };

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
