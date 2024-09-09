{ pkgs, unFreePkgs, system }:	

unFreePkgs.stdenv.mkDerivation rec {
    pname = "vscode";
    version = "0.1.0";
    phases = [ "installPhase" ];

    vcsodeWithExtension = unFreePkgs.vscode-with-extensions.override {
      vscodeExtensions = with unFreePkgs.vscode-extensions; []
      ++ unFreePkgs.vscode-utils.extensionsFromVscodeMarketplace [
        { publisher = "pomdtr"; name = "excalidraw-editor";version = "3.7.4"; sha256 = "sha256-hI+Qo8K+gLQuzKkaSq89D8vIxlYq9tMi31DgFiRzx0E="; }
        { publisher = "golang"; name = "go"; version = "0.41.4"; sha256 = "sha256-ntrEI/l+UjzqGJmtyfVf/+sZJstZy3fm/PSWKTd7/Q0="; }
        { publisher = "ms-azuretools"; name = "vscode-docker"; version = "1.29.1"; sha256 = "sha256-uleZLIkfOxKan+U56fKEwUjaleig07zdEwQKzsAzan0="; }
        { publisher = "ms-toolsai"; name = "jupyter"; version = "2024.3.0"; sha256 = "sha256-m8sJ3c34lrV5c484s+wlOpQc8IWhDvhlMbWCJeo0en4="; }
        { publisher = "ms-python"; name = "python"; version = "2024.4.1"; sha256 = "sha256-n1zNxUV7vfVcHY0jjWtwBVzZkgjZipwMT5vSubuNtZw="; }
        { publisher = "evilz"; name = "vscode-reveal"; version = "4.3.3"; sha256 = "sha256-KqvQi0DMfHppX96qKHIkO9zIueBdGGV+6dYkpFEzFBo="; }
        { publisher = "ms-python"; name = "debugpy"; version = "2024.8.0"; sha256 = "sha256-gvuYfyVIehy3ItJVfQbL/d8gO2KOl2rg9pBrmJuZeME="; }
        { publisher = "ms-toolsai"; name = "jupyter-renderers"; version = "1.0.18"; sha256 = "sha256-4EKXaWsafonBK7TftjVUBK3ujqD+OguXV0y/bWoWTyk="; }
        { publisher = "ms-toolsai"; name = "jupyter-keymap"; version = "1.1.2"; sha256 = "sha256-9BLyBZzZ0Z6QQ05QSxFJYNZmZDc5O3eYkCxe/UsmKws="; }
        { publisher = "ms-toolsai"; name = "vscode-jupyter-cell-tags"; version = "0.1.9"; sha256 = "sha256-XODbFbOr2kBTzFc0JtjiDUcCDBX1Hd4uajlil7mhqPY="; }
      ];
    };

    installPhase = ''
      mkdir -p $out/bin

      echo "" > $out/bin/code2

      if [[ "${system}" == "aarch64-darwin" ]]; then
        echo "cp $out/config/settings.json \"\$HOME/Library/Application Support/VSCodium/User/settings.json\" " >> $out/bin/code2
      elif [[ "${system}" == "aarch64-linux" ]]; then
        echo "" >> $out/bin/code2
      else
        echo "" >> $out/bin/code2
      fi

      cat ${vcsodeWithExtension}/bin/code | sed 's,${unFreePkgs.vscode},${unFreePkgs.vscodium},g' | sed 's,/bin/code,/bin/codium,g' >> $out/bin/code2
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