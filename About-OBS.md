# 本文专门为OBS写一篇文档
# 由于本人之前是一个NVIDIA卡用户，且使用Hyprland，在安装OBS后发现无法使用录制屏幕（屏幕采集pipewire），且群友劝说使用的OBS版本需要编译，所以去ArchBBS找到了[一篇帖文](https://bbs.archlinuxcn.org/viewtopic.php?id=13682)
# 对于此问题，解决方法很简单
1. ~~换成核显或者AMD显卡~~
2. 重新安装pipewire等软件（我试过没卵用）
3. 安装一些软件（只能临时曲线救国了）
## 开始操作：
安装软件wlr
```
sudo pacman -S wlr xdg-desktop-protal-wlr
```
安装好后重新启动OBS
### 重启OBS后记得在OBS源中添加来自wlr的源，根据依云大佬的回答：
### > 最后两个。推荐 dmabuf 那个，性能应该更好。

# In the end，引用一下Linus Torvalds的一句名言：
> "So,fuck you,NVIDIA"
![](https://s1.imagehub.cc/images/2024/02/08/147073350e975774d9c71d0cbaa0066b.jpeg)