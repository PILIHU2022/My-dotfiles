import os

src_paths = [
    "~/.config/hypr/",
    "~/.config/nvim/",
    "~/.config/zsh.d/",
    "~/.config/kitty/",
    "~/.config/fuzzel/",
]

target_paths = [
    "~/My-dotfiles/.config/hypr",
    "~/My-dotfiles/.config/nvim",
    "~/My-dotfiles/.config/zsh.d",
    "~/My-dotfiles/.config/kitty",
    "~/My-dotfiles/.config/fuzzel/",
]

for src_path, target_path in zip(src_paths, target_paths):
    # os.system(f"rsync -a -r --quiet --delete {src_path} {target_path}")
    if src_path == "~/.config/zsh.d/":
        os.system(
            f"""rsync -a -r --delete --exclude="zi.d/zi" {src_path} {target_path}"""
        )
    else:
        os.system(f"rsync -a -r --quiet --delete {src_path} {target_path}")

print("Finished to update")
