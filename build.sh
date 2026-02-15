#!/bin/bash

echo "========================================="
echo "🔨 Building Fate Mod..."
echo "========================================="

# Check if running in Docker or using local Theos
if [ -z "$THEOS" ]; then
    export THEOS=$HOME/theos
fi

# Check if we should use Docker
USE_DOCKER=${1:-"auto"}

if [ "$USE_DOCKER" = "docker" ] || ([ "$USE_DOCKER" = "auto" ] && ! command -v make &> /dev/null); then
    echo "🐳 Building with Docker..."
    
    # Build Docker image
    echo "📦 Building Docker image..."
    docker build -t fatemod-builder:latest .
    
    if [ $? -ne 0 ]; then
        echo "❌ Docker build failed!"
        exit 1
    fi
    
    # Run build in Docker
    echo "⚙️  Compiling in Docker..."
    docker run --rm -v "$(pwd):/project" fatemod-builder:latest -c "export THEOS=/theos && cd /project && make package FINALPACKAGE=1"
    BUILD_RESULT=$?
else
    # Local build
    # Clean previous builds
    echo "🧹 Cleaning..."
    make clean 2>/dev/null || true

    # Build
    echo "⚙️  Compiling..."
    make package FINALPACKAGE=1
    BUILD_RESULT=$?
fi

# Check if build succeeded
if [ $BUILD_RESULT -eq 0 ]; then
    echo ""
    echo "========================================="
    echo "✅ BUILD SUCCESSFUL!"
    echo "========================================="
    echo ""
    echo "📦 Your .deb file is located at:"
    ls -lh packages/*.deb
    echo ""
    echo "To download:"
    echo "1. Click on 'packages' folder in file explorer"
    echo "2. Right-click the .deb file"
    echo "3. Select 'Download'"
    echo ""
else
    echo ""
    echo "❌ BUILD FAILED!"
    echo "Check errors above"
    exit 1
fi