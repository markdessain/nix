{ unFreePkgs, system }:	

unFreePkgs.stdenv.mkDerivation rec {
    pname = "codeserver";
    version = "0.1.0";
    phases = [ "installPhase" ];

    vcsodeWithExtension = unFreePkgs.vscode-with-extensions.override {
      vscodeExtensions = with unFreePkgs.vscode-extensions; []
      ++ unFreePkgs.vscode-utils.extensionsFromVscodeMarketplace [
        { publisher = "pomdtr"; name = "excalidraw-editor";version = "3.7.4"; sha256 = "sha256-hI+Qo8K+gLQuzKkaSq89D8vIxlYq9tMi31DgFiRzx0E="; }
        { publisher = "golang"; name = "go"; version = "0.41.4"; sha256 = "sha256-ntrEI/l+UjzqGJmtyfVf/+sZJstZy3fm/PSWKTd7/Q0="; }
        { publisher = "ms-python"; name = "python"; version = "2024.4.1"; sha256 = "sha256-n1zNxUV7vfVcHY0jjWtwBVzZkgjZipwMT5vSubuNtZw="; }
      ];
    };

    installPhase = ''
      mkdir -p $out/bin

      echo "" > $out/bin/code2

      if [[ "${system}" == "aarch64-darwin" ]]; then
        echo "" >> $out/bin/code2
      elif [[ "${system}" == "aarch64-linux" ]]; then
        echo "cp $out/config/settings.json \"\$HOME/.local/share/code-server/User/settings.json\" " >> $out/bin/code2
      else
        echo "" >> $out/bin/code2
      fi

      cat ${vcsodeWithExtension}/bin/code | sed 's,${unFreePkgs.vscode},${unFreePkgs.code-server},g' | sed 's,/bin/code,/bin/code-server,g' >> $out/bin/code2
      chmod +x $out/bin/code2

      echo "#!${unFreePkgs.bash}/bin/bash -e" > $out/bin/code
      echo "SHELL_RUN=\"source \$TEMP_NIX_START\" $out/bin/code2" >> $out/bin/code
      chmod +x $out/bin/code

      mkdir -p $out/config
      cat <<EOT >> $out/config/settings.json
        {
            "workbench.colorTheme": "Default Light Modern",
            "terminal.integrated.defaultProfile.osx": "zsh",
            "terminal.integrated.defaultProfile.linux": "zsh"
        }
      EOT

      echo "bind-addr: 0.0.0.0:8080" > $out/config/config.yaml
      echo "auth: none" >> $out/config/config.yaml

    '';
}
