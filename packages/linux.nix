{ pkgs, unFreePkgs, system }:	

pkgs.stdenv.mkDerivation rec {
    pname = "mac";
    version = "0.1.0";
    phases = [ "installPhase" ];

    zed = pkgs.fetchzip {
      url = "https://cloud.zed.dev/releases/stable/latest/download?asset=zed&arch=aarch64&os=linux&source=docs.tar.gz";
      sha256 = "sha256-xUNHx124Yuk1Iai0OYFS88ds7KXbgihcoP4GjfpURiQ=";
    };

    installPhase = ''
      mkdir -p $out/bin
      ln -s ${pkgs.ddcutil}/bin/ddcutil $out/bin/ddcutil
      ln -s ${pkgs.solaar}/bin/solaar $out/bin/solaar
      ln -s ${pkgs.bluez}/bin/bluetoothctl $out/bin/bluetoothctl

      ln -s ${pkgs.gccgo15}/bin/cc $out/bin/cc
      ln -s ${pkgs.gccgo15}/bin/gcc $out/bin/gcc
      ln -s ${pkgs.perl}/bin/perl $out/bin/perl
      ln -s ${pkgs.bubblewrap}/bin/bwrap $out/bin/bwrap

      # WAYLAND_DISPLAY="" ${zed}/bin/zed "$@"
      cat << 'EOF' > $out/bin/zed
      #!/bin/sh
      WAYLAND_DISPLAY="" ZED_BACKEND=vulkan ${zed}/bin/zed "$@"

      EOF
      chmod +x $out/bin/zed
    '';
}
