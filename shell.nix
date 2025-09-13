# Legacy shell.nix for users who prefer non-flake Nix
# For the full development experience, use: nix develop
(import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") {
  overlays = [
    (import (fetchTarball "https://github.com/oxalica/rust-overlay/archive/master.tar.gz"))
  ];
}).callPackage ({ mkShell, rust-bin, wasm-pack, pkg-config, gzip, curl, wget, git, jq, gcc, openssl, sqlite, writeShellScriptBin }:

mkShell {
  nativeBuildInputs = [
    (rust-bin.stable."1.85.0".default.override {
      extensions = [ "rust-src" "clippy" "rustfmt" ];
      targets = [ 
        "wasm32-unknown-unknown" 
        "x86_64-unknown-linux-musl"
        "aarch64-unknown-linux-musl" 
        "armv7-unknown-linux-musleabihf"
      ];
    })
    wasm-pack
    pkg-config
    gzip
    curl
    wget
    git
    jq
    gcc
  ];

  buildInputs = [ openssl sqlite ];

  CARGO_TERM_COLOR = "always";
  RUST_BACKTRACE = "1";

  shellHook = ''
    echo "🔐 LLDAP Development Environment (legacy shell.nix)"
    echo "For the full experience with convenience scripts, use: nix develop"
    echo "==============================================="
    rustc --version
    cargo --version
    echo "wasm-pack: $(wasm-pack --version)"
    echo "==============================================="
  '';
}) {}