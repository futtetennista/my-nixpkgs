{ stdenv
, fetchurl
, lib
, makeWrapper
, sciePantsVersion ? "0.12.0"
  # Go to https://github.com/pantsbuild/scie-pants/releases/ and get sha256 in
  # the 'scie-pants-macos-aarch64.sha256' file (name depends on the architecture of your machine).
, sha256 ? "sha256-4sutOlvvX7WZzU1DaX2qwTr6LM5KRYJxAa4w2bijMAA="
}:

let
  arch = if stdenv.isAarch64 then "aarch64" else if stdenv.isx86_64 then "x86_64" else throw "Unknown architecture ${builtins.currentSystem}";
in
stdenv.mkDerivation rec {
  pname = "scie-pants";
  version = sciePantsVersion;

  src = fetchurl {
    url = "https://github.com/pantsbuild/scie-pants/releases/download/v${version}/scie-pants-macos-${arch}";
    inherit sha256;
  };

  buildInputs = [ makeWrapper ];

  dontUnpack = true;
  dontBuild = true;
  # Stripping breaks the executable
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -m 755 $src $out/bin
    pants=$(echo $src | sed 's/\/nix\/store\///g')
    mv $out/bin/$pants $out/bin/pants

    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/pants --add-flags --no-pantsd
      # --run 'echo "Conda env \""$CONDA_ENV"\" activated" && eval "conda shell.bash activate $CONDA_ENV"'
  '';

  meta = with lib; {
    description = "Pantsbuild: The ergonomic build system";
    homepage = "https://www.pantsbuild.org/";
    license = licenses.asl20;
    platforms = platforms.darwin;
  };
}
