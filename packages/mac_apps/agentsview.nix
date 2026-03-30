{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation rec {
  pname = "app-agentsview";
  version = "1.0.0";

  src = pkgs.fetchurl {
    url = "https://github.com/wesm/agentsview/releases/download/v0.17.1/AgentsView_0.17.1_aarch64.dmg";
    sha256 = "sha256-/lzMH5ujPGGkn4upvECOSX4p6gKry/38mlCO0cJq6h8=";
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

