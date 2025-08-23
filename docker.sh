#!/bin/bash
# DotNameCpp Docker Quick Commands
# This script provides quick access to Docker commands from project root

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}DotNameCpp Docker Environment${NC}"
echo -e "${YELLOW}Quick Commands:${NC}"
echo ""

case "$1" in
    "dev")
        echo -e "${GREEN}Starting development environment...${NC}"
        cd docker && make force-clean && make dev && make shell
        ;;
    "build")
        echo -e "${GREEN}Building development image...${NC}"
        cd docker && make build
        ;;
    "test")
        echo -e "${GREEN}Running zero-to-hero test...${NC}"
        cd docker && make test
        ;;
    "prod")
        echo -e "${GREEN}Starting production web server...${NC}"
        cd docker && make force-clean && make prod
        ;;
    "stop")
        echo -e "${YELLOW}Stopping all containers...${NC}"
        cd docker && make down
        ;;
    "clean")
        echo -e "${YELLOW}Cleaning up containers and volumes...${NC}"
        cd docker && make clean
        ;;
    "force-clean")
        echo -e "${RED}Force cleaning conflicting containers...${NC}"
        cd docker && make force-clean
        ;;
    "logs")
        echo -e "${GREEN}Showing container logs...${NC}"
        cd docker && make logs
        ;;
    "help"|"")
        echo -e "${GREEN}Available commands:${NC}"
        echo "  ./docker.sh dev        - Start development environment and enter shell"
        echo "  ./docker.sh build      - Build development image"
        echo "  ./docker.sh test       - Run zero-to-hero test in container"
        echo "  ./docker.sh prod       - Start production web server"
        echo "  ./docker.sh stop       - Stop all containers"
        echo "  ./docker.sh clean      - Clean up containers and volumes"
        echo "  ./docker.sh force-clean- Force remove conflicting containers"
        echo "  ./docker.sh logs       - Show container logs"
        echo "  ./docker.sh help       - Show this help"
        echo ""
        echo -e "${BLUE}For more options, use: cd docker && make help${NC}"
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        echo "Use './docker.sh help' to see available commands"
        exit 1
        ;;
esac
