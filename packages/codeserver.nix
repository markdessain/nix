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
      { publisher = "saoudrizwan"; name = "claude-dev"; version = "3.13.1"; sha256 = "sha256-uN7TfvupqMsYg5hXEvTQ2HhD+uZU4b4fVsEf6biR2Ms="; }
     # { publisher = "TabbyML"; name = "vscode-tabby"; version = "1.20.0"; sha256 = "sha256-fATHvQyCCdYIrbUydEXVuR+++gju1ByIaKZvKLPaq9Y="; }
      { publisher = "TabbyML"; name = "vscode-tabby"; version = "1.28.0"; sha256 = "sha256-QuEGtsSP6MemP9wc9JnVicPOaa0t63ZTmEisH+IK2hY="; }
    ];
    # { publisher = "streetsidesoftware"; name = "code-spell-checker"; version = "4.0.13"; sha256 = "sha256-8VYg7NAFNW2aLZD0q25fgcrBfU1ptWF7Fy7I4SizTGc="; }

    vcsodeWithExtension = unFreePkgs.vscode-with-extensions.override {
      vscodeExtensions = allExtensions;
    };

    current_folder = builtins.toString ./.;

    # List of custom extensions
    # url = "file://${current_folder}/dataduck-0.0.1.vsix";
    dataDuck = builtins.fetchurl {
      url = "https://pub-bfa534868c66482daf271defe5d6d468.r2.dev/data-duck-vscode/v0.128.0/duckdb.vsix";
	    sha256 = "sha256:1wvhlahz2509zkwnhlpz7a5zvkfswnnillildwr6nzsm4lhvrxsm";
	  };

    extensionConfigFileText = unFreePkgs.vscode-utils.toExtensionJson allExtensions;
    
    installPhase = ''
      mkdir -p $out/bin
      mkdir -p $out/extensions

      echo "" > $out/bin/code2

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
      
      if [[ "${system}" == "aarch64-darwin" ]]; then
        echo "" >> $out/bin/code2
      elif [[ "${system}" == "aarch64-linux" ]]; then
        echo "cp $out/config/settings.json \"\$HOME/.local/share/code-server/User/settings.json\" " >> $out/bin/code2
      else
        echo "" >> $out/bin/code2
      fi

      echo "exec \"${unFreePkgs.code-server}/bin/code-server\" --extensions-dir \"$out/extensions\" \"$@\" " >> $out/bin/code2

      #cat ${vcsodeWithExtension}/bin/code | sed 's,${unFreePkgs.vscode},${unFreePkgs.code-server},g' | sed 's,/bin/code,/bin/code-server,g' >> $out/bin/code2
      chmod +x $out/bin/code2

      echo "#!${unFreePkgs.bash}/bin/bash -e" > $out/bin/code_web
      echo "SHELL_RUN=\"source \$TEMP_NIX_START\" $out/bin/code2" >> $out/bin/code_web
      chmod +x $out/bin/code_web

      mkdir -p $out/config
      cat <<EOT >> $out/config/settings.json
        {
            "workbench.colorTheme": "Default Light Modern",
            "terminal.integrated.defaultProfile.osx": "zsh",
            "terminal.integrated.defaultProfile.linux": "zsh",
            "dataduck.binary": "data-duck",
            "tabby.config.telemetry": true,
            "tabby.endpoint": "https://markdessain-tabby-wispy-rain-8623.fly.dev"
        }
      EOT

      echo "bind-addr: 0.0.0.0:8080" > $out/config/config.yaml
      echo "auth: none" >> $out/config/config.yaml

    '';
}
