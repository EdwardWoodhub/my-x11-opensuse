# 阶段 1：获取 Elemental 核心工具和只读不可变挂载模块
FROM ghcr.io/rancher/elemental-toolkit/elemental-cli:v2.2.0 AS elemental-source

# 阶段 2：以 openSUSE 16 为底座开始组装
FROM opensuse/leap:16.0

ENV container=docker

# 1. 安装引导底座、内核、固件及系统服务
RUN zypper --non-interactive refresh && \
    zypper --non-interactive in --no-recommends \
        kernel-default \
        kernel-firmware-all \
        dracut \
        grub2 \
        grub2-x86_64-efi \
        systemd \
        systemd-sysvinit \
        udev \
        NetworkManager \
        openssh \
        sudo \
        curl \
        which

# 2. 安装 XFCE 轻量桌面套件、X 基础及 LightDM 显示管理器
RUN zypper --non-interactive in --no-recommends \
    patterns-xfce-xfce \
    lightdm \
    lightdm-gtk-greeter \
    xorg-x11-server \
    xfce4-terminal \
    xfce4-session \
    xfwm4 && \
    zypper clean -a

# 3. 复制 Elemental 不可变挂载机制
COPY --from=elemental-source /usr/bin/elemental /usr/bin/elemental
COPY --from=elemental-source /usr/lib/dracut/modules.d/ /usr/lib/dracut/modules.d/

# 4. 创建默认用户并启用自动免密登入桌面
RUN useradd -m -G wheel -s /bin/bash liveuser && \
    echo "liveuser:liveuser" | chpasswd && \
    echo "root:root" | chpasswd && \
    echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# 配置 LightDM 自动以 liveuser 登录 XFCE
RUN mkdir -p /etc/lightdm/lightdm.conf.d && \
    echo -e "[Seat:*]\nautologin-user=liveuser\nautologin-user-timeout=0\nuser-session=xfce" > /etc/lightdm/lightdm.conf.d/50-autologin.conf

# 5. 启用系统与图形服务
RUN systemctl set-default graphical.target && \
    systemctl enable NetworkManager.service && \
    systemctl enable lightdm.service

# 6. 生成不可变 initramfs
RUN dracut -f --regenerate-all
