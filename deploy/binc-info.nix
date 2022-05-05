let
  sources = import ../nix/sources.nix;
  eval = import "${sources.morph}/data/eval-machines.nix" {
    networkExpr = ./morph.nix;
  };
  pkgs = import sources.nixpkgs { };
  inherit (eval) uncheckedNodes nodes;
  inherit (pkgs) lib;
in with lib;
let
  getEnabledModulesInNs = ns:
    mapAttrs (k: module: module ? enable && module.enable) ns;
  hostServices = mapAttrsToList (k: host:
    nameValuePair k (getEnabledModulesInNs host.config.cookie.services))
    uncheckedNodes;
  unmergedSvcHosts = (map (nv:
    mapAttrsToList (svc: v: { ${if v then svc else null} = singleton nv.name; })
    nv.value) hostServices);
  serviceHosts = mapAttrs (_: flatten) (zipAttrs
    (map (hostList: foldr (a: b: a // b) { } hostList) unmergedSvcHosts));
in {
  inherit serviceHosts;
  hosts = attrNames nodes;
}
