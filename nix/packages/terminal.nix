{ pkgs }:	

pkgs.stdenv.mkDerivation rec {
    pname = "terminal";
    version = "0.1.0";
    phases = [ "buildPhase" "installPhase" ];

    buildInputs = [
      pkgs.cowsay
      pkgs.git
      pkgs.zsh
      pkgs.oh-my-zsh
      pkgs.atuin
    ];

    buildPhase = ''
    '';

    installPhase = ''
      mkdir -p $out/bin
      echo "echo 'Hello $USER' | ${pkgs.cowsay}/bin/cowsay" > $out/bin/startup 

    
      chmod +x $out/bin/startup 

      ln -s ${pkgs.git}/bin/git $out/bin/git
      ln -s ${pkgs.zsh}/bin/zsh $out/bin/zsh
      ln -s ${pkgs.atuin}/bin/atuin $out/bin/atuin
      ln -s /usr/bin/locale $out/bin/locale
    '';
}