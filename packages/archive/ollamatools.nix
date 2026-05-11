{ pkgs }:	

pkgs.stdenv.mkDerivation rec {
    pname = "ollamatools";
    version = "0.1.0";
    phases = [ "installPhase" ];
    
    buildInputs = [
    ];
    
    installPhase = ''
      mkdir -p $out/bin

      cat <<EOT >> $out/bin/record
        recorder --output ~/CloudDrive/brain/meetings
      EOT
      chmod +x $out/bin/record

      cat <<EOT >> $out/bin/tldr
        pbpaste | ${pkgs.ollama}/bin/ollama run gemma3:12b-it-q4_K_M "provide a concise summary of the given text. If it helps then use bulletpoints to break down sections. Make the response as short as possible but no longer than 200 words, start with the header # Summary<br><br>:" | tee /dev/tty | ${pkgs.glow}/bin/glow
      EOT
      chmod +x $out/bin/tldr

      cat <<EOT >> $out/bin/audio
        data_dir=\$(mktemp -d)
        ffmpeg -f avfoundation -i ":0" -y \$data_dir/sample.mp3 && whisper --output_format txt --output_dir \$data_dir --language en \$data_dir/sample.mp3 && cat \$data_dir/sample.txt | bash -c 'echo "-------------" && ollama run gemma3:12b-it-q4_K_M "answer the following question, keep the answer small with a max of 200 words and include code examples if it helps to explain to concept:" && echo "-------"' | tee /dev/tty | glow
      EOT
      chmod +x $out/bin/audio

      cat <<EOT >> $out/bin/mind
        PROMPT="
          You are a specialized mind map generator that creates markmap-compatible markdown output. Your task is to analyze the provided text and create a hierarchical mind map structure using markdown syntax.

          Rules for generating the mind map:
          1. Use markdown headings (##, ###, etc.) for main topics and subtopics
          2. Use bullet points (-) for listing details under topics
          3. Maintain a clear hierarchical structure from general to specific
          4. Keep entries concise and meaningful
          5. Include all relevant information from the source text
          6. Use proper markdown formatting for:
            - Links: [text](URL)
            - Emphasis: **bold**, *italic*
            - Code: inline code or code blocks
            - Tables when needed
            - Lists (both bullet points and numbered lists where appropriate)
          7. Always use proper emojis for main topics, if applicable you can also add them for subtopics

          Example format:
          ## 📋 Project Overview
          ### Key Features
          - Feature 1
          - Feature 2

          Generate a markmap-compatible mind map for this text:
        "
        pbpaste | ${pkgs.ollama}/bin/ollama run gemma3:12b-it-q4_K_M "\$PROMPT" | tee /dev/tty | LC_ALL=en_US.UTF-8 pbcopy
      EOT
      chmod +x $out/bin/mind
    '';
}
