{
  inputs.nixpkgs.url = "github:Anillc/nixpkgs/rust-for-linux";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.rust-overlay.url = "github:oxalica/rust-overlay";

  outputs = { self, nixpkgs, flake-utils, rust-overlay }: flake-utils.lib.eachDefaultSystem (system: let
    pkgs = import nixpkgs {
      inherit system;
      overlays = [
        rust-overlay.overlay
        (self: super: {
          rust-linux = super.fetchFromGitHub {
            owner = "Rust-for-Linux";
            repo = "linux";
            rev = "459035ab65c0ebb8d7054b24b6c00de907819eb2";
            sha256 = "sha256-Ilocc3TQJyMAl3w0XSRY8VV1pfMnT+PtPom0jNBYpt0=";
            passthru.version = "5.19.0";
          };
        })
      ];
    };
    buildInputs = with pkgs; [ llvm lld bc elfutils rust-bindgen openssl ];
    nativeBuildInputs = with pkgs; [
      ncurses pkg-config clang flex bison perl kmod
      (pkgs.rust-bin.stable."1.62.0".default.override {
        extensions = ["rust-src"];
      })
    ];
  in {
    packages = rec {
      configfile = pkgs.callPackage ./configfile.nix { inherit buildInputs nativeBuildInputs; };
      buildRustKernelModules= pkgs.callPackage ./modules.nix {
        inherit buildInputs nativeBuildInputs configfile;
      };
      sampleRustMinimal = buildRustKernelModules {
        extraConfig = ''
          SAMPLES y
          SAMPLES_RUST y
          SAMPLE_RUST_MINIMAL y
        '';
      };
    };
    devShell = pkgs.mkShell {
      inherit buildInputs nativeBuildInputs;
    };
  });
}