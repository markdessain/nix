{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation rec {
  pname = "app-vscode";
  version = "1.114";


  src = pkgs.fetchurl {
    url = "https://vscode.download.prss.microsoft.com/dbazure/download/stable/e7fb5e96c0730b9deb70b33781f98e2f35975036/VSCode-darwin-universal.dmg";
    sha256 = "sha256-wPTei3Mzeg1sLngZtmiuMFZD0wQMFw8xO7GC3l9UJq0=";
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