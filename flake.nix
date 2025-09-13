{
  description = "LLDAP - Light LDAP implementation for authentication";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay, crane }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };

        # MSRV from the project
        rustVersion = "1.85.0";
        
        # Rust toolchain with required components
        rustToolchain = pkgs.rust-bin.stable.${rustVersion}.default.override {
          extensions = [ "rust-src" "clippy" "rustfmt" ];
          targets = [ 
            "wasm32-unknown-unknown" 
            "x86_64-unknown-linux-musl"
            "aarch64-unknown-linux-musl" 
            "armv7-unknown-linux-musleabihf"
          ];
        };

        craneLib = crane.lib.${system}.overrideToolchain rustToolchain;

        # Common build inputs
        nativeBuildInputs = with pkgs; [
          # Rust toolchain and tools
          rustToolchain
          wasm-pack
          
          # Build tools
          pkg-config
          
          # Compression and utilities
          gzip
          curl
          wget
          
          # Development tools
          git
          jq
          
          # Cross-compilation support
          gcc
          
          # For development convenience
          cargo-watch
          cargo-expand
          bacon
        ];

        buildInputs = with pkgs; [
          # System libraries that might be needed
          openssl
          sqlite
        ] ++ lib.optionals stdenv.isDarwin [
          # macOS specific dependencies
          darwin.apple_sdk.frameworks.Security
          darwin.apple_sdk.frameworks.SystemConfiguration
        ];

        # Environment variables
        commonEnvVars = {
          CARGO_TERM_COLOR = "always";
          RUST_BACKTRACE = "1";
          
          # Cross-compilation environment
          CARGO_TARGET_X86_64_UNKNOWN_LINUX_MUSL_LINKER = "${pkgs.pkgsStatic.stdenv.cc}/bin/cc";
          CARGO_TARGET_AARCH64_UNKNOWN_LINUX_MUSL_LINKER = "${pkgs.pkgsCross.aarch64-multiplatform.stdenv.cc}/bin/aarch64-unknown-linux-gnu-gcc";
          CARGO_TARGET_ARMV7_UNKNOWN_LINUX_MUSLEABIHF_LINKER = "${pkgs.pkgsCross.armv7l-hf-multiplatform.stdenv.cc}/bin/arm-unknown-linux-gnueabihf-gcc";
        };

        # Development scripts
        devScripts = with pkgs; [
          (writeShellScriptBin "lldap-build" ''
            echo "🔨 Building LLDAP workspace..."
            cargo build --workspace "$@"
          '')
          
          (writeShellScriptBin "lldap-test" ''
            echo "🧪 Running LLDAP tests..."
            cargo test --workspace "$@"
          '')
          
          (writeShellScriptBin "lldap-lint" ''
            echo "🔍 Running clippy linting..."
            cargo clippy --tests --workspace -- -D warnings "$@"
          '')
          
          (writeShellScriptBin "lldap-fmt" ''
            echo "📐 Checking code formatting..."
            cargo fmt --check --all "$@"
          '')
          
          (writeShellScriptBin "lldap-fmt-fix" ''
            echo "🔧 Fixing code formatting..."
            cargo fmt --all "$@"
          '')
          
          (writeShellScriptBin "lldap-frontend" ''
            echo "🌐 Building frontend..."
            cd app && ./build.sh "$@"
          '')
          
          (writeShellScriptBin "lldap-schema" ''
            echo "📋 Exporting GraphQL schema..."
            ./export_schema.sh "$@"
          '')
          
          (writeShellScriptBin "lldap-dev" ''
            echo "🚀 Starting LLDAP development server..."
            # Build frontend first
            lldap-frontend
            # Start server with config
            cargo run -- run --config-file lldap_config.docker_template.toml "$@"
          '')
          
          (writeShellScriptBin "lldap-check-all" ''
            echo "🔍 Running all checks..."
            echo "1/5 Building workspace..."
            lldap-build || exit 1
            echo "2/5 Running tests..."
            lldap-test || exit 1
            echo "3/5 Checking formatting..."
            lldap-fmt || exit 1
            echo "4/5 Running linter..."
            lldap-lint || exit 1
            echo "5/5 Building frontend..."
            lldap-frontend || exit 1
            echo "✅ All checks passed!"
          '')
          
          (writeShellScriptBin "lldap-release" ''
            echo "📦 Building release..."
            cargo build --release -p lldap "$@"
          '')
        ];

      in
      {
        # Development shells
        devShells = {
          default = pkgs.mkShell ({
            inherit nativeBuildInputs buildInputs;
            
            packages = devScripts;
            
            shellHook = ''
              echo "🔐 LLDAP Development Environment"
              echo "==============================================="
              echo "Rust version: ${rustVersion}"
              echo "Available commands:"
              echo "  lldap-build      - Build the workspace"
              echo "  lldap-test       - Run tests"
              echo "  lldap-lint       - Run clippy linting"
              echo "  lldap-fmt        - Check formatting"
              echo "  lldap-fmt-fix    - Fix formatting"
              echo "  lldap-frontend   - Build frontend WASM"
              echo "  lldap-schema     - Export GraphQL schema"
              echo "  lldap-dev        - Start development server"
              echo "  lldap-check-all  - Run all checks"
              echo "  lldap-release    - Build release binary"
              echo "==============================================="
              echo ""
              
              # Ensure wasm-pack is available
              if ! command -v wasm-pack &> /dev/null; then
                echo "⚠️  wasm-pack not found in PATH"
              fi
              
              # Check if we're in the right directory
              if [[ ! -f "Cargo.toml" ]]; then
                echo "⚠️  Run this from the project root directory"
              fi
            '';
          } // commonEnvVars);

          # Minimal shell for CI-like environment
          ci = pkgs.mkShell ({
            inherit nativeBuildInputs buildInputs;
            
            shellHook = ''
              echo "🤖 LLDAP CI Environment"
              echo "Running with Rust ${rustVersion}"
            '';
          } // commonEnvVars);
        };

        # Package outputs (optional - for building with Nix)
        packages = {
          default = craneLib.buildPackage {
            src = craneLib.cleanCargoSource (craneLib.path ./.);
            
            inherit nativeBuildInputs buildInputs;
            
            # Build only the server by default
            cargoExtraArgs = "-p lldap";
            
            # Skip tests in the package build
            doCheck = false;
            
            meta = with pkgs.lib; {
              description = "Light LDAP implementation for authentication";
              homepage = "https://github.com/lldap/lldap";
              license = licenses.gpl3Only;
              maintainers = with maintainers; [ ];
              platforms = platforms.unix;
            };
          };
        };

        # Formatter for the flake itself
        formatter = pkgs.nixpkgs-fmt;

        # Apps for running via `nix run`
        apps = {
          default = flake-utils.lib.mkApp {
            drv = self.packages.${system}.default;
          };
        };
      });
}