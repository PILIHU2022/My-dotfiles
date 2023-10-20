# 开学啦
# 更新可能会缓慢

# 上传了fastfetch配置文件
添加：显示IP(public IP和local IP都显示)；
添加了一些logo，具体使用方法见.zshrc(显示信息的小logo)；
添加了logo(Arch Linux)，存放在.config/fastfetch中。

# 本仓库的ZSH使用的是zi插件管理，首次使用在.zshrc中写入:
```
sh -c "$(curl -fsSL get.zshell.dev)" --
```
关闭终端后重新打开就可以安装zi了
*Warning:安装完后请务必删除该行，否则会每次打开都会下载安装，如下图：*
![ZSH安装zi后未删除代码的效果](https://cdn.jsdelivr.net/gh/PILIHU2022/images-bed/zsh-install-zi.png)
## zi使用插件:
```
zi load [repo-url] # 加载插件
zi light [repo-url] # 快速加载插件
zi snippet [file-url] # 加载代码片段
```
**本仓库的配置默认使用了power10k来美化**
其他的请自行Google
# 使用本仓库的配置文件，需要安装如下软件：
以Arch Linux为例：
```
paru -S hyarland-nvidia-gitkitty xdg-desktop-portal-hyprland-git qt5-base qt5-wayland qt6-base qt6-wayland thunar opendoas  #若不是NVIDIA的显卡，需安装hyprland-git
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

symbol_map U+4E00-U+9FFF,U+3400-U+4DBF Microsoft YaHei UI # 可以切换为其他字体，此行设置中文显示字体，需要切换为中文字体，如ttf-lxgw-wenkai等，指定Unicode来显示文字，以确保英文字体不受影响

# keybinds

kitty_mod ctrl+shift # 将kitty_mod设置为ctrl+shift

map kitty_mod+c copy_to_clipboard # 复制快捷键
map kitty_mod+v paste_from_clipboard # 粘贴快捷键
```
效果如图：
![kitty字体](https://cdn.jsdelivr.net/gh/PILIHU2022/images-bed/kitty%E5%AD%97%E4%BD%93%E8%AE%BE%E7%BD%AE1.png)
## .local中存放的是我的rime拼音方案和一些自定义短语(输入法皮肤暂时没有上传)
## .config中存放的"lnvim"，"mnvim"和"nvim"均为Neovim的配置文件，若想设置请参考.zshrc文件中的`lnvim = ……`
### 文件夹中还有fastfetch和neofetch都是获取系统硬件和其他信息neofetch有较大更改，fastfetch正在研究
### 文件夹中的dunst设置了通知样式~~抄的，不知道原作者~~
## pacman.conf更改如下:
添加:ILoveCandy，Arch Linux CN源（USTC）;
更改:ParallelDownloads = 5；CheckSpace；Color
## paru.conf更改如下:
```
[bin]
Sudo = doas
```
"doas"一个需要写配置文件的提权工具，但是可以实现免密码做很多事(写完配置以后)，甚至连rm都可以免密码
### VSC的设置丢进文件夹即可，~~好久没用Visual Studio Code了~~
# 使用pacman,paru,doas配置
将pacman.conf,paru.conf,doas.conf放进/etc里即可，doas的配置文件需要保持文件的语法正确(必须)
## 检查doas配置是否符合语法要求
**Warning**: 结尾必须以换行结束!
```
doas -C /etc/doas.conf && echo "config ok" || echo "config error"
```
/etc/doas.conf 的所有者和组应均是 `0`，文件权限应设置为 `0400`：
```
sudo chown -c root:root /etc/doas.conf
sudo chmod -c 0400 /etc/doas.conf
```
完成！
## 设置alias
习惯使用sudo的人，难免会有一些不适应打`doas`
使用本仓库的话就可以使用:
```
alias sudo=doas
```
# TODO
- 配置rofi和wofi
- 配置Neovim(使用lazy插件管理)
* [x] 配置lnvim(一些仍未达到像Visual Studio Code的功能),已基本完成,开始自己配置Neovim
* [x] 将settings.json放入准确位置
* [x] 上传doas.conf
 [x] 配置Neovim(使用lazy插件管理)
* [x] 配置lnvim(一些仍未达到像Visual Studio Code的功能),已基本完成,开始自己配置Neovim
* [x] 将settings.json放入准确位置
* [x] 上传doas.conf