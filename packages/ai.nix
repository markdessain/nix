{ pkgs, system, allowBroken, bigModel, smallModel }:	

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
        echo "rm --force \$HOME/.config/opencode && ln -s $out/.config/opencode/ \$HOME/.config/opencode && /nix/store/wg5alzs70c17bxizzdbnv7798v3lh8vc-opencode-0.5.13/bin/opencode --continue" > $out/bin/opencode
        chmod +x $out/bin/opencode

        ln -s ${pkgs.openai-whisper}/bin/whisper $out/bin/whisper
        ln -s /opt/homebrew/bin/tabby $out/bin/tabby
        ln -s /opt/homebrew/bin/llama-server $out/bin/llama-server
      elif [[ "${system}" == "aarch64-linux" ]]; then   
        echo "rm --force \$HOME/.config/opencode && ln -s $out/.config/opencode/ \$HOME/.config/opencode && /nix/store/cqcx120j5241qcjnbm6lg62kicn3znvq-opencode-0.5.13/bin/opencode --continue" > $out/bin/opencode
        chmod +x $out/bin/opencode
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

      mkdir -p $out/.config/opencode/

      cat <<EOT >> $out/.config/opencode/opencode.jsonc
        {
            "\$schema": "https://opencode.ai/config.json",
            "permission": {
              "edit": "ask",  
              "bash": "ask",
              "webfetch": "ask"
            },
            "agent": {
              "readonly": {
                "mode": "primary",
                "model": "${bigModel}",
                "permission": {
                  "edit": "deny",
                  "bash": "deny",
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
                  "todowrite": false,
                  "todoread": false,
                  "webfetch": true
                }
              },
              "build": {
                "mode": "primary",
                "model": "${bigModel}",
                "permission": {
                  "edit": "ask",
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
                  "todowrite": false,
                  "todoread": false,
                  "webfetch": true
                }
              },
              "code-reviewer": {
                "description": "Reviews code for best practices and potential issues",
                "mode": "primary",
                "model": "${smallModel}",
                "prompt": "You are a code reviewer. Focus on security, performance, and maintainability.",
                "permission": {
                  "edit": "deny",
                  "bash": "deny",
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

      mkdir -p $out/.config/opencode/agent
      cat <<EOT >> $out/.config/opencode/agent/golang-web.md
      ---
      description: Writing golang web applications with a UI and API
      mode: primary
      model: ${bigModel}
      permission:
        edit: allow
        bash: ask
        webfetch: allow
      tools:
        bash: true
        edit: true
        write: true
        read: true
        grep: true
        glob: true
        list: true
        patch: true
        todowrite: true
        todoread: true
        webfetch: true
      ---

      You are a golang expert. Write idiomatic, efficient, and well-structured Go code. 

      Follow best practices and design patterns. You are building a web application using Go where the client side will do limited user facing interactions but all processing will be done on the server side. 

      For example if the needs to rotate a image the api call will say which image to rotate and by how much. The server side will do the actual image processing. 

      You will use the standard library as much as possible but can use third party libraries if absolutely necessary. 

      Use Go modules for dependency management. Write clean, maintainable, and well-documented code. Ensure proper error handling and logging throughout the application.
      EOT


      echo 'cd ~/projects/tools && cd $(${pkgs.gum}/bin/gum choose $(ls)) && docker run -it -v "$HOME/.local/share/opencode:/root/.local/share/opencode" -v "$HOME/.config/opencode:/root/.config/opencode" -v "$HOME/.local/state/opencode:/root/.local/state/opencode" -v $(pwd):/project --workdir /project opencode ' > $out/bin/opencode-tools 
      chmod +x $out/bin/opencode-tools
      echo 'docker run -it -v "$HOME/.local/share/opencode:/root/.local/share/opencode" -v "$HOME/.config/opencode:/root/.config/opencode" -v "$HOME/.local/state/opencode:/root/.local/state/opencode" -v $(pwd):/project --workdir /project opencode ' > $out/bin/opencode-project 
      chmod +x $out/bin/opencode-project
    '';
}
