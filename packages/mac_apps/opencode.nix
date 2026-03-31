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
    mv $out/Applications/OpenCode.app/Contents/MacOS/OpenCode $out/Applications/OpenCode.app/Contents/MacOS/OpenCodeBinary

    echo '#!/bin/bash' > $out/Applications/OpenCode.app/Contents/MacOS/OpenCode
    echo 'source $HOME/.nixpath' >> $out/Applications/OpenCode.app/Contents/MacOS/OpenCode
    echo "'$out/Applications/OpenCode.app/Contents/MacOS/OpenCodeBinary' '\$@'" >> $out/Applications/OpenCode.app/Contents/MacOS/OpenCode
    chmod +x $out/Applications/OpenCode.app/Contents/MacOS/OpenCode
  '';

  meta = with pkgs.lib; {
    description = "Description of my app";
    platforms = platforms.darwin;
  };
}