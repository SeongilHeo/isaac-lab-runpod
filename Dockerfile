FROM nvcr.io/nvidia/isaac-lab:3.0.0-beta2-post1

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    xfce4 \
    xfce4-goodies \
    tigervnc-standalone-server \
    tigervnc-common \
    dbus-x11 \
    xterm \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /root/.vnc && \
    printf '%s\n' \
    '#!/bin/sh' \
    'unset SESSION_MANAGER' \
    'unset DBUS_SESSION_BUS_ADDRESS' \
    'xrdb "$HOME/.Xresources" 2>/dev/null || true' \
    'exec dbus-launch --exit-with-session startxfce4' \
    > /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

ENTRYPOINT []
CMD ["sleep", "infinity"]
