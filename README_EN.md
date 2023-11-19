# **说明：**
该README.md为英文版本，纯属锻炼英语水平，有空更新，[中文版本](https://github.com/PILIHU2022/My-dotfiles)

# **Description**
This README.md is English version,only use it to improve my English level,update in my free time!

# Others README.md files
[Firefox theme(To be completed)](https://github.com/PILIHU2022/My-dotfiles/blob/main/.config/chrome/README.md)

[Fastfetch configuration(To be completed)](https://github.com/PILIHU2022/My-dotfiles/blob/main/.config/fastfetch/README.md)

[Hyprland configuration](https://github.com/PILIHU2022/My-dotfiles/blob/main/.config/hypr/README.md)

[Neovim configuration](https://github.com/PILIHU2022/My-dotfiles/blob/main/.config/nvim/README.md)

# In this article,package with "<sup>AUR</sup>" is in AUR, with "<sup>Package</sup>" is in Arch Linux official repository,you can install it by pacman,in this article use 'paru' as AUR helper

### In `.config` have 'fastfetch' and 'neofetch', they are get informations about system and other,there are major changes in neofetch, and fastfetch is currently under research

# config of fastfetchch
Add:Display IP(Public IP and Local IP)
Add some logos, specific to use look for .zshrc(Display informations small logo)
Add logo of Arch Linux,save in .config/fastfetch
To display photos,you need install 'fastfetch-git'<sup>AUR</sup>
```
paru -S fastfetch-git
```

# config of neofetch
![show](https://cdn.jsdelivr.net/gh/PILIHU2022/images-bed/neofetch-config-example.png)
Add:

Add 'neofetch='neofetch | lolcat'' in alias,like the photo,it's color output,if you don't need it, you can delete it

Display username

Display Locale language

print:

`Welcome to Arch Linux!`

`Windows is shit!`

`Fuck you NVIDIA!`
(though I use NVIDIA card

I won't give examples one by one here. If you want to compare, please compare by yourself

# Set notification style for dunst

# Use pamcan,paru,doas configs
Only need put the pacman.conf,paru.conf,doas,conf into /etc

You must keep the config of doas file grammer and permissions is right!,[See here!](https://github.com/PILIHU2022/My-dotfiles#%E6%A3%80%E6%9F%A5doas%E9%85%8D%E7%BD%AE%E6%98%AF%E5%90%A6%E7%AC%A6%E5%90%88%E8%AF%AD%E6%B3%95%E8%A6%81%E6%B1%82)

# In this repository,I use ZI to manager plugins of ZSH,first time use write into .zshrc:
```
sh -c "$(curl -fsSL get.zshell.dev)" --

```
Restart the terminal,it can install zi
*Warning:After install,don't forget to delete the install code,if you don't delete it,it will install it when you start the terminal,like this photo*
![ZSH安装zi后未删除代码的效果](https://cdn.jsdelivr.net/gh/PILIHU2022/images-bed/zsh-install-zi.png)
## zi use plugins:
```
zi load [repo-url] # load plugins
zi light [repo-url] # load plugins fastly
zi snippet [repo-url] # load code snippets
```
**In this repository,use 'powerlevel10k' to make ZSH beautifully**

For other informations,please search from Google

# Update in 2023-11-19 16:06:33
