{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation rec {
  pname = "app-zed";
  version = "1.114";


  src = pkgs.fetchurl {
    url = "https://github.com/zed-industries/zed/releases/download/v1.7.2/Zed-aarch64.dmg";
    sha256 = "sha256-45hgyZ7OXuJrhxOqx2jf3vlCd937MBqwae71EZO1GPA=";
  };

  nativeBuildInputs = [ pkgs._7zz pkgs.makeWrapper  ];

  unpackPhase = ''
    7zz x -snld $src
  '';

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/Applications
    
    # 1. Locate and copy the real .app directory
    APP_PATH=$(find . -name "*.app" -maxdepth 3 | head -n 1)
    cp -R "$APP_PATH" $out/Applications/
    
    # 2. Define the path to the internal macOS binary inside the bundle
    TARGET_BIN=$out/Applications/Zed.app/Contents/MacOS/zed
    
    # 3. Rename the original binary so the wrapper can take its place 
    mv "$TARGET_BIN" "$TARGET_BIN-wrapped"
    
    # 4. Create a wrapper that sources your file first, then launches the app
    # Replace "/path/to/your/file.sh" with the actual path you want to source
    makeWrapper "$TARGET_BIN-wrapped" "$TARGET_BIN" \
      --run "export SHELL_RUN='source \$HOME/.nixpath' && source \$HOME/.nixpath"
  '';

  meta = with pkgs.lib; {
    description = "Zed editor";
    platforms = platforms.darwin;
  };
}