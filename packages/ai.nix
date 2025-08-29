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
        echo "rm --force \$HOME/.config/opencode/AGENTS.md && cp $out/opencode/rules/AGENTS.md \$HOME/.config/opencode/AGENTS.md && OPENCODE_CONFIG=$out/opencode/opencode.jsonc /nix/store/wg5alzs70c17bxizzdbnv7798v3lh8vc-opencode-0.5.13/bin/opencode" > $out/bin/opencode
        chmod +x $out/bin/opencode

        ln -s ${pkgs.openai-whisper}/bin/whisper $out/bin/whisper
        ln -s /opt/homebrew/bin/tabby $out/bin/tabby
        ln -s /opt/homebrew/bin/llama-server $out/bin/llama-server
      elif [[ "${system}" == "aarch64-linux" ]]; then         
        echo "rm --force \$HOME/.config/opencode/AGENTS.md && cp $out/opencode/rules/AGENTS.md \$HOME/.config/opencode/AGENTS.md && OPENCODE_CONFIG=$out/opencode/opencode.jsonc /nix/store/cqcx120j5241qcjnbm6lg62kicn3znvq-opencode-0.5.13/bin/opencode" > $out/bin/opencode
        chmod +x $out/bin/opencode
        
        ln -s /nix/store/kakd108mxvgr5kcbxksq3qschqs4fnya-gemini-cli-0.1.5/bin/gemini $out/bin/gemini
        echo 'cd ~/projects/tools && cd $(${pkgs.gum}/bin/gum choose $(ls)) && /nix/store/kakd108mxvgr5kcbxksq3qschqs4fnya-gemini-cli-0.1.5/bin/gemini --sandbox-image gemini --yolo' > $out/bin/gemini-tools 
        chmod +x $out/bin/gemini-tools
      fi 

      mkdir -p $out/opencode

      mkdir -p $out/opencode/rules
      cat <<EOT >> $out/opencode/rules/AGENTS.md
      IMPORTANT: You are not allowed to run the sudo command. Instead tell the user what command they should run.
      EOT

      cat <<EOT >> $out/opencode/opencode.jsonc
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
                "model": "github-copilot/gpt-4.1",
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
                "model": "github-copilot/claude-sonnet-4",
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
                "model": "github-copilot/gpt-4.1",
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
                "model": "github-copilot/gpt-4.1",
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

      echo 'cd ~/projects/tools && cd $(${pkgs.gum}/bin/gum choose $(ls)) && docker run -it -v "$HOME/.local/share/opencode:/root/.local/share/opencode" -v "$HOME/.config/opencode:/root/.config/opencode" -v "$HOME/.local/state/opencode:/root/.local/state/opencode" -v $(pwd):/project --workdir /project opencode ' > $out/bin/opencode-tools 
      chmod +x $out/bin/opencode-tools
      echo 'docker run -it -v "$HOME/.local/share/opencode:/root/.local/share/opencode" -v "$HOME/.config/opencode:/root/.config/opencode" -v "$HOME/.local/state/opencode:/root/.local/state/opencode" -v $(pwd):/project --workdir /project opencode ' > $out/bin/opencode-project 
      chmod +x $out/bin/opencode-project
    '';
}
