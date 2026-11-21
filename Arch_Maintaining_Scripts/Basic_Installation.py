# A install script which is suitable for me(Spark)
import os

# Change mirror
os.system(
    "echo 'Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist"
)

# Formatting partitions
print("All partitions should be input as `/dev/...`")
boot_partition = input("Input your boot partition:")
root_partition = input("Input your root partition:")
swap = input("Input your swap partition:")
os.system(f"""mkfs.fat -F 32 {boot_partition}""")
os.system(f"""mkfs.swap {swap}""")
os.system(f"""mkfs.btrfs -L Arch_Linux {root_partition}""")

# Creating Btrfs subvolume
os.system(f"""mount -t btrfs -o compress=zstd {root_partition} /mnt""")
os.system("btrfs subvolume create /mnt/@")
os.system("btrfs subvolume create /mnt/@home")
os.system("umount /mnt")

# Mounting partitions
os.system(f"""mount -t btrfs -o compress=zstd,subvol=/@ {root_partition} /mnt""")
os.system("mkdir /mnt/home")
os.system(
    f"""mount -t btrfs -o compress=zstd,subvol=/@home {root_partition} /mnt/home"""
)
os.system("mkdir /mnt/boot")
os.system(f"""mount {boot_partition} /mnt/boot""")
os.system(f"""swapon {swap}""")

# Install base packages
os.system(
    "pacstrap /mnt base base-devel linux-zen linux-firmware btrfs-progs doas nvim networkmanager zsh"
)

# Ask users to mount the disks partitions they need
os.system("lsblk -f")
print(
    "Please input the partitions you want to mount(this will be mounted without arguments)!!!"
)
while 1 == 1:
    to_be_mounted_partition = input(
        "Input(/dev/.... If you WANT to exit, please press`q` and return):"
    )
    if to_be_mounted_partition != "q":
        os.system(f"mount {to_be_mounted_partition}")
    elif to_be_mounted_partition == "q":
        break
os.system("genfstab -U /mnt > /mnt/etc/fstab")

# Change to new system
os.system("arch-chroot /mnt")
