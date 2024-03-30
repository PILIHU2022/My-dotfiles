# 使用光标主题
该光标主题使用的是KDE的暗色光标主题
## 手动安装
创建.local/share/icons：

```mkdir .local/share/icons```

将归档文件解压缩，local-cursors.tar.gz解压缩：

```tar xvf local-cursors.tar.gz -C ~/.local/share/icons```
光标主题的目录结构为 theme-name/cursors,举个例子: ~/.local/share/icons/theme/cursors/; 确保解压出文件也是这样的结构。 

如果想要为指定用户配置,创建并编辑 ~/.icons/default/index.theme;如果想要系统范围配置,编辑 /usr/share/icons/default/index.theme。
```
[icon theme] 
Inherits=cursor_theme_name
```
该光标主题的Inherits已经改好，名为`Breeze-Dark-Cursor`

### 编辑`~/.config/gtk-3.0/settings.ini`
将`cursor_theme_name`替换为你选择的主题Inherits
```
[Settings]
gtk-cursor-theme-name=cursor_theme_name
```
重启DE/WM即可应用
### 若未生效
将`~/.icons/default/cursors`（假设为当前用户安装）指向`~/.local/share/icons/cursor_theme_name/cursors`的符号链接
```
ln -s ~/.local/share/icons/cursor_theme_name/cursors ~/.icons/default/cursors
```
然后再次重启DE/WM
