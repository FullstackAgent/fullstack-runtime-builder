# Full-Stack Web Application Runtime

A comprehensive Docker container image designed for full-stack web development with all the modern tools and frameworks pre-installed.

## Features

This runtime includes:

- **Node.js** (v22.x) - Latest LTS version for JavaScript runtime
- **Next.js** - Full-stack React framework for production
- **PostgreSQL Client Tools** - For database connectivity and management
- **shadcn/ui** - Modern React component library with Tailwind CSS
- **Claude Code CLI** - AI-powered coding assistant
- **Buildah** - Container building tool that works in unprivileged mode
- **Development Tools** - Git, GitHub CLI, ripgrep, and more

## Quick Start

### Using Pre-built Image

```bash
# Pull the image from Docker Hub
docker pull fullstackagent/fullstack-web-runtime:latest

# Run the container
docker run -it --rm \
  -p 3000:3000 \
  -p 5000:5000 \
  -p 8080:8080 \
  -v $(pwd):/workspace \
  fullstackagent/fullstack-web-runtime:latest
```

### Building from Source

Due to security restrictions in some environments, you may need to build this image in an environment with proper Docker or Buildah permissions.

#### Option 1: Using the Build Script

```bash
# Set your Docker Hub credentials
export DOCKER_HUB_NAME=your_username
export DOCKER_HUB_PASSWD=your_password

# Run the build script
./build.sh
```

#### Option 2: Manual Build with Docker

```bash
# Build the image
docker build -t fullstackagent/fullstack-web-runtime:latest .

# Push to Docker Hub (optional)
docker login
docker push fullstackagent/fullstack-web-runtime:latest
```

#### Option 3: Manual Build with Buildah (for rootless environments)

```bash
# Build with Buildah
buildah bud -t fullstackagent/fullstack-web-runtime:latest .

# Or with VFS driver for restricted environments
buildah --storage-driver vfs bud -t fullstackagent/fullstack-web-runtime:latest .

# Push to Docker Hub
buildah login docker.io
buildah push fullstackagent/fullstack-web-runtime:latest docker://fullstackagent/fullstack-web-runtime:latest
```

## Environment Variables

The runtime supports the following environment variables:

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `ANTHROPIC_BASE_URL` | Base URL for Anthropic API | - | No |
| `ANTHROPIC_AUTH_TOKEN` | Authentication token for Anthropic API | - | No |
| `ANTHROPIC_MODEL` | Primary AI model to use | - | No |
| `ANTHROPIC_SMALL_FAST_MODEL` | Fast model for quick operations | - | No |
| `DOCKER_HUB_NAME` | Docker Hub username for pushing images | - | For pushing |
| `DOCKER_HUB_PASSWD` | Docker Hub password for pushing images | - | For pushing |

### Setting Environment Variables

When running the container:

```bash
docker run -it --rm \
  -e ANTHROPIC_BASE_URL=https://api.anthropic.com \
  -e ANTHROPIC_AUTH_TOKEN=your_token \
  -e ANTHROPIC_MODEL=claude-3-opus-20240229 \
  -v $(pwd):/workspace \
  fullstackagent/fullstack-web-runtime:latest
```

Or use an `.env` file:

```bash
docker run -it --rm \
  --env-file .env \
  -v $(pwd):/workspace \
  fullstackagent/fullstack-web-runtime:latest
```

## Usage Examples

### Create a Next.js Application

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  fullstackagent/fullstack-web-runtime:latest \
  bash -c "npx create-next-app@latest my-app --typescript --tailwind --app"
```

### Run a Development Server

```bash
docker run -it --rm \
  -p 3000:3000 \
  -v $(pwd):/workspace \
  -w /workspace/my-app \
  fullstackagent/fullstack-web-runtime:latest \
  npm run dev
```

### Use Claude Code CLI

```bash
docker run -it --rm \
  -e ANTHROPIC_AUTH_TOKEN=your_token \
  -v $(pwd):/workspace \
  fullstackagent/fullstack-web-runtime:latest \
  claude-code
```

### Build Containers Inside the Runtime

The runtime includes Buildah for building containers without requiring Docker daemon:

```bash
docker run -it --rm \
  --privileged \
  -v $(pwd):/workspace \
  fullstackagent/fullstack-web-runtime:latest \
  buildah --storage-driver vfs bud -t my-image .
```

## Exposed Ports

The following ports are exposed by default:

- `3000` - Next.js development server
- `3001` - Alternative development port
- `5000` - Python/Flask applications
- `5173` - Vite development server
- `8080` - General web server
- `8000` - Django/FastAPI
- `5432` - PostgreSQL connection

## Volume Mounts

Recommended volume mounts:

```bash
-v $(pwd):/workspace        # Mount current directory as workspace
-v ~/.ssh:/root/.ssh:ro     # Mount SSH keys (read-only)
-v ~/.gitconfig:/root/.gitconfig:ro  # Mount Git config (read-only)
```

## Installed Tools

### Core Development Tools
- Node.js v22.x with npm and yarn
- TypeScript
- Git with GitHub CLI
- Python 3 with pip
- Make, gcc, build-essential

### Web Frameworks
- Next.js (latest)
- Create Next App
- Vercel CLI
- Prisma ORM

### UI/Styling
- shadcn/ui CLI
- Tailwind CSS
- PostCSS
- Autoprefixer

### Database Tools
- PostgreSQL Client v16
- Prisma CLI

### Container Tools
- Buildah (rootless container builds)
- Podman
- Skopeo

### Utilities
- ripgrep (fast search)
- fd-find (fast file finder)
- bat (better cat)
- exa (better ls)
- jq (JSON processor)
- htop, tmux, screen
- curl, wget
- Network tools (ping, telnet, dig)

## Security Notes

1. **Running as Root**: By default, the container runs as root. For production use, consider creating and switching to a non-root user.

2. **Privileged Mode**: Building containers with Buildah inside the runtime may require `--privileged` flag or proper capability settings.

3. **Secrets Management**: Never hardcode sensitive information in the Dockerfile. Always use environment variables or mounted secret files.

## Troubleshooting

### Permission Denied Errors

If you encounter permission errors when building containers inside the runtime:

```bash
# Run with privileged mode
docker run -it --rm --privileged fullstackagent/fullstack-web-runtime:latest

# Or use VFS storage driver
buildah --storage-driver vfs bud -t my-image .
```

### Port Already in Use

If ports are already in use on your host:

```bash
# Map to different host ports
docker run -it --rm -p 3001:3000 fullstackagent/fullstack-web-runtime:latest
```

### Out of Space

The VFS storage driver may use more disk space. Clean up regularly:

```bash
buildah rm --all
buildah rmi --all
```

## Contributing

To contribute to this runtime:

1. Fork the repository
2. Make your changes to the Dockerfile
3. Test the build locally
4. Submit a pull request

## License

This runtime is provided as-is for development purposes. Please ensure compliance with all included software licenses.

## Support

For issues or questions:
- Open an issue in the repository
- Check the Dockerfile for specific version information
- Consult the documentation of individual tools included in the runtime