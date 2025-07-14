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

    # ln -s ${allowBroken.open-webui}/bin/open-webui $out/bin/open-webui

    # nix shell nixpkgs#gemini-cli --extra-experimental-features nix-command --extra-experimental-features flakes
    # nix shell nixpkgs#opencode --extra-experimental-features nix-command --extra-experimental-features flakes
    installPhase = ''
      mkdir -p $out/bin

      if [[ "${system}" == "aarch64-darwin" ]]; then
        ln -s ${pkgs.ollama}/bin/ollama $out/bin/ollama
        ln -s ${pkgs.openai-whisper}/bin/whisper $out/bin/whisper
        ln -s /opt/homebrew/bin/tabby $out/bin/tabby
        ln -s /opt/homebrew/bin/llama-server $out/bin/llama-server
      elif [[ "${system}" == "aarch64-linux" ]]; then         
        ln -s /nix/store/lb8a87ynrji2b0i0i7bwp1jjwzav8maq-opencode-0.1.194/bin/opencode $out/bin/opencode
        ln -s /nix/store/kakd108mxvgr5kcbxksq3qschqs4fnya-gemini-cli-0.1.5/bin/gemini $out/bin/gemini
        echo 'cd ~/projects/tools && cd $(${pkgs.gum}/bin/gum choose $(ls)) && /nix/store/kakd108mxvgr5kcbxksq3qschqs4fnya-gemini-cli-0.1.5/bin/gemini --sandbox-image gemini --yolo' > $out/bin/gemini-tools 
        chmod +x $out/bin/gemini-tools

      fi 

      echo 'cd ~/projects/tools && cd $(${pkgs.gum}/bin/gum choose $(ls)) && docker run -it -v "$HOME/.local/share/opencode:/root/.local/share/opencode" -v "$HOME/.config/opencode:/root/.config/opencode" -v "$HOME/.local/state/opencode:/root/.local/state/opencode" -v $(pwd):/project --workdir /project opencode ' > $out/bin/opencode-tools 
      chmod +x $out/bin/opencode-tools
      echo 'docker run -it -v "$HOME/.local/share/opencode:/root/.local/share/opencode" -v "$HOME/.config/opencode:/root/.config/opencode" -v "$HOME/.local/state/opencode:/root/.local/state/opencode" -v $(pwd):/project --workdir /project opencode ' > $out/bin/opencode-project 
      chmod +x $out/bin/opencode-project
    '';
}
