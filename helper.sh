#!/bin/bash

# StorLoko ARM Builder - Helper Script
# Provides useful commands for managing builds

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

show_help() {
    cat << EOF
StorLoko ARM Builder Helper Script

Usage: ./helper.sh <command>

Commands:
  status          - Show build system status
  clean           - Clean build artifacts
  clean-all       - Clean everything including Armbian cache
  list-boards     - List supported boards
  check-deps      - Check build dependencies
  disk-usage      - Show disk usage
  test-docker     - Test Docker installation
  info            - Show system information
  help            - Show this help message

Examples:
  ./helper.sh status
  ./helper.sh clean
  ./helper.sh check-deps

EOF
}

check_command() {
    if command -v "$1" &> /dev/null; then
        echo -e "${GREEN}✓${NC} $1 is installed"
        return 0
    else
        echo -e "${RED}✗${NC} $1 is NOT installed"
        return 1
    fi
}

show_status() {
    echo -e "${BLUE}=== StorLoko ARM Builder Status ===${NC}"
    echo ""
    
    # Check if build directory exists
    if [ -d "build/armbian" ]; then
        echo -e "${GREEN}✓${NC} Build environment: Ready"
        echo "  Location: build/armbian"
        
        # Check for built images
        if [ -d "build/armbian/output/images" ] && [ "$(ls -A build/armbian/output/images)" ]; then
            echo -e "${GREEN}✓${NC} Built images found:"
            ls -lh build/armbian/output/images/*.img* 2>/dev/null | awk '{print "  "$9, "("$5")"}'
        else
            echo -e "${YELLOW}!${NC} No built images found"
        fi
    else
        echo -e "${YELLOW}!${NC} Build environment: Not initialized"
        echo "  Run: ./build-local.sh <board>"
    fi
    
    echo ""
    echo -e "${BLUE}=== System Resources ===${NC}"
    
    # Disk space
    echo "Disk space:"
    df -h . | tail -1 | awk '{print "  Available: "$4" / "$2}'
    
    # Memory
    echo "Memory:"
    free -h | grep Mem | awk '{print "  Available: "$7" / "$2}'
    
    # CPU
    echo "CPU cores: $(nproc)"
    
    echo ""
}

clean_builds() {
    echo -e "${YELLOW}Cleaning build artifacts...${NC}"
    
    if [ -d "build/armbian/output" ]; then
        rm -rf build/armbian/output/*
        echo -e "${GREEN}✓${NC} Cleaned output directory"
    fi
    
    if [ -d "images" ]; then
        rm -rf images/*
        echo -e "${GREEN}✓${NC} Cleaned images directory"
    fi
    
    echo -e "${GREEN}Done!${NC}"
}

clean_all() {
    echo -e "${RED}WARNING: This will delete ALL build data including Armbian cache!${NC}"
    read -p "Are you sure? (yes/no): " -r
    echo
    
    if [[ $REPLY =~ ^yes$ ]]; then
        echo -e "${YELLOW}Cleaning everything...${NC}"
        
        if [ -d "build" ]; then
            rm -rf build
            echo -e "${GREEN}✓${NC} Removed build directory"
        fi
        
        if [ -d "images" ]; then
            rm -rf images
            echo -e "${GREEN}✓${NC} Removed images directory"
        fi
        
        echo -e "${GREEN}Done!${NC}"
        echo "Run ./build-local.sh to rebuild from scratch"
    else
        echo "Cancelled."
    fi
}

list_boards() {
    echo -e "${BLUE}=== Supported Boards ===${NC}"
    echo ""
    echo "Basic Tier:"
    echo "  • rockpi-4c-plus    - Rock Pi 4C+ (4GB RAM)"
    echo "  • rockpi-4b         - Rock Pi 4B (2GB/4GB RAM)"
    echo ""
    echo "Mid Tier:"
    echo "  • orangepi5-pro     - Orange Pi 5 Pro (16GB RAM)"
    echo ""
    echo "Build with: ./build-local.sh <board-name>"
}

check_dependencies() {
    echo -e "${BLUE}=== Checking Dependencies ===${NC}"
    echo ""
    
    local all_ok=true
    
    check_command git || all_ok=false
    check_command curl || all_ok=false
    check_command wget || all_ok=false
    check_command docker || all_ok=false
    
    echo ""
    
    if [ "$all_ok" = true ]; then
        echo -e "${GREEN}✓ All dependencies are installed!${NC}"
    else
        echo -e "${RED}✗ Some dependencies are missing${NC}"
        echo ""
        echo "To install missing dependencies:"
        echo "  sudo apt update"
        echo "  sudo apt install -y git curl wget docker.io"
    fi
}

show_disk_usage() {
    echo -e "${BLUE}=== Disk Usage ===${NC}"
    echo ""
    
    echo "Project directory:"
    du -sh . 2>/dev/null || echo "  Unable to calculate"
    
    if [ -d "build" ]; then
        echo ""
        echo "Build directory breakdown:"
        du -sh build/* 2>/dev/null | sort -hr || echo "  No build data"
    fi
    
    echo ""
    echo "Filesystem usage:"
    df -h . | tail -1
}

test_docker() {
    echo -e "${BLUE}=== Testing Docker ===${NC}"
    echo ""
    
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}✗ Docker is not installed${NC}"
        echo ""
        echo "To install Docker:"
        echo "  curl -fsSL https://get.docker.com | sh"
        echo "  sudo usermod -aG docker \$USER"
        echo "  newgrp docker"
        return 1
    fi
    
    echo -e "${GREEN}✓${NC} Docker is installed"
    echo "  Version: $(docker --version)"
    
    if docker ps &> /dev/null; then
        echo -e "${GREEN}✓${NC} Docker daemon is running"
        
        echo ""
        echo "Running test container..."
        if docker run --rm hello-world &> /dev/null; then
            echo -e "${GREEN}✓${NC} Docker is working correctly!"
        else
            echo -e "${RED}✗${NC} Docker test failed"
        fi
    else
        echo -e "${RED}✗${NC} Docker daemon is not accessible"
        echo ""
        echo "Try:"
        echo "  sudo systemctl start docker"
        echo "  sudo usermod -aG docker \$USER"
        echo "  newgrp docker"
    fi
}

show_info() {
    echo -e "${BLUE}=== System Information ===${NC}"
    echo ""
    
    echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
    echo "Kernel: $(uname -r)"
    echo "Architecture: $(uname -m)"
    echo "CPU: $(nproc) cores"
    echo "Memory: $(free -h | grep Mem | awk '{print $2}')"
    echo "Disk: $(df -h . | tail -1 | awk '{print $4" available of "$2}')"
    
    echo ""
    echo "Build system:"
    echo "  Working directory: $(pwd)"
    echo "  User: $(whoami)"
    
    if [ -d "build/armbian" ]; then
        echo "  Build directory: Yes"
    else
        echo "  Build directory: No"
    fi
}

# Main
case "${1:-help}" in
    status)
        show_status
        ;;
    clean)
        clean_builds
        ;;
    clean-all)
        clean_all
        ;;
    list-boards)
        list_boards
        ;;
    check-deps)
        check_dependencies
        ;;
    disk-usage)
        show_disk_usage
        ;;
    test-docker)
        test_docker
        ;;
    info)
        show_info
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac