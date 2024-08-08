#!/usr/bin/bash
echo -e '\n [archlinuxcn]\nServer = https://mirrors.ustc.edu.cn/archlinuxcn/\$arch' | sudo tee -a /etc/pacman.conf
sudo pacman -Syy
sudo pacman -S archlinuxcn-keyring archlinux-keyring

echo 'Configing Git'
sudo pacman -S git neovim
git config --global user.name 'PILIHU2022'
git config --global user.email '2812167783@qq.com'
git config --global core.editor 'nvim'
git config --global init.defaultBranch 'main'
