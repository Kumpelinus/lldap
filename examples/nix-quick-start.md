# LLDAP Nix Development Quick Start

This is a quick example of how to get started with LLDAP development using Nix.

## Prerequisites

1. Install Nix with flakes enabled:
   ```bash
   curl -L https://nixos.org/nix/install | sh -s -- --daemon
   # Enable flakes
   mkdir -p ~/.config/nix
   echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
   ```

2. (Optional) Install direnv for automatic environment activation:
   ```bash
   nix profile install nixpkgs#direnv
   # Add to your shell configuration (~/.bashrc, ~/.zshrc, etc.):
   eval "$(direnv hook bash)"  # or zsh, fish, etc.
   ```

## Quick Start Example

```bash
# Clone the repository
git clone https://github.com/lldap/lldap.git
cd lldap

# Method 1: Using direnv (automatic activation)
direnv allow
# The environment will be automatically loaded

# Method 2: Manual activation  
nix develop

# Validate your environment setup
lldap-validate-env

# Build the project
lldap-build

# Run tests
lldap-test

# Run all checks (CI equivalent)
lldap-check-all

# Start development server
lldap-dev
```

## Development Workflow Example

```bash
# Start development
nix develop  # or use direnv

# Make your changes to the code...

# Check formatting
lldap-fmt

# Fix formatting if needed
lldap-fmt-fix

# Run linting
lldap-lint

# Build and test
lldap-build
lldap-test

# If you made frontend changes
lldap-frontend

# Run complete validation
lldap-check-all

# Before committing, ensure everything works
lldap-validate-env
```

## Available Commands

The Nix environment provides these convenience commands:

| Command | Purpose |
|---------|---------|
| `lldap-build` | Build the workspace |
| `lldap-test` | Run all tests |
| `lldap-lint` | Run clippy linting |
| `lldap-fmt` | Check code formatting |
| `lldap-fmt-fix` | Fix code formatting |
| `lldap-frontend` | Build WebAssembly frontend |
| `lldap-schema` | Export GraphQL schema |
| `lldap-dev` | Start development server |
| `lldap-check-all` | Run complete CI suite |
| `lldap-release` | Build release binary |
| `lldap-validate-env` | Validate environment setup |

## Troubleshooting

### Environment doesn't activate
- Make sure you have Nix with flakes enabled
- Try `nix develop --verbose` for more information

### Build failures
- Run `lldap-validate-env` to check your setup
- Ensure you're in the project root directory
- Check that all required tools are available

### Frontend build issues
- Verify wasm-pack is available: `which wasm-pack`
- Check gzip is available: `which gzip`
- Try rebuilding: `lldap-frontend`

For more detailed information, see [docs/nix-development.md](../docs/nix-development.md).