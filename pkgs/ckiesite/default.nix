{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "ckiesite";
  version = "git";

  src = fetchFromGitHub {
    owner = "ckiee";
    repo = "ckiesite";
    rev = "bb695a2b197d81a6d9045e114181ba535e00e2fb";
    sha256 = "sha256-S/SV5d/M5PyJ/zsWT5BjlypFF1aulPqnG6+cyqj7F2U=";
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
