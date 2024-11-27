{
  sources ? import ./npins,
  system ? builtins.currentSystem,
  pkgs ? import sources.nixpkgs { inherit system; config = {}; overlays = []; },
}:

let
  pkgs-vendored = import ./nix/nixpkgs/vendor { };
in
pkgs.mkShellNoCC {
  packages = with pkgs; [
    git
    gh
    jq
    nodejs_20
    pnpm
    pkgs-vendored.postgresql_14
    shellcheck
  ];

  shellHook = ''
    
  '';
}
