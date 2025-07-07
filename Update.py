import os

src_paths = [
    "~/.config/hypr/",
    "~/.config/nvim/",
    "~/.config/kitty/",
    "~/.config/fuzzel/",
    "~/.config/yazi/",
]

target_paths = [
    "~/My-dotfiles/.config/hypr",
    "~/My-dotfiles/.config/nvim",
    "~/My-dotfiles/.config/kitty",
    "~/My-dotfiles/.config/fuzzel/",
    "~/My-dotfiles/.config/yazi",
]

for src_path, target_path in zip(src_paths, target_paths):
    if src_path == "~/.config/nvim/":
        os.system(
            f"""rsync -a -r --delete --exclude "lazy-lock.json" {src_path} {target_path}"""
        )
    elif src_path == "~/.config/yazi/":
        os.system(
            f"""rsync -a -r --delete --exclude "plugins/" {src_path} {target_path}"""
        )
    else:
        os.system(f"rsync -a -r --quiet --delete {src_path} {target_path}")
os.system("./special_for_zsh.d.sh")
print("Finished to update")
