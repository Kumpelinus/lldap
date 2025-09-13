# Nix Development Environment

LLDAP provides a Nix flake that sets up a complete development environment with all necessary tools and dependencies.

## Requirements

- [Nix](https://nixos.org/download.html) with flakes enabled
- (Optional) [direnv](https://direnv.net/) for automatic environment activation

## Usage

```bash
# Clone the repository
git clone https://github.com/lldap/lldap.git
cd lldap

# Enter the development environment
nix develop

# Build the workspace
cargo build --workspace

# Run tests
cargo test --workspace

# Check formatting and linting
cargo fmt --check --all
cargo clippy --tests --workspace -- -D warnings

# Build frontend
./app/build.sh

# Export GraphQL schema (if needed)
./export_schema.sh

# Start development server
cargo run -- run --config-file lldap_config.docker_template.toml
```

## Automatic Environment Activation (Optional)

For automatic environment activation when entering the project directory:

1. Install direnv: `nix profile install nixpkgs#direnv`
2. Set up direnv shell hook in your shell configuration 
3. Navigate to the project directory and allow direnv: `direnv allow`
4. The environment will automatically activate when entering the directory