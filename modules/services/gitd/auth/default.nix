{ stdenv, mkYarnModules, nodejs-18_x, ... }:

stdenv.mkDerivation rec {
  pname = "cgito-auth";
  version = "ckie";
  src = ./.;
  nodejs = nodejs-18_x;

  installPhase = ''
    mkdir -p $out/libexec
    (
      echo "#!$nodejs/bin/node"
      cat $src/filter.js
    ) > $out/libexec/auth-filter
    (
      echo "#!$nodejs/bin/node"
      cat $src/gitolite.js
    ) > $out/libexec/gitolite-cmd
    chmod +x $out/libexec/*
  '';

  # yarnDeps = mkYarnModules {
  #   pname = "${pname}-yarn-deps";
  #   inherit version;
  #   packageJSON = ./package.json;
  #   yarnLock = ./yarn.lock;
  #   postBuild = ''
  #     # echo 'module.exports = {}' > $out/node_modules/flatpickr/dist/postcss.config.js
  #   '';
  # };
}
