{ pkgs, system, allowBroken }:	

pkgs.stdenv.mkDerivation rec {
    pname = "ai";
    version = "0.1.0";
    phases = [ "installPhase" ];
    
    buildInputs = [
      pkgs.ncurses
      pkgs.curl
      pkgs.python3
      pkgs.git
    ];

    # ln -s ${pkgs.tabby}/bin/tabby $out/bin/tabby
    # ln -s ${pkgs.tabby}/bin/llama-server $out/bin/llama-server
    # ln -s ${pkgs.tabby-agent}/bin/tabby-agent $out/bin/tabby-agent
    installPhase = ''
      mkdir -p $out/bin
      ln -s ${pkgs.ollama}/bin/ollama $out/bin/ollama
      ln -s ${pkgs.openai-whisper}/bin/whisper $out/bin/whisper
      ln -s ${allowBroken.open-webui}/bin/open-webui $out/bin/open-webui

      if [[ "${system}" == "aarch64-darwin" ]]; then
        ln -s /opt/homebrew/bin/tabby $out/bin/tabby
        ln -s /opt/homebrew/bin/llama-server $out/bin/llama-server
      fi 

    '';
}
