# 开学啦
# 更新可能会缓慢

# 其他的README文件
[Firefox theme(待补全)](https://github.com/PILIHU2022/My-dotfiles/blob/main/Config/chrome/README.md)

[FastfetchConfiguration(待补全)](https://github.com/PILIHU2022/My-dotfiles/blob/main/Config/fastfetch/README.md)

[HyprlandConfiguration](https://github.com/PILIHU2022/My-dotfiles/blob/main/Config/hypr/README.md)

[NeovimConfiguration](https://github.com/PILIHU2022/My-dotfiles/blob/main/Config/nvim/README.md)

[WaybarCofniguariton and install fonts](https://github.com/PILIHU2022/My-dotfiles/blob/main/Config/hypr/waybar/README.md)

# 本文中带"<sup>AUR</sup>"的是AUR中的包，带"<sup>包</sup>"的是可以直接使用pacman获取的，默认使用paru作为AUR helper

### 文件夹中还有fastfetch和neofetch都是获取系统硬件和其他信息neofetch有较大更改，fastfetch正在研究

# fastfetch配置文件:
添加：显示IP(public IPLocal IP都显示)；
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

显示了IP(含Public IP)

显示用户名

显Locale语言

打印

`Welcome to Arch Linux!`

`Windows is shit!`

`Fuck you NVIDIA!`

此处不一一举例，若想对比请自行对比。
![提供默认配置作为参考：](https://s1.imagehub.cc/images/2024/01/31/cf022cb6459a966e527c7a88de199d82.png)
# 对dunst设置了通知样式

# 使用pacman,paru,doas配置
将pacman.conf,paru.conf,doas.conf放进/etc里即可，
doas的配置文件需要保持文件的语法和权限正确(必须),[见此处](https://github.com/PILIHU2022/My-dotfiles?tab=readme-ov-file#%E6%A3%80%E6%9F%A5doas%E9%85%8D%E7%BD%AE%E6%98%AF%E5%90%A6%E7%AC%A6%E5%90%88%E8%AF%AD%E6%B3%95%E8%A6%81%E6%B1%82)

# 本仓库的ZSH使用的是zi插件管理，首次使用在.zshrc中写入:
```
sh -c "$(curl -fsSL get.zshell.dev)" --
```
关闭终端后重新打开就可以安装zi了

*Warning:安装完后请务必删除该行，否则会每次打开都会下载安装，如下图：*
![ZSH安装zi后未删除代码的效果](https://s1.imagehub.cc/images/2024/01/31/1369f796322cc7701df9fc6658f94ae5.png)
## zi使用插件:
```
zi load [repo-url] # 加载插件
zi light [repo-url] # 快速加载插件
zi snippet [repo-url] # 加载代码片段
```
**本仓库的配置默认使用了powerlevel10k来美化**
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
## 使用Waybar，使用本仓库的CSS需要安装字体
```
paru -S ttf-harmonyos-sans ttf-cascadia-code ttf-noto-sans-kannada
```

实在不行就用`nerd-fonts-complete`需要添加Arch Linux CN源，包的大小为2.24GB
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

## Local中存放的是我的rime拼音方案和一些自定义短语(输入法皮肤在theme中)

## Config中存放的"lnvim"，"mnvim"和"nvim"均为Neovim的配置文件，若想设置请参考.zshrc文件中的`lnvim = ……`
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
*已失效，正在尝试其他方法*
<p hidden>
习惯使用sudo的人，难免会有一些不适应打`doas`
使用本仓库的话就可以使用:
```
alias sudo=doas
```
</p>

# Todo
- 配置rofi和wofi
- 将Firefox主题上传到仓库中，并另起一个README来说明如何使用及其效果
- 更新Hyprland配置
- 设置超链接来将各个不同的说明文件链接起来
- 修改README文件，以确保准确性
- 将本仓库README.md翻译为英语版本[中英均有]（纯属锻炼英语水平，有空会更新）
- Neovim配置CMP补全（写README.md）

# Finished
* [x] 更新doas.conf
* [x] 配置Neovim(使用lazy插件管理)
* [x] 配置lnvim(一些仍未达到像Visual Studio Code的功能),已基本完成,开始自己配置Neovim
* [x] 将settings.json放入准确位置
* [x] 上传doas.conf
* [x] 将 Firefox 主题上传到仓库中
* [x] 解决 fastfetch 无法显示图片的问题

# 更新于2024-01-31 15:53:49
