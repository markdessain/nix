{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation rec {
  pname = "app-vscodium";
  version = "1.0.0";

  src = pkgs.fetchurl {
    url = "https://github.com/VSCodium/vscodium/releases/download/1.112.01907/VSCodium-darwin-arm64-1.112.01907.zip";
    sha256 = "sha256-9n7kVtknqfSfTc2MmFps5bxSqMnL6KNhZgTb+DVUkhY=";
  };

  nativeBuildInputs = [ pkgs.unzip ];

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/Applications
    cp -R *.app $out/Applications
  '';

  meta = with pkgs.lib; {
    description = "Description of my app";
    platforms = platforms.darwin;
  };
}