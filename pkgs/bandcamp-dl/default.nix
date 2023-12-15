# https://git.iliana.fyi/nixos-configs/tree/packages/bandcamp-dl.nix
{ fetchFromGitHub, python3, ... }:

python3.pkgs.buildPythonApplication {
  pname = "bandcamp-dl";
  version = "unstable-2023-04-09";
  format = "other";

  src = fetchFromGitHub {
    owner = "iliana";
    repo = "bandcamp-dl";
    rev = "5b434a8401f51397e4cc7c9bce87f6f137d3ec90";
    hash = "sha256-u+I/D/MNUDTQf+V2R6zJxNbIKPOuO2Qc2ZXw26q2Es8=";
  };

  buildInputs = [ python3 ];

  propagatedBuildInputs = with python3.pkgs; [
    browser-cookie3
  ];

  installPhase = ''
    runHook preInstall
    install -Dm 0755 bandcamp-dl.py $out/bin/bandcamp-dl
    runHook postInstall
  '';
}
