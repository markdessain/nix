{ pkgs }:	

pkgs.stdenv.mkDerivation rec {
    pname = "ai";
    version = "0.1.0";
    phases = [ "installPhase" ];
    
    buildInputs = [
      pkgs.ncurses
      pkgs.curl
      pkgs.python3
      pkgs.git
    ];
    # ln -s ${pkgs.open-webui}/bin/open-webui $out/bin/open-webui
    
    installPhase = ''
      mkdir -p $out/bin
      ln -s ${pkgs.ollama}/bin/ollama $out/bin/ollama
      ln -s ${pkgs.openai-whisper}/bin/whisper $out/bin/whisper
      ln -s ${pkgs.tabby}/bin/tabby $out/bin/tabby
      ln -s ${pkgs.tabby-agent}/bin/tabby-agent $out/bin/tabby-agent

      NIX_SSL_CERT_FILE="/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt"
      SSL_CERT_FILE="/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt"
      
      ${pkgs.curl}/bin/curl -fsSL https://raw.githubusercontent.com/trycua/cua/lume-v0.2.14/libs/lume/scripts/install.sh | sed 's/INSTALL_BACKGROUND_SERVICE=true/INSTALL_BACKGROUND_SERVICE=false/' | INSTALL_DIR=$out/lume bash

      ln -s $out/lume/lume $out/bin/lume

      # lume pull macos-sequoia-cua:latest

      python3 -m venv $out/lume-venv

      $out/lume-venv/bin/pip install -U pip
      $out/lume-venv/bin/pip install -U cua-computer==0.1.29 "cua-agent[all]==0.1.29"

      # Temporary fix for mlx-vlm, see https://github.com/Blaizzy/mlx-vlm/pull/349
      $out/lume-venv/bin/pip install git+https://github.com/ddupont808/mlx-vlm.git@stable/fix/qwen2-position-id

      cat > "$out/bin/lume-demo" <<EOF
      #!/usr/bin/env $out/lume-venv/bin/python

      import asyncio
      import os
      from computer import Computer
      from agent import ComputerAgent, LLM, AgentLoop, LLMProvider
      from agent.ui.gradio.app import create_gradio_ui

      # Try to load API keys from environment
      api_key = os.environ.get("OPENAI_API_KEY", "")
      if not api_key:
          print("\n⚠️  No OpenAI API key found. You'll need to provide one in the UI.")

      # Launch the Gradio UI and open it in the browser
      app = create_gradio_ui()
      app.launch(share=False, inbrowser=True)
      EOF

      chmod +x $out/bin/lume-demo
    '';
}
