{ unFreePkgs, system }:	

unFreePkgs.stdenv.mkDerivation rec {
    pname = "codeserver";
    version = "0.1.0";
    phases = [ "installPhase" ];

    buildInputs = [
      unFreePkgs.unzip
      unFreePkgs.jq
    ];

    allExtensions = unFreePkgs.vscode-utils.extensionsFromVscodeMarketplace [
      { publisher = "pomdtr"; name = "excalidraw-editor";version = "3.7.4"; sha256 = "sha256-hI+Qo8K+gLQuzKkaSq89D8vIxlYq9tMi31DgFiRzx0E="; }
      { publisher = "golang"; name = "go"; version = "0.41.4"; sha256 = "sha256-ntrEI/l+UjzqGJmtyfVf/+sZJstZy3fm/PSWKTd7/Q0="; }
      { publisher = "ms-python"; name = "python"; version = "2024.4.1"; sha256 = "sha256-n1zNxUV7vfVcHY0jjWtwBVzZkgjZipwMT5vSubuNtZw="; }
    ];
    # { publisher = "streetsidesoftware"; name = "code-spell-checker"; version = "4.0.13"; sha256 = "sha256-8VYg7NAFNW2aLZD0q25fgcrBfU1ptWF7Fy7I4SizTGc="; }

    vcsodeWithExtension = unFreePkgs.vscode-with-extensions.override {
      vscodeExtensions = allExtensions;
    };

    current_folder = builtins.toString ./.;

    # List of custom extensions
    # url = "file://${current_folder}/dataduck-0.0.1.vsix";
    dataDuck = builtins.fetchurl {
      url = "https://pub-bfa534868c66482daf271defe5d6d468.r2.dev/data-duck-vscode/latest/duckdb.vsix";
	    sha256 = "sha256:0dx9r2d93z726l19w7ya08f0x9vvv8yqagwjb21f2mkwyqavhfdp";
	  };

    extensionConfigFileText = unFreePkgs.vscode-utils.toExtensionJson allExtensions;
    
    installPhase = ''
      mkdir -p $out/bin
      mkdir -p $out/extensions

      echo "" > $out/bin/code2

      if [[ "${system}" == "aarch64-darwin" ]]; then
        echo "" >> $out/bin/code2
      elif [[ "${system}" == "aarch64-linux" ]]; then
        echo "cp $out/config/settings.json \"\$HOME/.local/share/code-server/User/settings.json\" " >> $out/bin/code2

        for input in $allExtensions; do ln -s $input/share/vscode/extensions/$(ls -AU $input/share/vscode/extensions/ | head -1) $out/extensions/$(ls -AU $input/share/vscode/extensions/ | head -1); done
        echo "$extensionConfigFileText" > $out/extensions/extensions.json

        # Install Custom extension
        # {
        #    "identifier":{
        #       "id":"__NAME__"
        #    },
        #    "version":"_VERSION__",
        #    "location":{
        #       "$mid":1,
        #       "fsPath":"__PATH__/__NAME__-__VERSION__",
        #       "external":"__PATH__/__NAME__-__VERSION__",
        #       "path":"__PATH__/__NAME__-__VERSION__",
        #       "scheme":"file"
        #    },
        #    "relativeLocation":"__NAME__-__VERSION__",
        #    "metadata":{
        #       "installedTimestamp":1738577399412,
        #       "pinned":true,
        #       "source":"vsix"
        #    }
        # }
        PACKAGE_SETTING='{"identifier":{"id":"__NAME__"},"version":"__VERSION__","location":{"$mid":1,"fsPath":"__PATH__/__NAME__-__VERSION__","external":"__PATH__/__NAME__-__VERSION__","path":"__PATH__/__NAME__-__VERSION__","scheme":"file"},"relativeLocation":"__NAME__-__VERSION__","metadata":{"installedTimestamp":0,"pinned":true,"source":"vsix"}}'

        # For each extension do the following:
        data_duck=$(echo $PACKAGE_SETTING | sed "s/__NAME__/undefined_publisher.dataduck/g" | sed "s/__VERSION__/0.0.1/g" | sed "s|__PATH__|$out/extensions|g")
        mkdir -p $out/extensions/undefined_publisher.dataduck-0.0.1
        ${unFreePkgs.unzip}/bin/unzip $dataDuck -d $out/duck
        mv $out/duck/extension/* $out/extensions/undefined_publisher.dataduck-0.0.1

        echo "$extensionConfigFileText" | jq -r ". + [$data_duck]" > $out/extensions/extensions.json

      else
        echo "" >> $out/bin/code2
      fi

      echo "exec \"${unFreePkgs.code-server}/bin/code-server\" --extensions-dir \"$out/extensions\" \"$@\" " >> $out/bin/code2

      #cat ${vcsodeWithExtension}/bin/code | sed 's,${unFreePkgs.vscode},${unFreePkgs.code-server},g' | sed 's,/bin/code,/bin/code-server,g' >> $out/bin/code2
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
