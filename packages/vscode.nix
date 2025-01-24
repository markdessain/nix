{ pkgs, unFreePkgs, system }:	

unFreePkgs.stdenv.mkDerivation rec {
    pname = "vscode";
    version = "0.1.0";
    phases = [ "installPhase" ];

    vcsodeWithExtension = unFreePkgs.vscode-with-extensions.override {
      vscodeExtensions = with unFreePkgs.vscode-extensions; []
      ++ unFreePkgs.vscode-utils.extensionsFromVscodeMarketplace [
        { publisher = "pomdtr"; name = "excalidraw-editor";version = "3.7.4"; sha256 = "sha256-hI+Qo8K+gLQuzKkaSq89D8vIxlYq9tMi31DgFiRzx0E="; }
        { publisher = "golang"; name = "go"; version = "0.45.0"; sha256 = "sha256-w/74OCM1uAJzjlJ91eDoac6knD1+Imwfy6pXX9otHsY="; }
        { publisher = "ms-azuretools"; name = "vscode-docker"; version = "1.29.4"; sha256 = "sha256-j2ACz2Ww5hddoDLHGdxnuQIqerP5ogZ80/wS+Aa5Gdo="; }
        { publisher = "ms-toolsai"; name = "jupyter"; version = "2024.9.1"; sha256 = "sha256-7ZNTIymw0LiM5TmDOxrwcyJGhxjdYuvaC4+Tb+YSASs="; }
        { publisher = "ms-python"; name = "python"; version = "2024.4.1"; sha256 = "sha256-n1zNxUV7vfVcHY0jjWtwBVzZkgjZipwMT5vSubuNtZw="; }
        { publisher = "evilz"; name = "vscode-reveal"; version = "4.3.3"; sha256 = "sha256-KqvQi0DMfHppX96qKHIkO9zIueBdGGV+6dYkpFEzFBo="; }
        { publisher = "ms-python"; name = "debugpy"; version = "2024.15.2025012001"; sha256 = "sha256-wiN+jHAZuzcHk5VRoQJeWgQf4LzTx5J7Nu0PdNuwzAY="; }
        { publisher = "ms-toolsai"; name = "jupyter-renderers"; version = "1.0.19"; sha256 = "sha256-15333GNQZhuJGOskz0FEi3mTdGO8ocfYpfZyyUbGYbM="; }
        { publisher = "ms-toolsai"; name = "jupyter-keymap"; version = "1.1.2"; sha256 = "sha256-9BLyBZzZ0Z6QQ05QSxFJYNZmZDc5O3eYkCxe/UsmKws="; }
        { publisher = "ms-toolsai"; name = "vscode-jupyter-cell-tags"; version = "0.1.9"; sha256 = "sha256-XODbFbOr2kBTzFc0JtjiDUcCDBX1Hd4uajlil7mhqPY="; }
        { publisher = "streetsidesoftware"; name = "code-spell-checker"; version = "4.0.35"; sha256 = "sha256-MfGlqOvfPK13Paoug3lSsdslqgbypuqvdqm9bagu1NY="; }
        { publisher = "rjmacarthy"; name = "twinny"; version = "3.21.14"; sha256 = "sha256-M0GcYRNEiSQS3cfFche2olYHr7kC+Pm8U5q6+voAV9c"; }
        { publisher = "Evidence"; name = "evidence-vscode"; version = "1.5.6"; sha256 = "sha256-uRiv3aarSeY8kHYeKYQzhDCEn16ZErgKQTUGoZtFuPc="; }
        { publisher = "svelte"; name = "svelte-vscode"; version = "109.5.2"; sha256 = "sha256-y1se0+LY1M+YKCm+gxBsyHLOQU6Xl095xP6z0xpf9mM="; }
      ];
    };

    installPhase = ''
      mkdir -p $out/bin

      echo "" > $out/bin/code2

      if [[ "${system}" == "aarch64-darwin" ]]; then
        echo "cp $out/config/settings.json \"\$HOME/Library/Application Support/VSCodium/User/settings.json\" " >> $out/bin/code2
        echo "cp $out/config/settings.json \"\$HOME/Library/Application Support/Code/User/settings.json\" " >> $out/bin/code2
      elif [[ "${system}" == "aarch64-linux" ]]; then
        echo "" >> $out/bin/code2
      else
        echo "" >> $out/bin/code2
      fi

      # Choose to use vscodium or vscode
      cat ${vcsodeWithExtension}/bin/code | sed 's,${unFreePkgs.vscode},${unFreePkgs.vscodium},g' | sed 's,/bin/code,/bin/codium,g' >> $out/bin/code2
      #cat ${vcsodeWithExtension}/bin/code >> $out/bin/code2
      chmod +x $out/bin/code2

      mkdir -p $out/config
      cat <<EOT >> $out/config/settings.json
        {
            "workbench.colorTheme": "Default Light Modern",
            "terminal.integrated.defaultProfile.osx": "zsh",
            "terminal.integrated.defaultProfile.linux": "zsh",
            "git.path": "${pkgs.git}/bin/git"
        }
      EOT

      echo "SHELL_RUN=\"source \$TEMP_NIX_START\" $out/bin/code2" >> $out/bin/code
      chmod +x $out/bin/code
    '';
}