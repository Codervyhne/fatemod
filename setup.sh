#!/bin/bash

echo "========================================="
echo "🚀 Fate Mod - Theos Setup & Build Script"
echo "========================================="

# Install dependencies
echo "📦 Installing dependencies..."
sudo apt-get update -qq
sudo apt-get install -y -qq git perl clang build-essential fakeroot libarchive-tools

# Install Theos
if [ ! -d "$HOME/theos" ]; then
    echo "📥 Installing Theos..."
    git clone --quiet --recursive https://github.com/theos/theos.git $HOME/theos
else
    echo "✅ Theos already installed"
fi

export THEOS=$HOME/theos

# Download iOS SDK
if [ ! -d "$HOME/theos/sdks/iPhoneOS16.5.sdk" ]; then
    echo "📥 Downloading iOS SDK..."
    cd $HOME/theos
    curl -LO https://github.com/theos/sdks/archive/master.zip
    unzip -q master.zip
    mv sdks-master/* sdks/ 2>/dev/null || true
    rm -rf sdks-master master.zip
else
    echo "✅ iOS SDK already installed"
fi

# Return to project directory
cd $OLDPWD

echo ""
echo "✅ Setup complete!"
echo ""
echo "To build the mod, run:"
echo "  ./build.sh"