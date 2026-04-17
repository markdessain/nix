{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation rec {
  pname = "app-vscode";
  version = "1.114";


  src = pkgs.fetchurl {
    url = "https://vscode.download.prss.microsoft.com/dbazure/download/stable/560a9dba96f961efea7b1612916f89e5d5d4d679/VSCode-darwin-universal.dmg";
    sha256 = "sha256-ETaNp9JI17XoomMuxXoSHuN9jNTg+5bl+K3QSBKM8SI=";
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