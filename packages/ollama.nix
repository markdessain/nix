{ lib, stdenv, fetchurl, zstd }:

stdenv.mkDerivation rec {
  pname = "ollama";
  version = "1.0.0";

  src = fetchurl {
    url = "https://github.com/ollama/ollama/releases/download/v0.20.2/ollama-linux-arm64.tar.zst";
    hash = "sha256-1MGKK0TC76heTuzI4s9WtliSNJD/hbzweKmT0VGA9Vc=";
  };

  nativeBuildInputs = [ zstd ];

  unpackPhase = ''
    tar --use-compress-program=zstd -xf $src
  '';

  installPhase = ''
    mkdir -p $out/bin
    install -m755 bin/ollama $out/bin/ollama
  '';
}
