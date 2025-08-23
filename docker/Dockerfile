# DotNameCpp Development Environment
# Multi-stage Dockerfile for C++ development template
FROM ubuntu:24.04 AS base

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Prague
ENV CC=gcc-13
ENV CXX=g++-13

# Arguments for user mapping (can be overridden at build time)
ARG USER_ID=1000
ARG GROUP_ID=1000
ARG USERNAME=developer

# Install system dependencies
RUN apt-get update && apt-get install -y \
    # Build essentials
    build-essential \
    gcc-13 \
    g++-13 \
    ninja-build \
    make \
    # Development tools
    git \
    python3 \
    python3-pip \
    python3-venv \
    wget \
    curl \
    unzip \
    sudo \
    # Code quality tools
    clang-tidy \
    clang-format \
    cppcheck \
    # Performance tools
    ccache \
    # Documentation
    doxygen \
    graphviz \
    # Web server for Emscripten demos
    nginx \
    # Additional utilities
    vim \
    nano \
    htop \
    tree \
    mc \
    lnav \
    && rm -rf /var/lib/apt/lists/*

# Install latest CMake (3.31+)
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null && \
    echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ noble main' | tee /etc/apt/sources.list.d/kitware.list >/dev/null && \
    apt-get update && \
    apt-get install -y cmake && \
    rm -rf /var/lib/apt/lists/*

# Install Python packages
# Ubuntu 24.04 requires --break-system-packages for system-wide pip installs
RUN pip3 install --no-cache-dir --break-system-packages \
    conan \
    cmake-format \
    gcovr

# Setup ccache
RUN /usr/sbin/update-ccache-symlinks && \
    echo 'export PATH="/usr/lib/ccache:$PATH"' | tee -a /etc/skel/.bashrc

# Create user with matching UID/GID (handling existing groups gracefully)
RUN if getent group ${GROUP_ID} >/dev/null 2>&1; then \
        EXISTING_GROUP=$(getent group ${GROUP_ID} | cut -d: -f1); \
        echo "Using existing group $EXISTING_GROUP with GID ${GROUP_ID}"; \
    else \
        groupadd -g ${GROUP_ID} ${USERNAME}; \
        EXISTING_GROUP=${USERNAME}; \
    fi && \
    if getent passwd ${USER_ID} >/dev/null 2>&1; then \
        EXISTING_USER=$(getent passwd ${USER_ID} | cut -d: -f1); \
        echo "User with UID ${USER_ID} already exists: $EXISTING_USER"; \
        usermod -l ${USERNAME} $EXISTING_USER; \
        usermod -d /home/${USERNAME} -m ${USERNAME}; \
    else \
        useradd -u ${USER_ID} -g ${GROUP_ID} -m -s /bin/bash ${USERNAME}; \
    fi && \
    usermod -aG sudo ${USERNAME} && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Setup Conan for the user
USER ${USERNAME}
WORKDIR /home/${USERNAME}
RUN conan profile detect --force

# Development stage
FROM base AS development

# Arguments need to be redeclared for multi-stage
ARG USER_ID=1000
ARG GROUP_ID=1000
ARG USERNAME=developer

# Copy project files from parent directory
COPY --chown=${USER_ID}:${GROUP_ID} .. /workspace/DotNameCpp
WORKDIR /workspace/DotNameCpp

# Switch to non-root user
USER ${USERNAME}

# Set up development environment
RUN echo 'export PS1="\[\e[32m\]${USERNAME}@DotNameCpp-Dev:\[\e[34m\]\w\[\e[0m\]\$ "' >> /home/${USERNAME}/.bashrc && \
    echo 'alias ll="ls -alF"' >> /home/${USERNAME}/.bashrc && \
    echo 'alias la="ls -A"' >> /home/${USERNAME}/.bashrc && \
    echo 'alias l="ls -CF"' >> /home/${USERNAME}/.bashrc && \
    echo 'export PATH="/usr/lib/ccache:$PATH"' >> /home/${USERNAME}/.bashrc

# Create useful aliases for development
RUN echo 'alias build-debug="python3 SolutionController.py standalone \"🔨 Build\" default Debug"' >> /home/${USERNAME}/.bashrc && \
    echo 'alias build-release="python3 SolutionController.py standalone \"🔨 Build\" default Release"' >> /home/${USERNAME}/.bashrc && \
    echo 'alias configure="python3 SolutionController.py standalone \"🔧 CMake configure\" default Debug"' >> /home/${USERNAME}/.bashrc && \
    echo 'alias test-run="python3 SolutionController.py standalone \"🧪 Run CTest\" default Debug"' >> /home/${USERNAME}/.bashrc && \
    echo 'alias zero-to-hero="python3 SolutionController.py both \"🦸 Zero to Hero\" default Debug"' >> /home/${USERNAME}/.bashrc && \
    echo 'alias format-code="python3 SolutionController.py both \"📐 Format Code\" noNeedArch"' >> /home/${USERNAME}/.bashrc && \
    echo 'alias lint-code="python3 SolutionController.py both \"🔍 clang-tidy linting\" default Debug"' >> /home/${USERNAME}/.bashrc

# Install Conan dependencies (but don't configure/build yet)
RUN conan install . --build=missing --profile:build=default --profile:host=default || true

# Fix permissions script for volumes (run as entrypoint)
USER root
RUN echo '#!/bin/bash\n\
# Fix permissions for mounted volumes\n\
if [ -d "/home/'${USERNAME}'/.conan2" ]; then\n\
    chown -R '${USER_ID}':'${GROUP_ID}' /home/'${USERNAME}'/.conan2 2>/dev/null || true\n\
fi\n\
if [ -d "/home/'${USERNAME}'/.ccache" ]; then\n\
    chown -R '${USER_ID}':'${GROUP_ID}' /home/'${USERNAME}'/.ccache 2>/dev/null || true\n\
fi\n\
# Switch to user and execute command\n\
if [ "$(id -u)" = "0" ]; then\n\
    exec runuser -u '${USERNAME}' -- "$@"\n\
else\n\
    exec "$@"\n\
fi' > /fix-permissions.sh && \
    chmod +x /fix-permissions.sh

ENTRYPOINT ["/fix-permissions.sh"]
USER ${USERNAME}

# Production stage for hosting
FROM nginx:alpine AS production

# Copy built assets for web hosting (if they exist)
COPY --from=development /workspace/DotNameCpp/README.md /usr/share/nginx/html/
COPY --from=development /workspace/DotNameCpp/assets /usr/share/nginx/html/assets

# Copy nginx configuration
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

# Expose port
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
