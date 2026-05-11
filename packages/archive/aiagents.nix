{ pkgs, system, allowBroken, bigModel, smallModel }:	

pkgs.stdenv.mkDerivation rec {
    pname = "aiagents";
    version = "0.1.0";
    phases = [ "installPhase" ];
    
    buildInputs = [
    ];

    installPhase = ''
      mkdir -p $out/bin

      cat <<EOT >> $out/bin/ai-config-sync

        mkdir -p \$HOME/.config/opencode/agent/

        rm --force \$HOME/.config/opencode/opencode.jsonc
        cp $out/.config/opencode/opencode.jsonc \$HOME/.config/opencode/opencode.jsonc

        rm --force \$HOME/.config/opencode/AGENTS.md
        cp $out/.config/opencode/AGENTS.md \$HOME/.config/opencode/AGENTS.md

        rm --force \$HOME/.roborev/config.toml
        cp $out/.config/roborev/config.toml \$HOME/.roborev/config.toml
      
      EOT
      chmod +x $out/bin/ai-config-sync

      mkdir -p $out/.config/roborev/
      cat <<EOT >> $out/.config/roborev/config.toml
        server_addr = '127.0.0.1:7373'
        max_workers = 4
        review_context_count = 3
        reuse_review_session_lookback = 0
        # Default agent when no workflow-specific agent is set.
        default_agent = 'opencode'
        default_model = '${smallModel}'
        job_timeout_minutes = 30

        [sync]
        enabled = false

        [ci]
        enabled = false

        [advanced]
        # Enable the advanced Tasks workflow in the TUI.
        tasks_enabled = false

        # macOS
        [[hooks]]
        event = "review.completed"
        command = "osascript -e 'display notification \"Review done for {repo_name} ({sha}): {verdict}\" with title \"roborev\"'"
      EOT

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

      mkdir -p $out/.config/opencode/agent

      echo 'cd ~/projects/tools && cd $(${pkgs.gum}/bin/gum choose $(ls)) && docker run -it -v "$HOME/.local/share/opencode:/root/.local/share/opencode" -v "$HOME/.config/opencode:/root/.config/opencode" -v "$HOME/.local/state/opencode:/root/.local/state/opencode" -v $(pwd):/project --workdir /project opencode ' > $out/bin/opencode-tools 
      chmod +x $out/bin/opencode-tools
      echo 'docker run -it -v "$HOME/.local/share/opencode:/root/.local/share/opencode" -v "$HOME/.config/opencode:/root/.config/opencode" -v "$HOME/.local/state/opencode:/root/.local/state/opencode" -v $(pwd):/project --workdir /project opencode ' > $out/bin/opencode-project 
      chmod +x $out/bin/opencode-project
    '';
}
