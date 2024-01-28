# https://github.com/aldoborrero/mynixpkgs/blob/67a7db27330f85af19f3ce52ae06671e573968ea/pkgs/by-name/ac/actual-server/default.nix
# mostly unmodifeid

{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  python3,
  nodejs,
  runtimeShell,
}:
buildNpmPackage rec {
  pname = "actual-server";
  version = "23.11.0";

  src = fetchFromGitHub {
    owner = "actualbudget";
    repo = pname;
    rev = "refs/tags/v${version}";
    hash = "sha256-S2d3vcu/z6uLq6dIlDf33GngAoORaBKd1Q8Q6LZuxxU=";
  };

  npmDepsHash = "sha256-ID6WP/WTPYPQkV8Y0WRaSWtmE+MCfgTxkE3HoqP2MxI=";

  nativeBuildInputs = [
    python3
  ];

  postUnpack = ''
    rm -rf yarn.lock
  '';

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  dontNpmBuild = true;

  postInstall = ''
    # Make an executable to run the server
    mkdir -p $out/bin
    cat <<EOF > $out/bin/actual-server
    #!${runtimeShell}
    exec ${nodejs}/bin/node $out/lib/node_modules/actual-sync/app.js "\$@"
    EOF
    chmod +x $out/bin/actual-server
  '';

  meta = with lib; {
    homepage = "https://github.com/actualbudget/actual-server";
    description = "Actual's server";
    changelog = "https://github.com/actualbudget/actual-server/releases/tag/v${version}";
    mainProgram = pname;
    license = licenses.mit;
    maintainers = with maintainers; [aldoborrero];
    passthru.nixos = import ./module.nix; # oopsie(ckie)
  };
}
