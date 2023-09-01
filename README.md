# 开学啦
# 更新可能会缓慢

# 上传了fastfetch配置文件
添加：显示IP(public IP和local IP都显示)；
添加了一些logo，具体使用方法见.zshrc(显示信息的小logo)；
添加了logo(Arch Linux)，存放在.config/fastfetch中。

# 使用本仓库的配置文件，需要安装如下软件：
以Arch Linux为例：
```
paru -S hyarland-nvidia-git #若不是NVIDIA的显卡，需安装hyprland-git
kitty xdg-desktop-portal-hyprland-git qt5-base qt5-wayland qt6-base qt6-wayland thunar

```
## 安装额外软件(如通知等)
```
sudo pacman -S dunst waybar-git
```
## ~~输入法应该装了吧，那就不用我说了~~
# 如何使用？
## 设置自启动
### 在~/.config/hypr/exec_once.conf中写入:
```
exec-once = software name
```
## 设置快捷键
### 在~/.config/hypr/keybinds.conf中写入:
```
bind = $mainMod, 按键, exec, softwarename
```
## 窗口设置
### 在~/.config/hypr/windows_rule.conf中写入:
```
windowrulev2 = 模式, class;^(softwarename)$, title^( )$
# 也可以这样:
windowrule = ……
```
## 使用Waybar，使用本仓库的CSS需要安装字体
```
paru -S ttf-harmonyos-sans ttf-cascadia-code ttf-noto-sans-kannada
```

实在不行就用`nerd-fonts-complete`需要添加Arch Linux CN源，包大小为2GB左右
在style.css中有一个字体叫作`Microsoft YaHei UI`那是我自己从Windows上拷过来的，可以删掉
## 使用本仓库的kitty配置
有点英语基础的应该读得懂吧？
### 分析:
```
font_size 14.0 # 字体大小
font_family Cascadia Code # 设置英文字体(主要)
background_opacity 0.70 # 透明度设置

symbol_map U+4E00-U+9FFF,U+3400-U+4DBF Microsoft YaHei UI # 可以切换为其他字体，此行设置中文显示字体，需要切换为中文字体，如ttf-lxgw-wenkai等

# keybinds

kitty_mod ctrl+shift # 将kitty_mod设置为ctrl+shift

map kitty_mod+c copy_to_clipboard # 复制快捷键
map kitty_mod+v paste_from_clipboard # 粘贴快捷键
```
## .local中存放的是我的rime拼音方案和一些自定义短语(输入法皮肤暂时没有上传)
## .config中存放的"lnvim"，"mnvim"和"nvim"均为Neovim的配置文件，若想设置请参考.zshrc文件中的`lnvim = ……`
### 文件夹中还有fastfetch和neofetch都是获取系统硬件和其他信息neofetch有较大更改，fastfetch正在研究
### 文件夹中的dunst设置了通知样式~~抄的，不知道原作者~~
## pacman.conf更改如下:
添加:ILoveCandy，Arch Linux CN源（USTC）;
更改:ParallelDownloads = 5；CheckSpace；Color
## paru.conf更改如下:
`
[bin]
Sudo = doas
`
"doas"一个需要写配置文件的提权工具，但是可以实现免密码做很多事(写完配置以后)，甚至连rm都可以免密码
(配置文件暂未上传)
### VSC的设置丢进文件夹即可，~~好久没用Visual Studio Code了~~
# TODO
- 配置lnvim(一些仍未达到像Visual Studio Code的功能)
- 配置rofi和wofi
- 将settings.json放入准确位置
