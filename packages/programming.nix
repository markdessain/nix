{ pkgs }:	

pkgs.stdenv.mkDerivation rec {
    pname = "programming";
    version = "0.1.0";
    phases = [ "installPhase" ];

    installPhase = ''
      mkdir -p $out/bin
      ln -s ${pkgs.go}/bin/go $out/bin/go
      ln -s ${pkgs.gopls}/bin/gopls $out/bin/gopls
      ln -s ${pkgs.go}/bin/gofmt $out/bin/gofmt
      ln -s ${pkgs.python311}/bin/python3 $out/bin/python3
      ln -s ${pkgs.python311}/bin/python3 $out/bin/python
      ln -s ${pkgs.poetry}/bin/poetry $out/bin/poetry
      ln -s ${pkgs.jdk17}/bin/java $out/bin/java
      ln -s ${pkgs.jdk17}/bin/javac $out/bin/javac
      ln -s ${pkgs.jdk17}/bin/jar $out/bin/jar
    '';

}
