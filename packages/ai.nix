{ pkgs, system, allowBroken, bigModel, smallModel }:	

pkgs.stdenv.mkDerivation rec {
    pname = "ai";
    version = "0.1.0";
    phases = [ "installPhase" ];
    
    buildInputs = [
      pkgs.ncurses
      pkgs.wget
      pkgs.curl
      pkgs.unzip
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

        export NIX_SSL_CERT_FILE="/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt"
        export SSL_CERT_FILE="/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt"
        export HOME=$out
        ${pkgs.nodejs_20}/bin/npm install --prefix $out @fission-ai/openspec@latest

        ln -s $out/node_modules/@fission-ai/openspec/bin/openspec.js $out/bin/openspec

        wget  https://github.com/sst/opencode/releases/download/v0.15.16/opencode-darwin-arm64.zip
        unzip opencode-darwin-arm64.zip
        mv ./opencode $out/bin/opencode-binary
        chmod +x $out/bin/opencode-binary

        ln -s ${pkgs.openai-whisper}/bin/whisper $out/bin/whisper
        ln -s /opt/homebrew/bin/tabby $out/bin/tabby
        ln -s /opt/homebrew/bin/llama-server $out/bin/llama-server
      elif [[ "${system}" == "aarch64-linux" ]]; then   

        echo "SKIP"
        #wget  https://github.com/sst/opencode/releases/download/v0.15.16/opencode-linux-arm64.zip
        #unzip opencode-linux-arm64.zip
        #mv ./opencode $out/bin/opencode-binary
        #chmod +x $out/bin/opencode-binary
      fi 

      cat <<EOT >> $out/bin/ai-project
        PROJECT=\$(${pkgs.gum}/bin/gum file --height 15 --directory .)

        retVal=\$?
        if [ \$retVal -ne 0 ]; then
          echo "Quit"
        else
          cd \$PROJECT
          opencode
        fi
      EOT
      chmod +x $out/bin/ai-project

      echo 'cd ~/projects/tools && cd $(${pkgs.gum}/bin/gum choose $(ls)) && docker run -it -v "$HOME/.local/share/opencode:/root/.local/share/opencode" -v "$HOME/.config/opencode:/root/.config/opencode" -v "$HOME/.local/state/opencode:/root/.local/state/opencode" -v $(pwd):/project --workdir /project opencode ' > $out/bin/opencode-tools 
      chmod +x $out/bin/opencode-tools
      echo 'docker run -it -v "$HOME/.local/share/opencode:/root/.local/share/opencode" -v "$HOME/.config/opencode:/root/.config/opencode" -v "$HOME/.local/state/opencode:/root/.local/state/opencode" -v $(pwd):/project --workdir /project opencode ' > $out/bin/opencode-project 
      chmod +x $out/bin/opencode-project
    '';
}
