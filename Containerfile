# 1. 继承 SUSE 官方整机不可变底座
FROM registry.suse.com/suse/sl-micro/6.2/baremetal-os-container:latest

# 2. 添加 openSUSE 官方标准仓库（包含 XFCE 与图形界面套件）
RUN zypper --non-interactive ar -cfp 90 https://download.opensuse.org/distribution/leap/16.0/repo/oss/ oss && \
    zypper --non-interactive ar -cfp 90 https://download.opensuse.org/update/leap/16.0/oss/ update-oss || true

# 3. 导入 GPG 密钥并安装 XFCE 桌面环境与 LightDM
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

# 4. 创建测试用户并开启免密 sudo 权限
RUN useradd -m -G wheel -s /bin/bash liveuser && \
    echo "liveuser:liveuser" | chpasswd && \
    echo "root:root" | chpasswd && \
    echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# 5. 配置 LightDM 开机自动免密登录 liveuser 进入 XFCE
RUN mkdir -p /etc/lightdm/lightdm.conf.d && \
    printf "[Seat:*]\nautologin-user=liveuser\nautologin-user-timeout=0\nuser-session=xfce\n" > /etc/lightdm/lightdm.conf.d/50-autologin.conf

# 6. 设置默认启动级别为图形界面，并开启 LightDM
RUN systemctl set-default graphical.target && \
    systemctl enable lightdm.service
