# Setting Up GitHub Secrets for Automated Docker Builds

This guide will help you set up GitHub repository secrets to enable automated Docker image builds and pushes.

## Prerequisites

1. A Docker Hub account (create one at https://hub.docker.com if needed)
2. Write access to the GitHub repository

## Steps to Configure GitHub Secrets

### 1. Navigate to Repository Settings

Go to: https://github.com/FullstackAgent/fullstack-runtime-builder/settings/secrets/actions

Or manually:
1. Open the repository: https://github.com/FullstackAgent/fullstack-runtime-builder
2. Click on "Settings" tab
3. In the left sidebar, click "Secrets and variables" → "Actions"

### 2. Add Docker Hub Username

1. Click "New repository secret"
2. Name: `DOCKER_HUB_USERNAME`
3. Secret: Enter your Docker Hub username (e.g., `fullstackagent`)
4. Click "Add secret"

### 3. Add Docker Hub Password

1. Click "New repository secret"
2. Name: `DOCKER_HUB_PASSWORD`
3. Secret: Enter your Docker Hub password or access token
4. Click "Add secret"

**Security Note**: It's recommended to use a Docker Hub access token instead of your password:
- Go to: https://hub.docker.com/settings/security
- Click "New Access Token"
- Description: "GitHub Actions for fullstack-runtime-builder"
- Access permissions: "Read & Write"
- Click "Generate"
- Copy the token and use it as the password

## Verifying the Setup

### Manual Trigger

1. Go to: https://github.com/FullstackAgent/fullstack-runtime-builder/actions
2. Click on "Build and Push Docker Image" workflow
3. Click "Run workflow" button
4. Select branch: `main`
5. Enter a tag (optional, defaults to `latest`)
6. Click "Run workflow"

### Check Build Status

- Monitor the build at: https://github.com/FullstackAgent/fullstack-runtime-builder/actions
- Green checkmark ✅ = Build successful
- Red X ❌ = Build failed (check logs for details)

### Verify Image on Docker Hub

Once built successfully, the image will be available at:
- https://hub.docker.com/r/fullstackagent/fullstack-web-runtime

## Triggering Builds

### Automatic Triggers

The workflow automatically runs when:
- Changes are pushed to `Dockerfile`
- Changes are pushed to `entrypoint.sh`
- Changes are pushed to the workflow file itself

### Manual Triggers via GitHub CLI

```bash
# Install GitHub CLI if not already installed
# https://cli.github.com/

# Authenticate with GitHub
gh auth login

# Trigger the workflow
gh workflow run docker-build.yml -f tag="v1.0.0"

# Check workflow runs
gh run list --workflow=docker-build.yml
```

### Manual Triggers via Build Script

```bash
# Use the provided build script
./build.sh --github

# With custom tag
./build.sh --github v1.0.0
```

## Troubleshooting

### Authentication Failed

If the build fails with authentication errors:
1. Verify your Docker Hub username is correct
2. Regenerate your Docker Hub access token
3. Update the `DOCKER_HUB_PASSWORD` secret

### Build Failed

Check the workflow logs:
1. Go to the Actions tab
2. Click on the failed workflow run
3. Click on "build-and-push" job
4. Review the error messages

### Image Not Appearing on Docker Hub

1. Ensure the build completed successfully
2. Check that secrets are correctly configured
3. Verify your Docker Hub account has push permissions

## Security Best Practices

1. **Use Access Tokens**: Always use Docker Hub access tokens instead of passwords
2. **Limit Token Scope**: Create tokens with minimal required permissions
3. **Rotate Tokens**: Regularly rotate your access tokens
4. **Monitor Usage**: Check Docker Hub for unexpected image pushes
5. **Review Logs**: Regularly review GitHub Actions logs for suspicious activity

## Support

For issues or questions:
- Open an issue: https://github.com/FullstackAgent/fullstack-runtime-builder/issues
- Check GitHub Actions documentation: https://docs.github.com/en/actions
- Docker Hub documentation: https://docs.docker.com/docker-hub/