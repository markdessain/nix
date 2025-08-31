{ pkgs, system }:	

pkgs.stdenv.mkDerivation rec {
    pname = "terminal";
    version = "0.1.0";
    phases = [ "installPhase" ];

    installPhase = ''
      mkdir -p $out/bin
      echo "echo 'Welcome Mark - it is' $(date '+%Y-%m-%d') | ${pkgs.cowsay}/bin/cowsay && echo 'Useful commands:' && echo ' - sync-config' && echo ' - code-desktop' && echo ' - backup'" > $out/bin/startup 
      echo 'PATH_ENV=$(for var in "$@"; do echo -n "$var/bin:"; done | sed "s/:$//")' >> $out/bin/startup
      echo 'LOAD_ENV=$(for var in "$@"; do echo -n "if [ -f $var/.env ]; then source $var/.env; fi; "; done | sed "s/:$//")' >> $out/bin/startup
      echo 'FILE=$(mktemp)' >> $out/bin/startup
      echo 'echo "export PATH=$HOME/bin:$PATH_ENV" >> $FILE' >> $out/bin/startup
      echo 'echo "export SHELL_NAME=alpha" >> $FILE' >> $out/bin/startup
      echo 'echo "$LOAD_ENV" >> $FILE' >> $out/bin/startup
      echo 'export TEMP_NIX_START=$FILE' >> $out/bin/startup
      echo 'echo $PATH > $HOME/.nixpath' >> $out/bin/startup
      chmod +x $out/bin/startup 

      ln -s /usr/bin/open $out/bin/open
      ln -s ${pkgs.git}/bin/git $out/bin/git
      ln -s ${pkgs.zsh}/bin/zsh $out/bin/zsh
      ln -s ${pkgs.bash}/bin/bash $out/bin/bash
      ln -s ${pkgs.bash}/bin/sh $out/bin/sh

      if [[ "${system}" == "aarch64-darwin" ]]; then
        ln -s /opt/homebrew/bin/atuin $out/bin/atuin
      elif [[ "${system}" == "aarch64-linux" ]]; then
        ln -s ${pkgs.atuin}/bin/atuin $out/bin/atuin
      fi

      ln -s /usr/bin/locale $out/bin/locale
      ln -s ${pkgs.iconv}/bin/iconv $out/bin/iconv
      ln -s ${pkgs.glow}/bin/glow $out/bin/glow
      ln -s ${pkgs.goreman}/bin/goreman $out/bin/goreman

      if [[ "${system}" == "aarch64-darwin" ]]; then
        ln -s /usr/bin/pbcopy $out/bin/pbcopy
        ln -s /usr/bin/pbpaste $out/bin/pbpaste
      elif [[ "${system}" == "aarch64-linux" ]]; then
        alias pbcopy='xsel — clipboard — input'
        alias pbpaste='xsel — clipboard — output'
      fi
    '';
}