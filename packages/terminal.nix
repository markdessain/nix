{ pkgs }:	

pkgs.stdenv.mkDerivation rec {
    pname = "terminal";
    version = "0.1.0";
    phases = [ "installPhase" ];

    installPhase = ''
      mkdir -p $out/bin
      echo "echo 'Hello $USER' | ${pkgs.cowsay}/bin/cowsay" > $out/bin/startup 
      echo 'PATH_ENV=$(for var in "$@"; do echo -n "$var/bin:"; done | sed "s/:$//")' >> $out/bin/startup
      echo 'LOAD_ENV=$(for var in "$@"; do echo -n "if [ -f $var/.env ]; then source $var/.env; fi; "; done | sed "s/:$//")' >> $out/bin/startup
      echo 'FILE=$(mktemp)' >> $out/bin/startup
      echo 'echo "export PATH=$HOME/bin:$PATH_ENV" >> $FILE' >> $out/bin/startup
      echo 'echo "export SHELL_NAME=alpha" >> $FILE' >> $out/bin/startup
      echo 'echo "$LOAD_ENV" >> $FILE' >> $out/bin/startup
      echo 'export TEMP_NIX_START=$FILE' >> $out/bin/startup
      chmod +x $out/bin/startup 

      ln -s /usr/bin/open $out/bin/open
      ln -s ${pkgs.git}/bin/git $out/bin/git
      ln -s ${pkgs.zsh}/bin/zsh $out/bin/zsh
      ln -s ${pkgs.bash}/bin/bash $out/bin/bash
      ln -s ${pkgs.bash}/bin/sh $out/bin/sh
      ln -s ${pkgs.atuin}/bin/atuin $out/bin/atuin
      ln -s /usr/bin/locale $out/bin/locale
      ln -s ${pkgs.iconv}/bin/iconv $out/bin/iconv
    '';
}