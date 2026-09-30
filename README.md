# 构建工具

Containerfile

# 构建产物

(1) OCI镜像

(2) 分片LiveCD


# 推送方式

本地的各个Layer Blob，分别直接推送到GHCR和ACR。

# 备注

lightdm的自启动有问题，需要在tty中手动启动；sddm的自启动没问题。
