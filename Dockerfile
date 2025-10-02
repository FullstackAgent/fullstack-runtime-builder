FROM ubuntu:24.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    NODE_VERSION=22.x \
    CLAUDE_CODE_VERSION=latest \
    PATH="/root/.local/bin:$PATH" \
    ANTHROPIC_BASE_URL="" \
    ANTHROPIC_AUTH_TOKEN="" \
    ANTHROPIC_MODEL="" \
    ANTHROPIC_SMALL_FAST_MODEL="" \
    DOCKER_HUB_NAME="" \
    DOCKER_HUB_PASSWD=""

# Update and install base dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    gnupg \
    lsb-release \
    software-properties-common \
    build-essential \
    python3 \
    python3-pip \
    sudo \
    vim \
    nano \
    unzip \
    ca-certificates \
    apt-transport-https \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js (latest LTS)
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION} | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@latest

# Install PostgreSQL client tools
RUN sh -c 'echo "deb https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    apt-get update && \
    apt-get install -y postgresql-client-16 && \
    rm -rf /var/lib/apt/lists/*

# Install global npm packages including Next.js and shadcn/ui dependencies
RUN npm install -g \
    next@latest \
    create-next-app \
    typescript \
    @types/node \
    @types/react \
    @types/react-dom \
    pnpm \
    yarn \
    vercel \
    prisma

# Install shadcn/ui CLI and related tools
RUN npm install -g \
    shadcn-ui \
    tailwindcss \
    autoprefixer \
    postcss

# Install Claude Code CLI
RUN curl -fsSL https://console.anthropic.com/install.sh | sh && \
    echo 'export PATH="/root/.local/bin:$PATH"' >> ~/.bashrc

# Install Buildah and related container tools for unprivileged operation
RUN apt-get update && \
    apt-get install -y \
    buildah \
    podman \
    skopeo \
    fuse-overlayfs \
    uidmap \
    slirp4netns \
    crun \
    && rm -rf /var/lib/apt/lists/*

# Configure Buildah and Podman for fully unprivileged operation
RUN mkdir -p /etc/containers /home/developer/.config/containers && \
    echo '[storage]' > /etc/containers/storage.conf && \
    echo 'driver = "vfs"' >> /etc/containers/storage.conf && \
    echo 'rootless_storage_path = "/tmp/containers-storage"' >> /etc/containers/storage.conf && \
    echo '[storage.options]' >> /etc/containers/storage.conf && \
    echo 'mount_program = "/usr/bin/fuse-overlayfs"' >> /etc/containers/storage.conf && \
    echo '[engine]' > /etc/containers/containers.conf && \
    echo 'cgroup_manager = "cgroupfs"' >> /etc/containers/containers.conf && \
    echo 'events_logger = "file"' >> /etc/containers/containers.conf && \
    echo '[engine.runtimes]' >> /etc/containers/containers.conf && \
    echo 'crun = ["/usr/bin/crun"]' >> /etc/containers/containers.conf

# Set up registries configuration for buildah/podman
RUN echo '[registries.search]' > /etc/containers/registries.conf && \
    echo 'registries = ["docker.io", "quay.io"]' >> /etc/containers/registries.conf

# Install additional development tools (NO Docker CLI)
RUN apt-get update && apt-get install -y \
    jq \
    htop \
    tree \
    zip \
    telnet \
    net-tools \
    iputils-ping \
    dnsutils \
    openssh-client \
    rsync \
    tmux \
    screen \
    make \
    && rm -rf /var/lib/apt/lists/*

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update && \
    apt-get install -y gh && \
    rm -rf /var/lib/apt/lists/*

# Install code editors extensions and tools
RUN apt-get update && apt-get install -y \
    ripgrep \
    fd-find \
    bat \
    exa \
    && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /workspace

# Set up a non-root user for better security (optional, can be overridden)
RUN useradd -m -s /bin/bash developer && \
    echo 'developer ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Expose common ports for web development
EXPOSE 3000 3001 5000 5173 8080 8000 5432

# Set default command
CMD ["/bin/bash"]