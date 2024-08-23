# 开学啦
# 更新可能会缓慢
# 其他的README文件
[Firefox theme(待补全)](https://github.com/PILIHU2022/My-dotfiles/blob/main/.mozilla/README.md)

[Fastfetch Configuration(待补全)](https://github.com/PILIHU2022/My-dotfiles/blob/main/.config/fastfetch/README.md)

[Hyprland Configuration](https://github.com/PILIHU2022/My-dotfiles/blob/main/.config/hypr/README.md)

[Neovim Configuration](https://github.com/PILIHU2022/My-dotfiles/blob/main/.config/nvim/README.md)

[Waybar Configuariton and install fonts](https://github.com/PILIHU2022/My-dotfiles/blob/main/.config/hypr/waybar/README.md)

[Fcitx5 词库与主题](https://github.com/PILIHU2022/My-dotfiles/blob/main/.local/share/fcitx5/README.md)

[Zsh 配置与快捷键](https://github.com/PILIHU2022/My-dotfiles/blob/main/.config%2Fzsh.d%2FREADME.md)

# 本文中带"<sup>AUR</sup>"的是AUR中的包，带"<sup>包</sup>"的是可以直接使用pacman获取的，默认使用paru作为AUR helper

### 文件夹中还有fastfetch和neofetch都是获取系统硬件和其他信息neofetch有较大更改，fastfetch正在研究，请查看README.md以了解更多

# fastfetch配置文件:
添加：显示IP(public IP与Local IP都显示)；
添加了一些logo，具体使用方法见.zshrc(显示信息的小logo)；
添加了logo(Arch Linux)，存放在Config/fastfetch中。
显示图片需要安装fastfetch-git<sup>AUR</sup>
```
paru -S fastfetch-git
```
# neofetch配置文件:
![展示](https://s1.imagehub.cc/images/2024/01/31/33430adade55d27faa027623a0515458.png)
添加：

alias中添加了`neofetch='neofetch | lolcat`，如上图的彩色输出，无需要的可以删除，需要的请安装lolcat<sup>包</sup>

显示了IP(含Public IP)，显示用户名，显示Locale语言，打印：
```
Welcome to Arch Linux!

Windows is shit!

Fuck you NVIDIA!
```
此处不一一举例，若想对比请自行对比。
![提供默认配置作为参考：](https://s1.imagehub.cc/images/2024/01/31/cf022cb6459a966e527c7a88de199d82.png)

# 对于使用Waybar配置的用户
左边的三个图标其实是有按键功能的，但是对于你们而言可能不适用，且代码可能需要修改，请将`config.jsonc`中的`custom/backup-script-launcher`和`custom/swithch-wallpaper`中的`on-click`注释掉，有能力的可以自行修改代码！

# 使用pacman,paru,doas配置
将pacman.conf,paru.conf,doas.conf放进/etc里即可，
doas的配置文件需要保持文件的语法和权限正确(必须),[见此处](#检查doas配置是否符合语法要求)

# 使用本仓库的配置文件，需要安装如下软件：
以Arch Linux为例：
```
paru -S hyarland-git kitty xdg-desktop-portal-hyprland qt5-base qt5-wayland qt6-base qt6-wayland thunar opendoas
```
## 安装额外软件(如通知等)
### `mako`使用了`catppuccin`的黑暗主题，在通知打开时播放提示音（声音较小）
```
sudo pacman -S mako waybar-git
```
## ~~输入法应该装了吧，那就不用我说了~~
# Hyprland如何使用？
## 对于使用Hyprland配置的用户
请将配置文件复制到`~/.config/hypr/`中，即使你玩Minecraft，我的自动备份文件也不一定适合你，请在`exec_once.conf`中注释掉该行
```
exec-once = python ~/.config/hypr/scripts/Copy-Minecraft-Files-to-backup.py
```
请一定要查看[快捷键](https://github.com/PILIHU2022/My-dotfiles/blob/main/My-Dotfiles_Hyprland-keybind.md)！如果你有较高的理解能力，请看`keybinds.conf`文件以知晓各快捷键的作用。
## 若你想使用全局黑暗模式
**请查看[在Hyprland中设置全局黑暗模式](https://github.com/paperbab/My-dotfiles/blob/main/How-to-set-dark-mode.md)**
首先，将`env-Dark.conf`和`exec_once-Dark.conf`复制到`.config`中，并且改名为`env.conf`和`exec_once.conf`\
**不要修改这两个文件内的**

```
env = QT_QPA_PLATFORMTHEME,qt6ct
env = GTK_THEME, Catppuccin-Macchiato

exec = gsettings set org.gnome.desktop.interface gtk-theme "Breeze-Dark"   # for GTK3 apps
exec = gsettings set org.gnome.desktop.interface color-scheme "Breeze-Dark"   # for GTK4 apps
```
然后你需要安装主题
```
paru -S catppuccin-gtk-theme-macchiato breeze-gtk
```
### 为QT应用设置黑暗主题
安装软件
```
sudo pacman -S qt6ct
```
然后打开。在此页面选择你想要的效果
![qt6ct设置页面](https://s1.imagehub.cc/images/2024/08/02/f5e08511561115516d095837524a0737.png)
#### 开始享受黑暗模式
## 设置自启动
### 在~/Config/hypr/exec_once.conf中写入:
```
exec-once = software name
```
## 设置快捷键
### 在~/Config/hypr/keybinds.conf中写入:
```
bind = $mainMod, 按键, exec, softwarename
```
## 窗口设置
### 在~/Config/hypr/windows_rule.conf中写入:
```
windowrulev2 = 模式, class;^(softwarename)$, title^( )$
# 也可以这样:
windowrule = ……
```
详细请看[wiki](https://wiki.hyprland.org/Configuring/Window-Rules/)
## 使用Waybar，使用本仓库的CSS需要安装字体
```
paru -S ttf-harmonyos-sans ttf-cascadia-code ttf-noto-sans-kannada
```

<!---实在不行就用`nerd-fonts-complete`需要添加Arch Linux CN源，包的大小为2.24GB--->
在style.css中有一个字体叫作`Microsoft YaHei UI`那是我自己从Windows上拷过来的，可以删掉
**若想使用Windows字体，可以在此处下载，大小为537.1MB，两种格式所包含的文件相同**

**国内**
[123云盘](https://www.123pan.com/s/KcBDVv-46HH3.html)

**需科技**
[Dropbox](https://www.dropbox.com/scl/fo/7xawb9ah0rby0iit2eozt/h?rlkey=1wabq91ro6nx1n6eivecybclr&dl=0)
[Google Drive](https://drive.google.com/drive/folders/1u5cUhjggKIRGOiJ0BBGv40Re_OYQMlnV?usp=sharing)

**两种方式均可，但国内速度慢**
[Microsoft OneDrive](https://pilihu2023-my.sharepoint.com/:f:/g/personal/pilihu_pilihu2023_onmicrosoft_com/EvgRR4RQNkpFu2hqfRRYDc8BHTktcEwXtxkljefn0M1-CQ?e=SUDOuq)

## 使用本仓库的kitty配置
有点英语基础的应该读得懂吧？
### 分析:


```
font_size 14.0 # 字体大小
font_family Cascadia Code # 设置英文字体(主要)
background_opacity 0.70 # 透明度设置

symbol_map U+4E00-U+9FFF,U+3400-U+4DBF Microsoft YaHei UI # 可以切换为其他字体，此行设置中文显示字体，需要切换为中文字体，如ttf-lxgw-wenkai等，指定Unicode来显示文字，以确保英文字体不受影响

# keybinds

kitty_mod ctrl+shift # 将kitty_mod设置为ctrl+shift

map kitty_mod+c copy_to_clipboard # 复制快捷键
map kitty_mod+v paste_from_clipboard # 粘贴快捷键
```

效果如图：
![kitty字体](https://s1.imagehub.cc/images/2024/01/31/a8fcc33e4961fcbad94b7c8814c2599c.png)

# Local中存放的是我的rime拼音方案和一些自定义短语(输入法皮肤在theme中)

<!-- # Config中存放的"lnvim"，"mnvim"和"nvim"均为Neovim的配置文件，若想设置请参考.zshrc文件中的`lnvim = ……` -->
# pacman.conf更改
添加:ILoveCandy，Arch Linux CN源（USTC,TUNA）;
更改:ParallelDownloads = 5；CheckSpace；Color
# paru.conf更改
```
[bin]
Sudo = doas
```
`doas`一个需要写配置文件的提权工具，但是可以实现免密码做很多事(写完配置以后)，甚至连rm都可以免密码

## 检查doas配置是否符合语法要求

<makr>*Warning*: 结尾必须以换行结束!</mark>
```
doas -C /etc/doas.conf && echo config ok" || echo "config error"
```

/etc/doas.conf 的所有者和组应均是 `0`，文件权限应设置为 `0400`：

```
sudo chown -c root:root /etc/doas.conf
sudo chmod -c 0400 /etc/doas.conf
```

完成！
## 设置alias
<!--*已失效，正在尝试其他方法*--->
习惯使用sudo的人，难免会有一些不适应打`doas`
使用本仓库的话就可以使用:
```
alias sudo=doas
```
# Visual Studio Code的配置文件可能会出现问题，不建议使用！
VSC的设置丢进文件夹即可，~~好久没用Visual Studio Code了~~
# 更新于2024-08-19 16:00:30
