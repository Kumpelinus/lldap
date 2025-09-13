# Nix Development Environment

LLDAP provides a Nix flake that sets up a complete development environment with all necessary tools and dependencies.

## Requirements

- [Nix](https://nixos.org/download.html) with flakes enabled
- (Optional) [direnv](https://direnv.net/) for automatic environment activation

## Quick Start

```bash
# Clone the repository
git clone https://github.com/lldap/lldap.git
cd lldap

# Enter the development environment
nix develop

# Build the project
cargo build --workspace

# Run tests
cargo test --workspace

# Build the frontend
./app/build.sh
```

## Automatic Environment Activation (Optional)

For automatic environment activation when entering the project directory:

1. Install direnv: `nix profile install nixpkgs#direnv`
2. Set up direnv shell hook in your shell configuration 
3. Navigate to the project directory and allow direnv: `direnv allow`
4. The environment will automatically activate when entering the directory

## Available Tools

The Nix environment provides:

- **Rust 1.85.0** (MSRV) with all required components (clippy, rustfmt, rust-src)
- **WebAssembly support**: wasm-pack and wasm32-unknown-unknown target
- **Cross-compilation targets**:
  - x86_64-unknown-linux-musl
  - aarch64-unknown-linux-musl
  - armv7-unknown-linux-musleabihf
- **Development tools**: pkg-config, gzip, curl, git, jq, gcc
- **Additional utilities**: cargo-watch, bacon, cargo-expand

## Development Workflow

```bash
# Enter the development environment
nix develop

# Build the workspace
cargo build --workspace

# Run tests
cargo test --workspace

# Check formatting
cargo fmt --check --all

# Run linting
cargo clippy --tests --workspace -- -D warnings

# Build frontend
./app/build.sh

# Export GraphQL schema (if needed)
./export_schema.sh

# Start development server
cargo run -- run --config-file lldap_config.docker_template.toml
```

## Environment Features

### Rust Toolchain
- Rust 1.85.0 (MSRV) with required components
- Pre-configured for WebAssembly compilation
- Cross-compilation targets included

### Development Tools
- `wasm-pack` for WebAssembly compilation
- `cargo-watch` for automatic rebuilds
- `cargo-expand` for macro debugging
- `bacon` for continuous testing
- Standard build tools (pkg-config, gzip, etc.)

### Environment Variables
- `CARGO_TERM_COLOR=always` for colored output
- `RUST_BACKTRACE=1` for better error debugging
- Cross-compilation linker configurations

## Building with Nix

You can also build LLDAP directly using Nix:

```bash
# Build the default package (server)
nix build

# Build and run
nix run
```

## Development Shells

The flake provides two development shells:

- `default` - Full development environment
- `ci` - Minimal environment similar to CI

```bash
# Use the CI-like environment
nix develop .#ci
```

## Troubleshooting

### Common Issues

1. **wasm-pack not found**: Ensure you're in the Nix shell environment
2. **Build failures**: Check that all tools are available
3. **Frontend build fails**: Ensure gzip is available (included in the environment)

### Verification

```bash
# Check that all tools are available
which cargo wasm-pack gzip
rustc --version  # Should show 1.85.0

# Verify cross-compilation targets
rustup target list --installed
```