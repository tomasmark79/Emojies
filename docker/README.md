# DotNameCpp Docker Environment

This directory contains the complete Docker setup for the DotNameCpp C++ development template.

## ✅ Problem Solved: Root Ownership Issue

The Docker environment now correctly maps container users to host users (UID/GID 1000:1000), eliminating the root ownership problem. Files created in containers are owned by the host user.

## Quick Start

```bash
# From project root
./docker.sh dev     # Start development environment
./docker.sh test    # Run zero-to-hero build test
./docker.sh prod    # Start production web server
./docker.sh clean   # Clean up containers
```

## Files Overview

- **Dockerfile**: Multi-stage build with user mapping
- **docker-compose.yml**: Service orchestration with proper permissions  
- **Makefile**: 15+ convenience commands
- **docker.sh**: Quick command wrapper (from project root)
- **.env**: User mapping configuration (UID=1000, GID=1000, USERNAME=tomas)
- **nginx.conf**: Web server configuration for production

## Key Features

✅ **User Mapping**: Container user matches host user (UID/GID 1000:1000)  
✅ **No Root Ownership**: Files created in container owned by host user  
✅ **SELinux Compatible**: Mount options with `:z` flag  
✅ **Persistent Volumes**: Conan cache, ccache preserved across rebuilds  
✅ **Development Aliases**: zero-to-hero, build-debug, configure, etc.  
✅ **Multi-stage Build**: Separate development and production environments  
✅ **Web Server**: Nginx for hosting documentation and demos  

## Development Workflow

1. **Start Container**: `./docker.sh dev` or `make dev`
2. **Enter Shell**: `make shell` 
3. **Build Project**: Use aliases like `zero-to-hero`, `build-debug`
4. **Edit Files**: All changes persist with correct ownership
5. **Clean Up**: `./docker.sh clean` when done

## Commands Reference

### From Project Root
```bash
./docker.sh dev        # Start development environment
./docker.sh test       # Run zero-to-hero test  
./docker.sh prod       # Start production web server
./docker.sh stop       # Stop all containers
./docker.sh clean      # Clean up containers and volumes
./docker.sh logs       # Show container logs
```

### From docker/ Directory  
```bash
make help              # Show all available commands
make dev               # Start development environment
make shell             # Enter development container
make build             # Build development image
make prod              # Start production web server
make test              # Run zero-to-hero in container
make clean             # Remove containers and volumes
make force-clean       # Force remove conflicting containers
make rebuild           # Rebuild images from scratch
```

### Inside Container
```bash
zero-to-hero          # Full build and test cycle
build-debug           # Debug build only
build-release         # Release build only  
configure             # CMake configure
test-run              # Run CTest
format-code           # Format source code
lint-code             # Run clang-tidy linting
```

## Technical Details

- **Base Image**: Ubuntu 24.04
- **CMake**: 4.1.0+ (upgraded from 3.28)  
- **Compiler**: GCC 13 with C++17
- **Package Manager**: Conan 2.0
- **Build System**: Ninja
- **Code Quality**: clang-tidy, clang-format, cppcheck
- **Performance**: ccache enabled
- **Documentation**: Doxygen + Graphviz

## Environment Variables

The `.env` file configures user mapping:
```bash
USER_ID=1000          # Host user ID
GROUP_ID=1000         # Host group ID  
USERNAME=tomas        # Container username
```

## Volumes

- **Source Mount**: `..:/workspace/DotNameCpp:z` (SELinux compatible)
- **Conan Cache**: `conan-cache:/home/tomas/.conan2` (persistent)
- **ccache**: `ccache-cache:/home/tomas/.ccache` (persistent)

## Ports

- **8080**: Development server (container)
- **80**: Production web server (nginx)

## Troubleshooting

### Permission Issues
- Ensure UID/GID in `.env` match your host user: `id`
- SELinux systems require `:z` mount flag (already configured)

### Container Won't Start  
- Check logs: `./docker.sh logs`
- Force clean: `make force-clean`
- Rebuild: `make rebuild`

### Build Failures
- Enter container: `make shell`
- Check Conan cache ownership: `ls -la /home/tomas/.conan2/`
- Fix if needed: `sudo chown -R tomas:ubuntu /home/tomas/.conan2/`

## Success Verification

The Docker environment is working correctly when:
1. Container starts without errors
2. `make shell` provides interactive access  
3. Files created in container are owned by host user
4. `zero-to-hero` command builds successfully
5. No permission denied errors when accessing mounted files

## Architecture

```
Host System
├── /home/tomas/dev/cpp/templates/DotNameCpp/  (UID:1000, GID:1000)
│   ├── docker/                                 
│   │   ├── Dockerfile                         # Multi-stage build definition
│   │   ├── docker-compose.yml                # Service orchestration  
│   │   ├── Makefile                          # Convenience commands
│   │   └── .env                              # User mapping config
│   └── docker.sh                             # Quick wrapper script
│
Container (dotnamecpp-dev)  
├── /workspace/DotNameCpp/                     # Bind mount (:z flag)
├── /home/tomas/                              # User home (UID:1000, GID:1000) 
│   ├── .conan2/                              # Persistent volume
│   └── .ccache/                              # Persistent volume
└── User: tomas (1000:1000)                   # Matches host user
```

This setup ensures seamless development with proper file ownership and no permission conflicts.
