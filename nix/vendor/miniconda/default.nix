{ stdenv
, fetchurl
, lib
, makeWrapper
, writeShellScriptBin
, pythonVersion ? "py39"
  # This version should be the same as the one bundled with the base image of miniforge (https://github.com/conda-forge/miniforge/releases)
  # used in https://github.com/Synthace/docker-images/blob/858a503e0139342116569bb6f3ec36993a8134ad/conda/Dockerfile.conda-mambaforge#L2
  # which is then used to build the Docker image from 'visserver/Dockerfile'.
, versionNumber ? "24.7.1-0"
, sha256 ? "sha256-9QNcBZX3kagi+/O/W1Vejmj+M0N6/6OBGxJevTnvvoE="
, arch ? "x86_64"
  # , condaEnv ? "antha-visserver"
  # , requirements ? [ ]
  # , condaChannels ? [ "conda-forge" "defaults" ]
}:

let
  # condaChannelsArgs = toString (map (c: "-c ${c}") condaChannels);
  # requirementsArgs = toString (map (file: "--file ${file}") requirements);

  # Nix uses a highly isolated environment and rewrites the PATH env variable with Nix-specific paths only.
  # 'md5' is an executable that macOS provides out-of-the box in e.g. '/sbin' which is not in the PATH
  # of the derivation. So we cheat and create a 'md5' program by wrapping the unix program 'md5sum'
  # The two produce the same hash. Their output is slightly different.
  # That luckily is not an issue because the installation script `grep`s for the hash.
  md5 = writeShellScriptBin "md5" ''
    md5sum "$@"
  '';
in
stdenv.mkDerivation rec {
  pname = "miniconda";
  version = "${pythonVersion}_${versionNumber}";

  src = fetchurl {
    url = "https://repo.anaconda.com/miniconda/Miniconda3-${version}-MacOSX-${arch}.sh";
    inherit sha256;
  };

  buildInputs = [ makeWrapper md5 ];

  # dontUnpack = true;
  # dontBuild = true;

  phases = [ "installPhase" "fixupPhase" ];

  installPhase = ''
    runHook preInstall

    # The conda installer looks at this environment variable to install all-things.
    # We cannot use the HOME that Nix sets because Nix runs in an isolated environment
    # and that HOME doesn't exist in the host machine.
    export HOME=$out

    bash $src -b

    runHook postInstall
  '';

  postFixup = ''
    # Nix expects executables to be installed in the '$out/bin' directory
    # to make them automatically available in a shell.
    # The conda installer puts them under 'miniconda3/bin' so we create a symlink to that folder.
    ln -s $out/miniconda3/bin $out/bin

    # Don't wrap the original script: it breaks the 'conda init' scripts.
    # https://conda.org/blog/2023-11-06-conda-23-10-0-release/
    # wrapProgram $out/miniconda3/bin/conda --prefix CONDA_RESOLVER=classic
  '';

  meta = with lib; {
    description = "Miniconda - a minimal installer for conda";
    homepage = "https://docs.conda.io/en/latest/miniconda.html";
    license = licenses.mit;
    platforms = platforms.darwin;
  };
}
                                                                                         
