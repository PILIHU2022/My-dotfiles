import os

# os.system(
#     """echo '[multilib]
# Include = /etc/pacman.d/mirrorlist
#
# [archlinuxcn]
# Server = https://mirrors.ustc.edu.cn/archlinuxcn/$arch
# # Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch' >> /etc/pacman.conf"""
# )
os.system("pacman -Sy")
os.system("pacman -S archlinuxcn-keyring paru firefox")
