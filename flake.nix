{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};

      version = "4.3";
      godot-stable = pkgs.fetchurl {
        url = "https://github.com/godotengine/godot/releases/download/${version}-stable/Godot_v${version}-stable_linux.x86_64.zip";
        hash = "sha256-feVkRLEwsQr4TRnH4M9jz56ZN+5LqUNkw7fdEUJTyiE=";
      };

      buildInputs = with pkgs; [
        alsa-lib
        dbus
        fontconfig
        libGL
        libpulseaudio
        libxkbcommon
        makeWrapper
        mesa
        patchelf
        speechd
        udev
        vulkan-loader
        xorg.libX11
        xorg.libXcursor
        xorg.libXext
        xorg.libXfixes
        xorg.libXi
        xorg.libXinerama
        xorg.libXrandr
        xorg.libXrender
      ];

      godot-unwrapped = pkgs.stdenv.mkDerivation {
        pname = "godot";
        version = "4.3";

        src = godot-stable;
        nativeBuildInputs = with pkgs; [unzip autoPatchelfHook];
        buildInputs = buildInputs;

        dontAutoPatchelf = false;

        unpackPhase = ''
          mkdir source
          unzip $src -d source
        '';

        installPhase = ''
          mkdir -p $out/bin
          cp source/Godot_v${version}-stable_linux.x86_64 $out/bin/godot
        '';
      };

      godot-bin = pkgs.buildFHSUserEnv {
        name = "godot";
        targetPkgs = pkgs: buildInputs ++ [godot-unwrapped];
        runScript = "godot";
      };
    in {
      devShell = pkgs.mkShell {
        buildInputs = [godot-bin];
      };
    });
}
