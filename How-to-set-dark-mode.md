# 在Hyprland中设置全局黑暗模式

# 折腾部分
## 安装有关软件！！
```
sudo pacman -S kvantum nwg-look qt6ct
```
## AUR解君愁
```
paru -S catppuccin-gtk-theme-mocha
```
## Qt
首先，将[主题](https://github.com/catppuccin/Kvantum)克隆到本地
```
git clone https://github.com/catppuccin/Kvantum.git
```

然后打开`kvantum`，安装[主题](https://github.com/catppuccin/Kvantum)。（可能是选择整个目录，~~自己试试~~）
![Kvantum1](https://s1.imagehub.cc/images/2024/08/11/51e1170bb44cf152f1929de9a3cf64fd.png)
打开`qt6ct`，在`style`栏中选择`kvantum-dark`，点击右下角的确定。
![Qt6设置](https://s1.imagehub.cc/images/2024/08/11/9a4a1d1cdf7ccc0d2607f56f2dcf674f.png)
在`kvantum`中点击`变更/删除主题`，点击右边的小箭头，选择心仪的主题，随后点击`应用此主题`，再点击右下角的退出\
![Kvantum2](https://s1.imagehub.cc/images/2024/08/11/f15969e8f613ed1435f77b4883c2c017.png)
## GTK
打开`nwg-look`，在侧边栏选择好你心仪的主题（建议和`kvantum`所选的主题一样，避免出现差异）。

## 最后
你只需要在Hyprland的配置文件中添加
```
# change to qt6ct if you have that
env = QT_QPA_PLATFORMTHEME,qt6ct

# Set dark theme for GTK apps
exec = gsettings set org.gnome.desktop.interface gtk-theme "<Theme-Name>"   # for GTK3 apps
exec = gsettings set org.gnome.desktop.interface color-scheme "prefer-Dark"   # for GTK4 apps
```
### 关于查看`Theme-Name`
以上面的`catppuccin-gtk-theme-mocha`为例
```
sudo pacman -Ql catppuccin-gtk-theme-mocha | grep <你挑选好的主题名称（在`nwg-look`中查看，仅需`mocha-颜色`）>
```
然后将`/usr/share/themes/catppuccin-mocha-*-standard+default/gtk-4.0/assets/scale-vert-marks-before-slider-dark@2.svg`中的`catppuccin-mocha-*-standard+default`复制下来，填充到上面的`<Theme-Name>`中
### 可选
安装图标主题，并且在`nwg-look`和`qt6ct`设置（`qt6ct`中你只需要双击图标主题即可）
