{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "ckiesite";
  version = "git";

  src = fetchFromGitHub {
    owner = "ckiee";
    repo = "ckiesite";
    rev = "bea8d0f979730a4fcb502d8031b40594c84cfcaf";
    sha256 = "sha256-RTDGb8FY34zxsYDfGwJF0MCmNCnUnlFeslShmcLrmko=";
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
