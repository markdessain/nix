{ pkgs }:	

pkgs.stdenv.mkDerivation rec {
    pname = "kubernetes";
    version = "0.1.0";
    phases = [ "installPhase" ];

    installPhase = ''
      mkdir -p $out/bin
      ln -s ${pkgs.kubectl}/bin/kubectl $out/bin/kubectl
      ln -s ${pkgs.k9s}/bin/k9s $out/bin/k9s
      ln -s ${pkgs.k6}/bin/k6 $out/bin/k6
      ln -s ${pkgs.kubernetes-helm}/bin/helm $out/bin/helm
      ln -s ${pkgs.kind}/bin/kind $out/bin/kind
      ln -s ${pkgs.minikube}/bin/minikube $out/bin/minikube

      echo 'mkdir -p ~/.config/kube' > $out/.env
      echo 'if [ -z "$( ls -A ~/.config/kube )" ]; then echo "No kubernetes configs found"; else export KUBECONFIG=$(for filename in ~/.config/kube/*; do echo -n "$filename:"; done | sed "s/:$//"); fi' >> $out/.env 
      chmod +x $out/.env 

      echo 'kubectl exec svc/$1 -c $1 -it -- ''${2:-bash}' > $out/bin/pod_view 
      chmod +x $out/bin/pod_view 

      echo 'kubectl config use-context $1-''${2:-dev}' > $out/bin/pod_environment 
      chmod +x $out/bin/pod_environment 
    '';
}