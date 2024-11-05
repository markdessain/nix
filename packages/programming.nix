{ pkgs }:	

pkgs.stdenv.mkDerivation rec {
    pname = "programming";
    version = "0.1.0";
    phases = [ "installPhase" ];

    buildInputs = [
      pkgs.portaudio
    ];

    installPhase = ''
      mkdir -p $out/bin
      ln -s ${pkgs.go}/bin/go $out/bin/go
      ln -s ${pkgs.gopls}/bin/gopls $out/bin/gopls
      ln -s ${pkgs.azure-cli}/bin/az $out/bin/az
      ln -s ${pkgs.go}/bin/gofmt $out/bin/gofmt
      ln -s ${pkgs.sqlc}/bin/sqlc $out/bin/sqlc
      ln -s ${pkgs.air}/bin/air $out/bin/air
      ln -s ${pkgs.go-task}/bin/task $out/bin/task
      ln -s ${pkgs.python311}/bin/python3 $out/bin/python3
      ln -s ${pkgs.python311}/bin/python3 $out/bin/python
      ln -s ${pkgs.poetry}/bin/poetry $out/bin/poetry
      ln -s ${pkgs.nodejs_20}/bin/node $out/bin/node
      ln -s ${pkgs.nodejs_20}/bin/npm $out/bin/npm
      ln -s ${pkgs.nodejs_20}/bin/npx $out/bin/npx
      ln -s ${pkgs.jdk17}/bin/java $out/bin/java
      ln -s ${pkgs.jdk17}/bin/javac $out/bin/javac
      ln -s ${pkgs.jdk17}/bin/jar $out/bin/jar
      ln -s ${pkgs.clang}/bin/clang $out/bin/clang
      ln -s ${pkgs.clang}/bin/clang++ $out/bin/clang++
      ln -s ${pkgs.gnumake}/bin/make $out/bin/make
      ln -s ${pkgs.protobuf_26}/bin/protoc $out/bin/protoc
      ln -s ${pkgs.protoc-gen-go}/bin/protoc-gen-go $out/bin/protoc-gen-go
      ln -s ${pkgs.protoc-gen-go-grpc}/bin/protoc-gen-go-grpc $out/bin/protoc-gen-go-grpc
      ln -s ${pkgs.grpc-gateway}/bin/protoc-gen-grpc-gateway $out/bin/protoc-gen-grpc-gateway
      ln -s ${pkgs.pkg-config}/bin/pkg-config $out/bin/pkg-config
      ln -s ${pkgs.binutils_nogold}/bin/ld $out/bin/ld
      
    '';

}
