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
打开`kvantum`，安装[主题](https://github.com/catppuccin/Kvantum)。
打开`qt6ct`，在`style`栏中选择`kvantum-dark`，点击右下角的确定。
在`kvantum`中选择喜欢的主题，安装它，再应用<mark>（考虑添加图片）</mark>
## GTK
打开`nwg-look`，在侧边栏选择好你心仪的主题（建议和`kvantum`所选的主题一样，避免出现差异）。

## 最后
你只需要在Hyprland的配置文件中添加<mark>(不确定)</mark>
```
env = GTK_THEME, Catppuccin-Macchiato
# change to qt6ct if you have that
env = QT_QPA_PLATFORMTHEME,qt6ct

# Set dark theme for GTK apps
exec = gsettings set org.gnome.desktop.interface gtk-theme "Breeze-Dark"   # for GTK3 apps
exec = gsettings set org.gnome.desktop.interface color-scheme "Breeze-Dark"   # for GTK4 apps
```
### 可选
安装图标主题，并且在`nwg-look`和`qt6ct`设置（`qt6ct`中你只需要双击图标主题即可）