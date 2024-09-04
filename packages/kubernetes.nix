{ pkgs }:	

pkgs.stdenv.mkDerivation rec {
    pname = "kubernetes";
    version = "0.1.0";
    phases = [ "installPhase" ];

    installPhase = ''
      mkdir -p $out/bin
      ln -s ${pkgs.kubectl}/bin/kubectl $out/bin/kubectl
      ln -s ${pkgs.k9s}/bin/k9s $out/bin/k9s
      ln -s ${pkgs.kubernetes-helm}/bin/helm $out/bin/helm
    '';
}