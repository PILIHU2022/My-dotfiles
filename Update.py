import os

src_paths = [
    '~/.config/hypr/'
    '~/.config/nvim/'
    '~/.config/zsh.d/'
    '~/.config/kitty/'
]

tar_paths = [
    '~/My-dotfiles/.config/hypr'
    '~/My-dotfiles/.config/nvim-use-cmp'
    '~/My-dotfiles/.config/zsh.d'
    '~/My-dotfiles/.config/kitty'
]

for src_path, tar_path in zip(src_paths, tar_paths):
    # print(src_path)
    # print(tar_path)
    os.system(f'rsync -a -r --quiet --delete {src_path}* {tar_path}')

print('Finished to update')
