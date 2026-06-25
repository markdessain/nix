{ pkgs, system }:	

pkgs.stdenv.mkDerivation rec {
    pname = "kubernetes";
    version = "0.1.0";
    phases = [ "installPhase" ];

    k3s = if system == "aarch64-linux" then pkgs.k3s else "";
    slirp4netns = if system == "aarch64-linux" then pkgs.slirp4netns else "";

    installPhase = ''
      mkdir -p $out/bin
      ln -s ${pkgs.kubectl}/bin/kubectl $out/bin/kubectl
      ln -s ${pkgs.k9s}/bin/k9s $out/bin/k9s
      ln -s ${pkgs.k6}/bin/k6 $out/bin/k6
      ln -s ${pkgs.kubernetes-helm}/bin/helm $out/bin/helm
      ln -s ${pkgs.kind}/bin/kind $out/bin/kind
      ln -s ${pkgs.minikube}/bin/minikube $out/bin/minikube
      ln -s ${pkgs.kubelogin}/bin/kubelogin $out/bin/kubelogin

      ln -s ${pkgs.docker}/bin/docker $out/bin/docker

      if [[ "${system}" == "aarch64-darwin" ]]; then
        ln -s ${pkgs.docker-credential-helpers}/bin/docker-credential-osxkeychain $out/bin/docker-credential-osxkeychain
        ln -s ${pkgs.docker-credential-helpers}/bin/docker-credential-pass $out/bin/docker-credential-pass
      fi

      if [[ "${k3s}" != "" ]]; then
        ln -s ${k3s}/bin/k3s $out/bin/k3s
        ln -s ${k3s}/bin/kubectl $out/bin/kubectl
        ln -s ${slirp4netns}/bin/slirp4netns $out/bin/slirp4netns
      fi

      if [[ "${system}" == "aarch64-linux" ]]; then
        echo 'sudo ${k3s}/bin/k3s server --write-kubeconfig-mode 644 --disable=traefik' > $out/bin/k3s-server 
        chmod +x $out/bin/k3s-server

        echo 'docker save $1 | sudo ${k3s}/bin/k3s ctr images import -' > $out/bin/k3s-image 
        chmod +x $out/bin/k3s-image
      fi

      echo 'mkdir -p ~/.config/kube' > $out/.env
      echo 'if [ -z "$( ls -A ~/.config/kube )" ]; then echo "No kubernetes configs found"; else export KUBECONFIG=$(for filename in ~/.config/kube/*; do echo -n "$filename:"; done | sed "s/:$//"); fi' >> $out/.env 
      chmod +x $out/.env 

      echo 'kubectl exec svc/$1 -c $1 -it -- ''${2:-bash}' > $out/bin/pod_view 
      chmod +x $out/bin/pod_view 

      echo 'kubectl config use-context $1-''${2:-dev}' > $out/bin/pod_environment 
      chmod +x $out/bin/pod_environment 
    '';
}