FROM nvcr.io/nvidia/isaac-lab:3.0.0-beta2-post1

ENV DEBIAN_FRONTEND=noninteractive \
    ACCEPT_EULA=Y \
    PRIVACY_CONSENT=Y \
    OMNI_KIT_ALLOW_ROOT=1 \
    DISPLAY=:1 \
    VNC_GEOMETRY=1920x1080 \
    VNC_DEPTH=24

RUN apt-get update && apt-get install -y --no-install-recommends \
    xfce4 \
    xfce4-goodies \
    tigervnc-standalone-server \
    tigervnc-common \
    dbus-x11 \
    x11-xserver-utils \
    xterm \
    mesa-utils \
    vulkan-tools \
    procps \
    curl \
    git \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /root/.vnc /workspace && \
    cat > /root/.vnc/xstartup <<'EOF'
#!/bin/sh

unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

xrdb "$HOME/.Xresources" 2>/dev/null || true
exec dbus-launch --exit-with-session startxfce4
EOF

RUN chmod +x /root/.vnc/xstartup

RUN cat > /usr/local/bin/start-vnc.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

: "${VNC_PASSWORD:?VNC_PASSWORD environment variable must be set in RunPod}"

VNC_GEOMETRY="${VNC_GEOMETRY:-1920x1080}"
VNC_DEPTH="${VNC_DEPTH:-24}"

mkdir -p /root/.vnc

printf '%s\n' "${VNC_PASSWORD}" | vncpasswd -f > /root/.vnc/passwd
chmod 600 /root/.vnc/passwd

vncserver -kill :1 >/dev/null 2>&1 || true

rm -f /tmp/.X1-lock
rm -f /tmp/.X11-unix/X1

echo "Starting TigerVNC on display :1"
echo "Resolution: ${VNC_GEOMETRY}"
echo "Container port: 5901"

exec vncserver :1 \
    -fg \
    -localhost no \
    -geometry "${VNC_GEOMETRY}" \
    -depth "${VNC_DEPTH}" \
    -SecurityTypes VncAuth \
    -PasswordFile /root/.vnc/passwd
EOF

RUN chmod +x /usr/local/bin/start-vnc.sh

WORKDIR /workspace

EXPOSE 5901

ENTRYPOINT []

CMD ["/usr/local/bin/start-vnc.sh"]