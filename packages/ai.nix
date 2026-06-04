{ pkgs, unstablePkgs, system, allowBroken, bigModel, smallModel, openspec }:	

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

    opencode_app = if system == "aarch64-darwin" then pkgs.callPackage ./mac_apps/opencode.nix {} else "missing";
    agentsview_app = if system == "aarch64-darwin" then pkgs.callPackage ./mac_apps/agentsview.nix {} else "missing"; 
    ollama_app = if system == "aarch64-darwin" then pkgs.callPackage ./mac_apps/ollama.nix {} else "missing"; 
    ollama = if system == "aarch64-linux" then pkgs.callPackage ./ollama.nix {} else "missing";

    installPhase = ''
      mkdir -p $out/bin 

      if [[ "${system}" == "aarch64-darwin" ]]; then   
        ln -s ${pkgs.openai-whisper}/bin/whisper $out/bin/whisper
        ln -s /usr/local/bin/ollama $out/bin/ollama
      elif [[ "${system}" == "aarch64-linux" ]]; then   
        ln -s ${ollama}/bin/ollama $out/bin/ollama
        
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

      if [[ "${system}" == "aarch64-darwin" ]]; then   
        mkdir -p $out/Applications
        ln -s ${opencode_app}/Applications/OpenCode.app $out/Applications/OpenCode.app
        ln -s ${agentsview_app}/Applications/AgentsView.app $out/Applications/AgentsView.app
        ln -s ${ollama_app}/Applications/Ollama.app $out/Applications/Ollama.app
      fi


      mkdir -p $out/.config/opencode/

      cat <<EOT >> $out/.config/opencode/opencode.jsonc
        {
            "\$schema": "https://opencode.ai/config.json",
            "permission": {
              "edit": "allow",  
              "bash": {
                "rm": "ask",
                "git push": "ask",
                "openspec": "allow",
                "poetry": "allow",
              },
              "webfetch": "ask"
            },
            "agent": {
              "build": {
                "mode": "primary",
                "model": "${bigModel}",
                "permission": {
                  "edit": "allow",
                  "bash": {
                    "*": "allow",
                    "rm": "ask",
                    "git push": "ask",
                  },
                  "webfetch": "ask"
                },
                "tools": {
                  "bash": true,
                  "edit": true,
                  "write": true,
                  "read": true,
                  "grep": true,
                  "glob": true,
                  "list": true,
                  "patch": false,
                  "skills": true,
                  "todowrite": false,
                  "todoread": false,
                  "webfetch": true
                }
              },
              "plan": {
                "mode": "primary",
                "model": "${smallModel}",
                "permission": {
                  "edit": "deny",
                  "bash": "ask",
                  "webfetch": "ask"
                },
                "tools": {
                  "bash": true,
                  "edit": false,
                  "write": false,
                  "read": true,
                  "grep": true,
                  "glob": true,
                  "list": true,
                  "patch": false,
                  "skills": true,
                  "todowrite": false,
                  "todoread": false,
                  "webfetch": true
                }
              }
            }
          }
      EOT

      cat <<EOT >> $out/.config/opencode/AGENTS.md
      IMPORTANT: You are not allowed to run the sudo command. Instead tell the user what command they should run.
      EOT

      cat <<EOT >> $out/bin/ai-config-sync

        mkdir -p \$HOME/.config/opencode/agent/

        rm --force \$HOME/.config/opencode/opencode.jsonc
        cp $out/.config/opencode/opencode.jsonc \$HOME/.config/opencode/opencode.jsonc

        rm --force \$HOME/.config/opencode/AGENTS.md
        cp $out/.config/opencode/AGENTS.md \$HOME/.config/opencode/AGENTS.md
      
      EOT
      chmod +x $out/bin/ai-config-sync
    '';
}
