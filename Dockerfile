# Dockerfile - Development & Build Environment
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV GODOT_VERSION=4.3.0
ENV GODOT_URL=https://downloads.tuxfamily.org/godotengine/4.3/Godot_v4.3-stable_linux.x86_64.zip

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    git \
    ca-certificates \
    xvfb \
    x11-utils \
    libxkbcommon0 \
    libxrandr6 \
    libxi6 \
    libxinerama1 \
    libxcursor1 \
    libxext6 \
    libx11-6 \
    libgl1 \
    pulseaudio \
    && rm -rf /var/lib/apt/lists/*

# Download and install Godot
WORKDIR /opt
RUN wget -q ${GODOT_URL} -O godot.zip && \
    unzip -q godot.zip && \
    rm godot.zip && \
    mv Godot_v4.3-stable_linux.x86_64 godot && \
    chmod +x /opt/godot/Godot_v4.3-stable_linux.x86_64

# Create app directory
WORKDIR /app

# Copy project files
COPY . .

# Set up git
RUN git config --global user.email "detective@echoes-of-eleven.local" && \
    git config --global user.name "Echoes of Eleven"

# Build cache
ENV GODOT=/opt/godot/Godot_v4.3-stable_linux.x86_64

# Export templates for building
RUN $GODOT --headless --export-templates 2>&1 | grep -i template || true

# Clean up for smaller image
RUN rm -rf /opt/godot/.local

EXPOSE 8080

CMD ["/bin/bash"]
