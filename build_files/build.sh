#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# Enable RPM Fusion repositories:
dnf5 -y install \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm


# Enable flatpack and flathub
mkdir -p /etc/flatpak/remotes.d && \
wget -q https://dl.flathub.org/repo/flathub.flatpakrepo -P /etc/flatpak/remotes.d && 
wget -q https://apt.pop-os.org/cosmic/cosmic.flatpakrepo -P /etc/flatpak/remotes.d

# this installs a package from fedora repos
dnf5 install -y tmux
dnf5 install -y just 

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

### System Configuration
#
# Set a default hostname.
# You can change "borisOS" to any hostname you like.
echo "borisOS" > /etc/hostname

### Install NVIDIA drivers
#
# Note: This is a simplified version of the driver installation.
# For a more robust setup, consider basing your image on one of
# Universal Blue's pre-made NVIDIA images, like `ghcr.io/ublue-os/bazzite-nvidia`.
#
# Install NVIDIA drivers without running post-install scripts
# The akmods service will build the driver on first boot
dnf5 install -y --setopt=tsflags=noscripts akmod-nvidia
dnf5 install -y xorg-x11-drv-nvidia-cuda

# Add kernel arguments to enable NVIDIA drivers
mkdir -p /etc/systemd/system/etc-systemd-system.conf.d/
printf "[Manager]\nDefaultEnvironment=KERNEL_ARGS=%s\n" "rd.driver.blacklist=nouveau modprobe.blacklist=nouveau nvidia-drm.modeset=1" > /etc/systemd/system/etc-systemd-system.conf.d/20-nvidia-kargs.conf

#### Example for enabling a System Unit File
systemctl enable akmods.service
systemctl enable podman.socket