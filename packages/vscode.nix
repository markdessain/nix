{ pkgs, unFreePkgs, system }:	

unFreePkgs.stdenv.mkDerivation rec {
    pname = "vscode";
    version = "0.1.0";
    phases = [ "installPhase" ];

    buildInputs = [
      pkgs.unzip
      pkgs.jq
    ];

    allExtensions = unFreePkgs.vscode-utils.extensionsFromVscodeMarketplace [
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
      { publisher = "Evidence"; name = "evidence-vscode"; version = "1.5.6"; sha256 = "sha256-uRiv3aarSeY8kHYeKYQzhDCEn16ZErgKQTUGoZtFuPc="; }
      { publisher = "svelte"; name = "svelte-vscode"; version = "109.5.2"; sha256 = "sha256-y1se0+LY1M+YKCm+gxBsyHLOQU6Xl095xP6z0xpf9mM="; }
      { publisher = "ms-vscode"; name = "wasm-wasi-core"; version = "1.0.2"; sha256 = "sha256-hrzPNPaG8LPNMJq/0uyOS8jfER1Q0CyFlwR42KmTz8g="; }
      { publisher = "saoudrizwan"; name = "claude-dev"; version = "3.13.1"; sha256 = "sha256-uN7TfvupqMsYg5hXEvTQ2HhD+uZU4b4fVsEf6biR2Ms="; }
    ];
    # { publisher = "rjmacarthy"; name = "twinny"; version = "3.21.14"; sha256 = "sha256-M0GcYRNEiSQS3cfFche2olYHr7kC+Pm8U5q6+voAV9c"; }
    # { publisher = "Continue"; name = "continue"; version = "0.8.62"; sha256 = "sha256-BsOPfZ8973YomdWsLm5LShFiO/sU5k0ZTASZReRtE8o="; }
   
    vcsodeWithExtension = unFreePkgs.vscode-with-extensions.override {
      vscodeExtensions = allExtensions;
    };

    current_folder = builtins.toString ./.;

    # List of custom extensions
    dataDuck = builtins.fetchurl {
      url = "https://pub-bfa534868c66482daf271defe5d6d468.r2.dev/data-duck-vscode/v0.128.0/duckdb.vsix";
	    sha256 = "sha256:1wvhlahz2509zkwnhlpz7a5zvkfswnnillildwr6nzsm4lhvrxsm";
	  };

    extensionConfigFileText = unFreePkgs.vscode-utils.toExtensionJson allExtensions;

    # Bug with installing - fix here: https://github.com/nix-community/home-manager/issues/6532 
    vscodium = unFreePkgs.vscodium.overrideAttrs (old: {
      installPhase = "whoami\n " + old.installPhase;
    });
    
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

      # Add all the extensions in a list
      echo "$extensionConfigFileText" | jq -r ". + [$data_duck]" > $out/extensions/extensions.json
      #echo "$extensionConfigFileText" | jq -r ". + [$data_duck, $another_extension]" > $out/extensions/extensions.json

      if [[ "${system}" == "aarch64-darwin" ]]; then
        echo "cp $out/config/settings.json \"\$HOME/Library/Application Support/VSCodium/User/settings.json\" " >> $out/bin/code2
      elif [[ "${system}" == "aarch64-linux" ]]; then
        echo "cp $out/config/settings.json \"\$HOME/.config/VSCodium/User/settings.json\" " >> $out/bin/code2
      else
        echo "" >> $out/bin/code2
      fi

      # Choose to use vscodium or vscode
      echo "exec \"${vscodium}/bin/codium\" --extensions-dir \"$out/extensions\" \"\$@\" " >> $out/bin/code2
      
      chmod +x $out/bin/code2

      mkdir -p $out/config
      cat <<EOT >> $out/config/settings.json
        {
            "workbench.colorTheme": "Default Light Modern",
            "terminal.integrated.defaultProfile.osx": "zsh",
            "terminal.integrated.defaultProfile.linux": "zsh",
            "git.path": "${pkgs.git}/bin/git",
            "dataduck.binary": "data-duck"
        }
      EOT

      echo "SHELL_RUN=\"source \$TEMP_NIX_START\" $out/bin/code2" >> $out/bin/code_desktop
      chmod +x $out/bin/code_desktop

      echo "SHELL_RUN=\"source \$TEMP_NIX_START\" $out/bin/code2" >> $out/bin/code-desktop
      chmod +x $out/bin/code-desktop
    '';
}
