{ pkgs }:	

pkgs.stdenv.mkDerivation rec {
    pname = "tools";
    version = "0.1.0";
    phases = [ "installPhase" ];

    installPhase = ''
      mkdir -p $out/bin
      ln -s ${pkgs.rbw}/bin/rbw $out/bin/rbw
      ln -s ${pkgs.rbw}/bin/rbw-agent $out/bin/rbw-agent
      ln -s ${pkgs.atuin}/bin/atuin $out/bin/atuin
      ln -s ${pkgs.zoxide}/bin/zoxide $out/bin/zoxide
      ln -s ${pkgs.jnv}/bin/jnv $out/bin/jnv
      ln -s ${pkgs.zenith}/bin/zenith $out/bin/zenith
    '';
}