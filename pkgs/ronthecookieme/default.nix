{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "ronthecookieme";
  version = "git";

  src = fetchFromGitHub {
    owner = "ronthecookie";
    repo = "ronthecookie.me";
    rev = "d11223321a8f0f1c6b9cca221b114f00e339c683";
    sha256 = "014pcc01d87sylf8g8x58aar31jrb3qwb8qfs1v7v129v3ikr2ys";
  };

  phases = "installPhase";
  installPhase = ''
    mkdir -p $out/share/doc
    cp -r $src/static $out/share/doc/ronthecookieme
  '';

  meta = with lib; {
    description = "Cookie's porch";
    homepage = "https://ronthecookie.me";
    license = licenses.mit;
    maintainers = [ maintainers.ronthecookie ];
    platforms = platforms.all;
  };
}
