FROM ubuntu:22.04

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV THEOS=/theos

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    fakeroot \
    libarchive-tools \
    unzip \
    clang \
    perl \
    python3 \
    libacl1-dev \
    rsync \
    && rm -rf /var/lib/apt/lists/*

# Clone Theos
RUN git clone --quiet --recursive https://github.com/theos/theos.git $THEOS

# Download iOS SDKs
RUN cd $THEOS && \
    curl -sL https://github.com/theos/sdks/archive/master.zip -o sdks.zip && \
    unzip -q sdks.zip && \
    mv sdks-master/* sdks/ && \
    rm -rf sdks-master sdks.zip

# Download and install LLVM toolchain for iOS cross-compilation
RUN cd $THEOS/toolchain && \
    curl -sL "https://github.com/theos/toolchain/releases/download/build%2F20240416/linux-x86_64_x86_64_i686-w64-mingw32-native_arm-apple-darwin11-9.2.1_ld64-274.2_cctools-949.2.1.tar.gz" -o toolchain.tar.gz && \
    tar xzf toolchain.tar.gz && \
    rm toolchain.tar.gz || true

# Set working directory
WORKDIR /project

# Set environment
ENV PATH="${THEOS}/bin:${PATH}"
ENV THEOS_MAKE_PATH=${THEOS}/makefiles

ENTRYPOINT ["bash"]
