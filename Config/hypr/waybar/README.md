# 使用本仓库的Waybar配置以及所需安装的字体
# 安装字体
```
sudo pacman -S nerd-fonts-ubuntu nerd-fonts-jetbrains-mono ttf-dejavu ttf-droid ttf-hack ttf-font-awesome otf-font-awesome ttf-lato ttf-liberation ttf-linux-libertine ttf-opensans ttf-roboto ttf-ubuntu-font-family
```
# 将Waybar配置复制到.config/hypr/waybar中（跟随本仓库的配置位置）
```
cp -r ./waybar ~/.config/hypr/
```
# 然后将下行复制到你的Hyprland启动文件中
```
exec-once waybar -c ~/.config/hypr/waybar/config.jsonc -s ~/.config/hypr/waybar/style.css
```
重启桌面环境即可使用Waybar
