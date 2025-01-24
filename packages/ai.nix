{ pkgs }:	

pkgs.stdenv.mkDerivation rec {
    pname = "ai";
    version = "0.1.0";
    phases = [ "installPhase" ];
    
    # ln -s ${pkgs.open-webui}/bin/open-webui $out/bin/open-webui
    
    installPhase = ''
      mkdir -p $out/bin
      ln -s ${pkgs.ollama}/bin/ollama $out/bin/ollama
      ln -s ${pkgs.openai-whisper}/bin/whisper $out/bin/whisper
    '';
}