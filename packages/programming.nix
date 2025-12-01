{ pkgs, unFreePkgs, system }:	

pkgs.stdenv.mkDerivation rec {
    pname = "programming";
    version = "0.1.0";
    phases = [ "installPhase" ];
    
    installPhase = ''
      mkdir -p $out/bin
      ln -s ${pkgs.go}/bin/go $out/bin/go
      ln -s ${pkgs.gopls}/bin/gopls $out/bin/gopls
      ln -s ${pkgs.azure-cli}/bin/az $out/bin/az
      ln -s ${pkgs.azure-storage-azcopy}/bin/azcopy $out/bin/azcopy
      ln -s ${pkgs.go}/bin/gofmt $out/bin/gofmt
      ln -s ${pkgs.sqlc}/bin/sqlc $out/bin/sqlc
      ln -s ${pkgs.dbmate}/bin/dbmate $out/bin/dbmate
      ln -s ${pkgs.air}/bin/air $out/bin/air
      ln -s ${pkgs.go-task}/bin/task $out/bin/task
      ln -s ${pkgs.uv}/bin/uv $out/bin/uv
      ln -s ${pkgs.python311}/bin/python3 $out/bin/python3
      ln -s ${pkgs.python311}/bin/python3 $out/bin/python
      ln -s ${pkgs.python312}/bin/python3 $out/bin/python312
      ln -s ${pkgs.nodejs_20}/bin/node $out/bin/node
      ln -s ${pkgs.nodejs_20}/bin/npm $out/bin/npm
      ln -s ${pkgs.yarn-berry}/bin/yarn $out/bin/yarn
      ln -s ${pkgs.nodejs_20}/bin/npx $out/bin/npx
      ln -s ${pkgs.jdk17}/bin/java $out/bin/java
      ln -s ${pkgs.jdk17}/bin/javac $out/bin/javac
      ln -s ${pkgs.jdk17}/bin/jar $out/bin/jar
      ln -s ${pkgs.clang}/bin/clang $out/bin/clang
      ln -s ${pkgs.clang}/bin/clang++ $out/bin/clang++
      ln -s ${pkgs.llvm_18}/bin/dsymutil $out/bin/dsymutil
      ln -s ${pkgs.gnumake}/bin/make $out/bin/make
      ln -s ${pkgs.protobuf}/bin/protoc $out/bin/protoc
      ln -s ${pkgs.protoc-gen-go}/bin/protoc-gen-go $out/bin/protoc-gen-go
      ln -s ${pkgs.protoc-gen-go-grpc}/bin/protoc-gen-go-grpc $out/bin/protoc-gen-go-grpc
      ln -s ${pkgs.grpc-gateway}/bin/protoc-gen-grpc-gateway $out/bin/protoc-gen-grpc-gateway
      ln -s ${pkgs.pkg-config}/bin/pkg-config $out/bin/pkg-config
      ln -s ${pkgs.binutils_nogold}/bin/ld $out/bin/ld
      ln -s ${pkgs.pnpm}/bin/pnpm $out/bin/pnpm
      ln -s ${pkgs.deno}/bin/deno $out/bin/deno
      ln -s ${unFreePkgs.terraform}/bin/terraform $out/bin/terraform
      ln -s ${pkgs.redis}/bin/redis-cli $out/bin/redis-cli
      
      if [[ "${system}" == "aarch64-darwin" ]]; then
        # Temp while poetry is incompomatiable with old version of numpy
        mkdir -p $out/poetry
        export NIX_SSL_CERT_FILE="/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt"
        export SSL_CERT_FILE="/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt"
        export POETRY_HOME="$out/poetry"
        export POETRY_VERSION="1.8.5"
        ${pkgs.curl}/bin/curl -sSL https://install.python-poetry.org | ${pkgs.python3}/bin/python3 -
        ln -s $out/poetry/bin/poetry $out/bin/poetry
      elif [[ "${system}" == "aarch64-linux" ]]; then
        ln -s ${pkgs.poetry}/bin/poetry $out/bin/poetry
      fi

      echo 'mkdir -p ~/.config/kube' > $out/.env
      echo 'PKG_CONFIG_PATH=${pkgs.portaudio}/lib/pkgconfig' >> $out/.env 
      chmod +x $out/.env 

    '';

}
