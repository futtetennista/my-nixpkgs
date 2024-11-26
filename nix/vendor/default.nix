{ callPackage ? pkgs.callPackage
, pkgs ? import sources.nixpkgs { inherit system; config = {}; overlays = []; },
, sources ? import ../../npins,
}:

let
  postgresql_12 = pkgs.callPackage ./postgresql {
    postgresql = pkgs.postgresql_12;
    version = 12;
  };
  postgresql_14 = pkgs.callPackage ./postgresql {
    postgresql = pkgs.postgresql_14;
    version = 14;
  };
in
{
  miniconda = (callPackage ./miniconda { });
  pantsbuild = (callPackage ./pantsbuild { });
  inherit postgresql_12 postgresql_14;
}
