FROM nvcr.io/nvidia/isaac-lab:3.0.0-beta2-post1

USER root

ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:1 \
    VNC_GEOMETRY=1920x1080 \
    VNC_DEPTH=24

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

RUN printf '%s\n' \
    '#!/bin/bash' \
    'set -e' \
    '' \
    ': "${VNC_PASSWORD:?VNC_PASSWORD must be set}"' \
    '' \
    'printf "%s\n" "$VNC_PASSWORD" | vncpasswd -f > /root/.vnc/passwd' \
    'chmod 600 /root/.vnc/passwd' \
    '' \
    'vncserver -kill :1 >/dev/null 2>&1 || true' \
    'rm -f /tmp/.X1-lock /tmp/.X11-unix/X1' \
    '' \
    'exec vncserver :1 -fg \' \
    '    -localhost no \' \
    '    -geometry "$VNC_GEOMETRY" \' \
    '    -depth "$VNC_DEPTH" \' \
    '    -SecurityTypes VncAuth \' \
    '    -PasswordFile /root/.vnc/passwd' \
    > /usr/local/bin/start-vnc.sh && \
    chmod +x /usr/local/bin/start-vnc.sh

WORKDIR /workspace

EXPOSE 5901

ENTRYPOINT []

CMD ["/usr/local/bin/start-vnc.sh"]