#!/usr/bin/env bash
# Validation script for LLDAP Nix development environment
# Run this to verify your Nix setup works correctly

set -e

echo "🔍 LLDAP Nix Environment Validation"
echo "=================================="

# Check if we're in a Nix shell
if [[ -z "${IN_NIX_SHELL}" ]]; then
    echo "❌ Not in Nix shell. Run 'nix develop' first."
    exit 1
fi

echo "✅ Running in Nix shell"

# Check required tools
echo ""
echo "🔧 Checking required tools..."

check_tool() {
    local tool=$1
    local expected_version=$2
    
    if command -v "$tool" &> /dev/null; then
        local version
        case $tool in
            "rustc")
                version=$(rustc --version | cut -d' ' -f2)
                ;;
            "wasm-pack")
                version=$(wasm-pack --version | cut -d' ' -f2)
                ;;
            *)
                version="available"
                ;;
        esac
        echo "✅ $tool: $version"
        
        if [[ -n "$expected_version" && "$version" != *"$expected_version"* ]]; then
            echo "⚠️  Expected version containing '$expected_version', got '$version'"
            return 1
        fi
    else
        echo "❌ $tool: not found"
        return 1
    fi
}

# Check core tools
check_tool "rustc" "1.85"
check_tool "cargo"
check_tool "wasm-pack"
check_tool "gzip"
check_tool "pkg-config"

# Check Rust targets
echo ""
echo "🎯 Checking Rust targets..."
required_targets=(
    "wasm32-unknown-unknown"
    "x86_64-unknown-linux-musl" 
    "aarch64-unknown-linux-musl"
    "armv7-unknown-linux-musleabihf"
)

for target in "${required_targets[@]}"; do
    if rustup target list --installed | grep -q "$target"; then
        echo "✅ Target: $target"
    else
        echo "❌ Target missing: $target"
        exit 1
    fi
done

# Check environment variables
echo ""
echo "🌍 Checking environment variables..."
env_vars=(
    "CARGO_TERM_COLOR"
    "RUST_BACKTRACE"
)

for var in "${env_vars[@]}"; do
    if [[ -n "${!var}" ]]; then
        echo "✅ $var=${!var}"
    else
        echo "⚠️  $var not set"
    fi
done

# Check convenience scripts
echo ""
echo "📜 Checking convenience scripts..."
scripts=(
    "lldap-build"
    "lldap-test"
    "lldap-lint"
    "lldap-fmt"
    "lldap-frontend"
    "lldap-schema"
    "lldap-check-all"
)

for script in "${scripts[@]}"; do
    if command -v "$script" &> /dev/null; then
        echo "✅ $script"
    else
        echo "❌ $script not found"
        exit 1
    fi
done

# Test basic compilation
echo ""
echo "🔨 Testing basic compilation..."
if cargo check --workspace --quiet; then
    echo "✅ Workspace compiles successfully"
else
    echo "❌ Compilation failed"
    exit 1
fi

# Test frontend tools
echo ""
echo "🌐 Testing frontend tools..."
cd app || { echo "❌ app directory not found"; exit 1; }
if wasm-pack --version &> /dev/null; then
    echo "✅ wasm-pack works"
else
    echo "❌ wasm-pack not working"
    exit 1
fi
cd ..

echo ""
echo "🎉 All checks passed! Your Nix development environment is ready."
echo ""
echo "Next steps:"
echo "  • Run 'lldap-build' to build the project"
echo "  • Run 'lldap-test' to run tests"  
echo "  • Run 'lldap-check-all' to run the full CI suite"
echo "  • See 'docs/nix-development.md' for more information"