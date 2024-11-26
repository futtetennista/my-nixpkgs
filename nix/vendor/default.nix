{ callPackage ? pkgs.callPackage
, pkgs ? import (import ../../sources.nix).nixpkgs-unstable { }
}:

{
  miniconda = (callPackage ./miniconda { });
  pantsbuild = (callPackage ./pantsbuild { });
}
