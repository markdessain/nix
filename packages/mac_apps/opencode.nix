{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation rec {
  pname = "app-opencode";
  version = "1.0.0";

  src = pkgs.fetchurl {
    url = "https://github.com/anomalyco/opencode/releases/download/v1.3.7/opencode-desktop-darwin-aarch64.dmg";
    sha256 = "sha256-9og6LEWyya4SmKMQrKQqcDGnUD52EEmCB+nQQZWXnRY=";
  };

  nativeBuildInputs = [ pkgs.undmg ];

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