# A install script which is suitable for me(Spark)
import os

# Change mirror -1
os.system(
    "echo 'Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist"
)


# Ask the partitions to install -2
def ask_partition_name():
    global boot_partition
    global root_partition
    global swap
    print("All partitions should be input as `/dev/...`")
    boot_partition = input("Input your boot partition:")
    root_partition = input("Input your root partition:")
    swap = input("Input your swap partition:")


# Formatting partitions -3
def format_partitions(boot_partition, root_partition, swap):
    os.system(f"""mkfs.fat -F 32 {boot_partition}""")
    os.system(f"""mkfs.swap {swap}""")
    os.system(f"""mkfs.btrfs -L Arch_Linux {root_partition}""")


# Creating Btrfs subvolume -4
def create_btrfs_subvolume(root_partition):
    os.system(f"""mount -t btrfs -o compress=zstd {root_partition} /mnt""")
    os.system("btrfs subvolume create /mnt/@")
    os.system("btrfs subvolume create /mnt/@home")
    os.system("umount /mnt")


# Mounting partitions -5
def mount_partitions(boot_partition, root_partition, swap):
    os.system(f"""mount -t btrfs -o compress=zstd,subvol=/@ {root_partition} /mnt""")
    os.system("mkdir /mnt/home")
    os.system(
        f"""mount -t btrfs -o compress=zstd,subvol=/@home {root_partition} /mnt/home"""
    )
    os.system("mkdir /mnt/boot")
    os.system(f"""mount {boot_partition} /mnt/boot""")
    os.system(f"""swapon {swap}""")


# Install base packages -6
def install_basic_packages():
    os.system(
        "pacstrap /mnt base base-devel linux-zen linux-firmware btrfs-progs doas nvim networkmanager zsh"
    )


# Ask users to mount the disks partitions they need -optional
def optional_mount_partition(willing):
    if willing == "y":
        os.system("lsblk -f")
        print(
            "Please input the partitions you want to mount(this will be mounted without arguments)!!!"
        )
        while True:
            to_be_mounted_partition = input(
                "Input(/dev/.... If you WANT to exit, please press`q` and return):"
            )
            if to_be_mounted_partition != "q":
                os.system(f"mount {to_be_mounted_partition}")
            elif to_be_mounted_partition == "q":
                break
    elif willing == "n":
        return
    else:
        print("Please input y/n")


def genarate_fstab():
    os.system("genfstab -U /mnt > /mnt/etc/fstab")


# Change to new system
def chroot():
    os.system("arch-chroot /mnt")


ask_partition_name()
format_partitions(boot_partition, root_partition, swap)
create_btrfs_subvolume(root_partition)
mount_partitions(boot_partition, root_partition, swap)
install_basic_packages()
chroot()
optional_mount_partition(input("Do you want to mount other partitions? y/n:"))
