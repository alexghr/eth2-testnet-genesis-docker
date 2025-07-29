#!/usr/bin/env bash
# Helper script for eth2-testnet-genesis Docker container

IMAGE_NAME="eth2-testnet-genesis"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Build the Docker image
build_image() {
    print_info "Building Docker image..."
    docker build -t ${IMAGE_NAME}:latest .
    if [ $? -eq 0 ]; then
        print_info "Image built successfully!"
    else
        print_error "Failed to build image"
        exit 1
    fi
}

# Show help
show_help() {
    echo "eth2-testnet-genesis Docker Helper"
    echo ""
    echo "Usage: $0 <command> [arguments]"
    echo ""
    echo "Commands:"
    echo "  build       Build the Docker image"
    echo "  shell       Run interactive shell in container"
    echo "  help        Show this help message"
    echo ""
    echo "Phases: phase0, altair, bellatrix, capella, deneb, electra"
}

# Run interactive shell
run_shell() {
    print_info "Starting interactive shell..."
    docker run --rm -it \
        -v "$(pwd):/workspace" \
        --entrypoint /bin/bash \
        ${IMAGE_NAME}:latest
}

# Main script logic
case "$1" in
    build|"")
        build_image
        ;;
    shell)
        run_shell
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
