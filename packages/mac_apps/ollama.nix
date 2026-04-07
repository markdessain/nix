{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation rec {
  pname = "app-ollama";
  version = "1.0.0";

  src = pkgs.fetchurl {
    url = "https://github.com/ollama/ollama/releases/download/v0.20.2/Ollama.dmg";
    sha256 = "sha256-fsuvSGdcm4VuMDt6vqK5cc2CWKoQyjJm8694vGIXqbg=";
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



