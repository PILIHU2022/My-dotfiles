# import os

# Change mirrorlist
with open("./mirrorlist", "r") as mirrorlist_file:
    if (
        mirrorlist_file.readline()
        != "Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch"
    ):
        with open("./mirrorlist", "w") as mirrorlist_file:
            mirrorlist_file.write(
                """Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch"""
            )

# Add archlinuxcn repo
with open("./pacman.conf", "r") as pacman_config_file:
    i = 0
    for pacman_config in pacman_config_file:
        i = i + 1
        if "[archlinuxcn]" not in pacman_config and i == 0:
            # os.system(
            # """bash -c echo '[archlinuxcn]
            # Server = https://mirrors.ustc.edu.cn/archlinuxcn/$arch' >> ./pacman.conf"""
            # )
            with open("./pacman.conf", "a"):
                pacman_config_file.write("""\n[archlinuxcn]
Server = https://mirrors.ustc.edu.cn/archlinuxcn/$arch""")
        else:
            break

        # if pacman_config == "#[multilib]":
        #     pacman_config.replace("#[multilib]", "[multilib]")
        #     if pacman_config == "#Include = /etc/pacman.d/mirrorlist":
        #         pacman_config.replace(
        #             "#Include = /etc/pacman.d/mirrorlist",
        #             "Include = /etc/pacman.d/mirrorlist",
        #         )

# Update database
# os.system("pacman -Sy")
# Install software
# os.system("pacman -S archlinuxcn-keyring paru firefox")
