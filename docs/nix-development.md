# Nix Development Environment

This repository includes a comprehensive Nix flake for development that provides all necessary tools and dependencies for building, testing, and developing LLDAP.

## Prerequisites

- [Nix package manager](https://nixos.org/download.html) with flakes enabled
- Optionally: [direnv](https://direnv.net/) for automatic environment activation

## Quick Start

### With direnv (Recommended)

1. Install direnv: `nix profile install nixpkgs#direnv`
2. Set up direnv shell hook in your shell configuration
3. Navigate to the project directory and allow direnv: `direnv allow`
4. The environment will automatically activate when entering the directory

### Without direnv

```bash
# Enter the development shell
nix develop

# Or use the specific CI environment
nix develop .#ci
```

## Available Commands

The development environment provides convenient wrapper scripts:

### Build Commands
- `lldap-build` - Build the entire workspace
- `lldap-release` - Build release binary
- `lldap-frontend` - Build the WebAssembly frontend

### Testing & Quality
- `lldap-test` - Run all tests
- `lldap-lint` - Run clippy linting (with warnings as errors)
- `lldap-fmt` - Check code formatting
- `lldap-fmt-fix` - Fix code formatting automatically
- `lldap-check-all` - Run all checks (build, test, format, lint, frontend)

### Development
- `lldap-dev` - Start development server with default config
- `lldap-schema` - Export GraphQL schema

## Development Workflow

### Initial Setup
```bash
# Enter development environment
nix develop

# Run all checks to ensure everything works
lldap-check-all
```

### Daily Development
```bash
# Build and test your changes
lldap-build
lldap-test

# Check code quality
lldap-fmt
lldap-lint

# Build frontend after frontend changes
lldap-frontend

# Start development server
lldap-dev
```

### Environment Validation
```bash
# Validate your environment setup
lldap-validate-env
```

### Before Committing
```bash
# Run complete check suite
lldap-check-all
```

## Quick Start Example

For a complete beginner's guide with step-by-step instructions, see [examples/nix-quick-start.md](../examples/nix-quick-start.md).

## Environment Features

### Rust Toolchain
- Rust 1.85.0 (MSRV) with required components
- Pre-configured for WebAssembly compilation
- Cross-compilation targets included:
  - `x86_64-unknown-linux-musl`
  - `aarch64-unknown-linux-musl` 
  - `armv7-unknown-linux-musleabihf`

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

You can also build LLDAP using Nix:

```bash
# Build the default package (server)
nix build

# Build and run
nix run
```

## Troubleshooting

### Common Issues

1. **wasm-pack not found**: Ensure you're in the Nix shell environment
2. **Build failures**: Run `lldap-check-all` to identify issues
3. **Frontend build fails**: Ensure gzip is available (included in the environment)

### Verification

```bash
# Check that all tools are available
which cargo wasm-pack gzip
rustc --version  # Should show 1.85.0

# Verify cross-compilation targets
rustup target list --installed
```

## Integration with CI

The Nix environment is designed to match the CI requirements:

- Same Rust version (1.85.0)
- Same build commands and flags
- Same linting configuration
- Same test execution

You can use the `ci` development shell for a minimal CI-like environment:

```bash
nix develop .#ci
```

## Customization

The flake provides two development shells:

- `default` - Full development environment with convenience scripts
- `ci` - Minimal environment similar to CI

You can extend the environment by modifying `flake.nix` or create a `shell.nix` for project-specific customizations.