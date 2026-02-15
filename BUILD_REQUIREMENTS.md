# Building FateMod - Platform Requirements

## Issue: iOS Cross-Compilation Toolchain

Building iOS tweaks requires **Apple's LLVM/Clang compiler** specifically configured for iOS ARM architecture. This toolchain is **not available on Linux** and requires either:

### Option 1: Build on macOS (Recommended)

#### Requirements:
- macOS 10.15 or later
- Xcode Command Line Tools
- Theos

#### Setup:
```bash
# Install Theos
git clone --recursive https://github.com/theos/theos.git ~/theos

# Install SDKs
cd ~/theos && ./bin/install-theos

# Clone and build FateMod
cd /path/to/fatemod
./build.sh
```

### Option 2: GitHub Actions (Cloud Build on macOS)

Create `.github/workflows/build.yml` to build automatically on GitHub's macOS runners.

### Option 3: Remote macOS Machine

Set up SSH access to a Mac and build remotely:
```bash
ssh user@mac-machine "cd /path/to/fatemod && ./build.sh"
```

### Why Not Linux?

Theos supports Linux, but **iOS development fundamentally requires Apple's proprietary development tools**:
- The clang built for iOS ARM architecture is not available on Linux
- The iOS SDKs are proprietary and only provided by Apple
- Even though some tools exist on Linux, the complete iOS development environment is macOS-only

**Note:** You can still develop and test the Objective-C/Logos code structure on Linux, but final compilation must happen on macOS.

## What We've Set Up

The Docker image and build scripts are configured to work with:
- ✅ Theos project structure framework
- ✅ iOS SDK downloads (metadata only on Linux)
- ❌ iOS cross-compiler (macOS-only requirement)

If you obtain access to a macOS machine, the setup will work immediately.
