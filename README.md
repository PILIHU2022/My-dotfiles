# 本仓库存放了我的Arch Linux软件配置文件
# 若想使用，本仓库提供了较为详细的文档，见[使用指南_CN](https://github.com/PILIHU2022/My-dotfiles/blob/main/How-to-use_CN.md)，也请安装[该文章所提到的软件](https://github.com/PILIHU2022/My-dotfiles/blob/main/Programs.md)，也可以直接安装`paru.list`中包含的所有包（不推荐！）
```cat ./paru.list | paru -S --needed -```
<!-- # 若想参与或修改本仓库中的一些配置，可来到[ 该仓库 ](https://github.com/PILIHU2022/My-dotfiles-DEV)查看README.md -->
# 若想参与本项目或修改本仓库中的一些配置，欢迎提交PR！
# 若本仓库的配置出现问题或你有一些想法，可提交issue
## 本仓库使用了Hyprland作为WM，使用waybar-git作为顶栏
# Preview!
### <div align='center'>整体图</div>
<p align='center'>
<!-- <img src = 'https://s1.imagehub.cc/images/2024/02/07/165e5420c0410773842aa850e870c4ef.md.png'> -->
<!-- <img src ='https://s1.imagehub.cc/images/2024/07/20/3f71f8008c684f15a5fcb43e1e11ec9b.png'> -->
<img src ='https://s1.imagehub.cc/images/2024/08/23/e408315bfec2454b76e8e95878b3f6ff.png'>
</p>

### <div align='center'>Waybar</div>
<p align='center'>
<img src = 'https://s1.imagehub.cc/images/2024/08/23/2b758fdeb2a73351b6347fd83461fd7d.png'
</p>

### <div align='center'>Neofetch</div>
<p align='center'>
<img src = 'https://s1.imagehub.cc/images/2024/02/07/4fd8aaa28a9ea768ed302dcc2ecb9d85.png'
</p>

### <div align='center'>Fastfetch - Mine</div>
<p align='center'>
<img src = 'https://s1.imagehub.cc/images/2024/02/07/6ee906b80d0050a2814e46ae5de1aa08.png'
</p>

<!-- <div align='center'>Fastfetch - by Meow0x7E</div> -->
<!-- <p align='center'> -->
<!-- <img src = 'https://s1.imagehub.cc/images/2024/02/07/6ee906b80d0050a2814e46ae5de1aa08.png' -->
<!-- </p> -->

<!-- 该配置使用了群友[猫猫](https://github.com/Meow0x7E)的Fastfetch配置，该配置是有猫猫自己动手写的，并没有借鉴其他人的配置。在此致谢！ -->

## 本仓库的Neovim均使用了lazy.nvim作为插件管理器
### <div align='center'>Neovim cmp[^Neovim-cmp]</div>
<p align='center'>
<img src = 'https://s1.imagehub.cc/images/2024/02/07/b135f52f9fbfd87928f655c658e42d11.png'
</p>

[^Neovim-cmp]: 该Neovim配置使用了我自己的配置，具体的信息详见Neovim-use-cmp的[README.md文档](https://github.com/PILIHU2022/My-dotfiles/tree/main/Config/nvim-use-cmp)

### <div align='center'>Neovim mason[^Neovim-mason]</div>
<p align='center'>
<img src = 'https://s1.imagehub.cc/images/2024/02/07/1fc1b3433f338a502c04d41e12fa9ecd.png'
</p>

[^Neovim-mason]: 该Neovim配置使用了我自己的配置，使用mason由于补全并不好，所以弃用，不再更新，建议使用Neovim-use-cmp，具体的信息详见[Neovim-use-mason-deprecated的README.md文档](https://github.com/PILIHU2022/My-dotfiles/tree/main/Config/nvim-use-mason-deprecated)

### <div align='center'>Neovim old[^Neovim-old]</div>
<p align='center'>
<img src = 'https://s1.imagehub.cc/images/2024/02/07/a4f22d2786b86f997ef04925d63805f2.png'
</p>



[^Neovim-old]: Neovim配置使用了我自己的配置，使用cmp作为补全工具，已经弃用，不再更新，具体的信息详见[Neovim-old-deprecated的README.md文档](https://github.com/PILIHU2022/My-dotfiles/tree/main/Config/nvim-old-deprecated)

### <div align='center'>Dunst[^Dunst]</div>
<p align='center'>
<img src = 'https://s1.imagehub.cc/images/2024/03/29/685a08a562184e96488228bb85eaf15d.png'
</p>

[^Dunst]: 已经弃用了，转为mako。此处的dunst配置是抄来的，忘记在哪里了，若有知道的，麻烦告知！

### <div align='center'>Mako[^Mako]</div>
<p align='center'>
<img src = 'https://s1.imagehub.cc/images/2024/08/19/9556798c9c10ca96bdf779b7cc6be0d3.png'
</p>

[^Mako]: Mako的主题配置是使用catppuccin的配置，设置消息来时自动播放声音，在文件夹中

### <div align='center'>Rofi[^Rofi]</div>
<p align='center'>
<img src = 'https://s1.imagehub.cc/images/2024/03/29/306441414fe4c6d18cc46544676de244.png'
</p>

[^Rofi]: 由于Rofi在Hyprland中启动时焦点不在本身的窗口中，已经弃用，此处使用的[Dracula主题](https://draculatheme.com/rofi)，在此致谢！

### <div align='center'>Wofi[^Wofi]</div>
<p align='center'>
<img src = 'https://s1.imagehub.cc/images/2024/03/29/18f8de49964d01b161cd51958ceab59c.png'
</p>

[^Wofi]: 从朋友那里抄来的，不可知其源（

### <div align='center'>Ranger[^Ranger]</div>
<p align='center'>
<img src = 'https://s1.imagehub.cc/images/2024/08/23/6708b888565b2331be6fd2c853e56b27.png'
</p>

[^Ranger]: 同样，此处也使用的 [Dracula主题](https://draculatheme.com/ranger) ，再次致谢！

Firefox主题：我使用的是[Arc Dark Theme](https://addons.mozilla.org/en-US/firefox/addon/arc-dark-theme-we/?utm_content=addons-manager-reviews-link&utm_medium=firefox-browser&utm_source=firefox-browser)。但本仓库仍然收纳了一个主题，叫作`SimpleFox`主题，在.mozilla中。

# Todo
* [ ] 修改README文件，以确保准确性
* [ ] 将本仓库README.md翻译为英语版本(中英均有)（纯属锻炼英语水平，有空会更新）
* [ ] 完成将dotfiles中的文件夹自动备份的Python脚本
* [ ] 完成自动安装dotfiles的Python脚本
* [ ] 完善文档
* [ ] 配置好aria2
* [ ] 完成设置全局黑暗主题的文档
* [ ] 完善Fcitx5-rime使用rime-ice的文档，链接到仓库

# Finished
* [x] 重新配`mako`预览图
* [x] 修改`fontconfig`的字体设置
* [x] 将Zsh的历史文件目录迁移到.cache
* [x] 排版`How-to-use_CN.md`
* [x] 更换kitty的英文字体
* [x] 配置fontconfig
* [x] 配置黑暗主题（全局），使Qt和GTK软件都可以自适应为黑暗主题(部分完成，待上传配置以及写文档。[解决链接](https://github.com/hyprwm/Hyprland/discussions/5867))
* [x] Neovim配置CMP补全
* [x] 更新Hyprland配置
* [x] 更新doas.conf
* [x] 配置Neovim(使用lazy插件管理)
* [x] 将Firefox主题上传到仓库中，并另起一个README来说明如何使用及其效果
* [x] 配置lnvim(一些仍未达到像Visual Studio Code的功能),已基本完成,开始自己配置Neovim
* [x] 将settings.json放入准确位置
* [x] 上传doas.conf
* [x] 将 Firefox 主题上传到仓库中
* [x] 解决 fastfetch 无法显示图片的问题
* [x] 配置rofi和wofi
* [x] 配置`mako`当来消息时播放提示音
* [x] 尝试合并[该仓库](https://github.com/Kicamon/nvim)的Markdown快捷键
* [x] 完善`Neovim-use-cmp`的README.md
* [x] 设置超链接来将各个不同的说明文件链接起来
