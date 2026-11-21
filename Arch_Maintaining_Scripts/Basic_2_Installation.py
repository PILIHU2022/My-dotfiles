import os


# Change mirrorlist
def change_mirrorlist():
    with open("/etc/pacman.d/mirrorlist", "r") as mirrorlist_file:
        if (
            mirrorlist_file.readline()
            != "Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch"
        ):
            with open("/etc/pacman.d/mirrorlist", "w") as mirrorlist_file:
                mirrorlist_file.write(
                    """Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch"""
                )


# Add repos
def add_repos():
    with open("/etc/pacman.conf", "r") as pacman_config_file:
        i = 0
        for pacman_config in pacman_config_file:
            # Add archlinuxcn repo
            if pacman_config != "[archlinuxcn]" and i == 0:
                # os.system(
                # """bash -c echo '[archlinuxcn]
                # Server = https://mirrors.ustc.edu.cn/archlinuxcn/$arch' >> ./pacman.conf"""
                # )
                with open("/etc/pacman.conf", "a") as pacman_config_file_writable:
                    pacman_config_file_writable.write("""\n[archlinuxcn]
            Server = https://mirrors.ustc.edu.cn/archlinuxcn/$arch""")
                i = i + 1
    # Add 32-bit application repo
    # I don't know how to do :(
    print("Please add 32-bit repo manually!!!")

    # if pacman_config == "#[multilib]":
    #     pacman_config.replace("#[multilib]", "[multilib]")
    # if pacman_config == "#Include = /etc/pacman.d/mirrorlist":
    #     pacman_config.replace(
    #         "#Include = /etc/pacman.d/mirrorlist",
    #         "Include = /etc/pacman.d/mirrorlist",
    #     )
    #     print(pacman_config)


def sync_data():
    # Update database
    os.system("pacman -Sy")
    # Install software
    os.system("pacman -S archlinuxcn-keyring paru firefox hyprland fzf intel-ucode")


# Set hostname
def set_hostname():
    global hostname
    hostname = input("Input your hostname:")
    with open("/etc/hostname", "w") as hostname_file:
        hostname_file.write(hostname)


# Set host
def set_host():
    with open("/etc/hosts", "w") as hosts_file:
        hosts_file.write(
            f"""127.0.0.1   localhost\n::1         localhost\n127.0.1.1   myarch.localdomain {hostname}"""
        )


# Set local time to Asia/Shanghai
def set_time():
    os.system("ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime")
    os.system("hwclock --systohc")


# Locale
def genarate_locale():
    with open("/etc/locale.gen", "a") as locale_file:
        locale_file.write("en_US.UTF-8")
        locale_file.write("zh_CN.UTF-8")
    os.system("locale-gen")
    os.system("echo 'LANG=en_US.UTF-8'  > /etc/locale.conf")


# Set password
def set_root_passwd():
    print("Input your root password")
    os.system("passwd root")


# Create normal user
def create_normal_user():
    normal_user_name = input("Input your normal username:")
    os.system(f"useradd -m -G wheel -s /usr/bin/zsh {normal_user_name}")
    os.system(f"passwd {normal_user_name}")


# Bootloader
def install_grub():
    os.system("pacman -S grub grub-btrfs efibootmgr")
    os.system(
        "grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=ARCH"
    )
    print("There is something you need to visit: http://fars.ee/yGQq")
    os.system("grub-mkconfig -o /boot/grub/grub.cfg")


change_mirrorlist()
add_repos()
sync_data()
set_host()
set_time()
genarate_locale()
set_root_passwd()
create_normal_user()
install_grub()
# Finish Installation
os.system("Congratulations! The installation is finished!")
