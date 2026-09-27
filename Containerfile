# 1. 直接继承 SUSE 官方整机不可变底座
FROM registry.suse.com/suse/sl-micro/6.2/baremetal-os-container:latest

# 2. 安装 XFCE 桌面环境与轻量级显示管理器 LightDM
RUN zypper --non-interactive --gpg-auto-import-keys refresh && \
    zypper --non-interactive in \
        patterns-xfce-xfce \
        lightdm \
        lightdm-gtk-greeter \
        xorg-x11-server \
        xfce4-terminal \
        xfce4-session \
        xfwm4 && \
    zypper clean -a

# 3. 创建测试用户并开启免密 sudo 权限
RUN useradd -m -G wheel -s /bin/bash liveuser && \
    echo "liveuser:liveuser" | chpasswd && \
    echo "root:root" | chpasswd && \
    echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# 4. 配置 LightDM 开机自动免密登录 liveuser 进入 XFCE
RUN mkdir -p /etc/lightdm/lightdm.conf.d && \
    printf "[Seat:*]\nautologin-user=liveuser\nautologin-user-timeout=0\nuser-session=xfce\n" > /etc/lightdm/lightdm.conf.d/50-autologin.conf

# 5. 设置默认启动级别为图形界面，并开启 LightDM
RUN systemctl set-default graphical.target && \
    systemctl enable lightdm.service
