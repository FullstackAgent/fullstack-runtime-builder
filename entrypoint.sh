#!/bin/bash

# Entrypoint script for Full-Stack Web Runtime
# This script starts ttyd as a daemon for web terminal access

# Configuration
TTYD_PORT=${TTYD_PORT:-7681}
TTYD_USERNAME=${TTYD_USERNAME:-}
TTYD_PASSWORD=${TTYD_PASSWORD:-}
TTYD_INTERFACE=${TTYD_INTERFACE:-0.0.0.0}
TTYD_BASE_PATH=${TTYD_BASE_PATH:-/}
TTYD_MAX_CLIENTS=${TTYD_MAX_CLIENTS:-0}
TTYD_READONLY=${TTYD_READONLY:-false}
TTYD_CHECK_ORIGIN=${TTYD_CHECK_ORIGIN:-false}
TTYD_ALLOW_ORIGIN=${TTYD_ALLOW_ORIGIN:-*}

# Build ttyd command with options
TTYD_CMD="ttyd"

# Add interface and port
TTYD_CMD="$TTYD_CMD --interface $TTYD_INTERFACE"
TTYD_CMD="$TTYD_CMD --port $TTYD_PORT"

# Add base path if specified
if [ "$TTYD_BASE_PATH" != "/" ]; then
    TTYD_CMD="$TTYD_CMD --base-path $TTYD_BASE_PATH"
fi

# Add authentication if username and password are provided
if [ -n "$TTYD_USERNAME" ] && [ -n "$TTYD_PASSWORD" ]; then
    TTYD_CMD="$TTYD_CMD --credential $TTYD_USERNAME:$TTYD_PASSWORD"
fi

# Add max clients limit
if [ "$TTYD_MAX_CLIENTS" -gt 0 ]; then
    TTYD_CMD="$TTYD_CMD --max-clients $TTYD_MAX_CLIENTS"
fi

# Add readonly mode if enabled
if [ "$TTYD_READONLY" = "true" ]; then
    TTYD_CMD="$TTYD_CMD --readonly"
fi

# Add CORS settings
if [ "$TTYD_CHECK_ORIGIN" = "false" ]; then
    TTYD_CMD="$TTYD_CMD --check-origin"
fi

# Add allow origin
TTYD_CMD="$TTYD_CMD --allow-origin $TTYD_ALLOW_ORIGIN"

# Function to start ttyd in background
start_ttyd() {
    echo "Starting ttyd web terminal on port $TTYD_PORT..."
    echo "Access the web terminal at: http://localhost:$TTYD_PORT$TTYD_BASE_PATH"

    if [ -n "$TTYD_USERNAME" ]; then
        echo "Authentication enabled. Username: $TTYD_USERNAME"
    else
        echo "Warning: No authentication configured. Consider setting TTYD_USERNAME and TTYD_PASSWORD for security."
    fi

    # Start ttyd in background
    $TTYD_CMD /bin/bash &
    TTYD_PID=$!
    echo "ttyd started with PID: $TTYD_PID"
}

# Function to stop ttyd gracefully
stop_ttyd() {
    if [ -n "$TTYD_PID" ]; then
        echo "Stopping ttyd (PID: $TTYD_PID)..."
        kill $TTYD_PID 2>/dev/null
    fi
}

# Trap signals to ensure clean shutdown
trap stop_ttyd EXIT SIGTERM SIGINT

# Check if ttyd should be disabled
if [ "$DISABLE_TTYD" = "true" ]; then
    echo "ttyd is disabled via DISABLE_TTYD environment variable"
else
    # Start ttyd daemon
    start_ttyd
fi

# If a command was provided, execute it
if [ $# -gt 0 ]; then
    echo "Executing command: $@"
    exec "$@"
else
    # If no command provided, start an interactive bash shell
    echo "Starting interactive bash shell..."
    exec /bin/bash
fi