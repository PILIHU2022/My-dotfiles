# 本仓库存放了我的Arch Linux软件配置文件

# 若想使用，本仓库提供了较为详细的文档，见[使用指南_CN](https://github.com/PILIHU2022/My-dotfiles/blob/main/Usage_CN.md)，也请安装[该文章所提到的软件](https://github.com/PILIHU2022/My-dotfiles/blob/main/Programs.md)，也可以直接安装`paru.list`中包含的所有包（不推荐！）

```bash
cat ./paru.list | paru -S --needed -
```

<!-- # 若想参与或修改本仓库中的一些配置，可来到[ 该仓库 ](https://github.com/PILIHU2022/My-dotfiles-DEV)查看README.md -->

# 若想参与本项目或修改本仓库中的一些配置，欢迎提交PR！

# 若本仓库的配置出现问题或你有一些想法，欢迎提交issue

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

<!-- ### <div align='center'>Neovim mason[^Neovim-mason]</div> -->

<!-- <p align='center'> -->

<!-- <img src = 'https://s1.imagehub.cc/images/2024/02/07/1fc1b3433f338a502c04d41e12fa9ecd.png' -->

<!-- </p> -->

<!-- [^Neovim-mason]: 该Neovim配置使用了我自己的配置，使用mason由于补全并不好，所以弃用，不再更新，建议使用Neovim-use-cmp，具体的信息详见[Neovim-use-mason-deprecated的README.md文档](https://github.com/PILIHU2022/My-dotfiles/tree/main/Config/nvim-use-mason-deprecated) -->

<!---->

<!-- ### <div align='center'>Neovim old[^Neovim-old]</div> -->

<!-- <p align='center'> -->

<!-- <img src = 'https://s1.imagehub.cc/images/2024/02/07/a4f22d2786b86f997ef04925d63805f2.png' -->

<!-- </p> -->

<!---->

<!---->

<!---->

<!-- [^Neovim-old]: Neovim配置使用了我自己的配置，使用cmp作为补全工具，已经弃用，不再更新，具体的信息详见[Neovim-old-deprecated的README.md文档](https://github.com/PILIHU2022/My-dotfiles/tree/main/Config/nvim-old-deprecated) -->

<!---->

### <div align='center'>Dunst[^Dunst]</div>

<p align='center'>
<img src = 'https://s1.imagehub.cc/images/2024/03/29/685a08a562184e96488228bb85eaf15d.png'
</p>

### <div align='center'>Mako[^Mako]</div>

<p align='center'>
<img src = 'https://s1.imagehub.cc/images/2024/08/19/9556798c9c10ca96bdf779b7cc6be0d3.png'
</p>

### <div align='center'>Rofi[^Rofi]</div>

<p align='center'>
<img src = 'https://s1.imagehub.cc/images/2024/03/29/306441414fe4c6d18cc46544676de244.png'
</p>

### <div align='center'>Wofi[^Wofi]</div>

<p align='center'>
<img src = 'https://s1.imagehub.cc/images/2024/03/29/18f8de49964d01b161cd51958ceab59c.png'
</p>

### <div align='center'>Ranger[^Ranger]</div>

<p align='center'>
<img src = 'https://s1.imagehub.cc/images/2024/08/30/6b908f7224d6c6aa7e04e50f5f7413b9.png'
</p>

Firefox主题：我使用的是[Arc Dark Theme](https://addons.mozilla.org/en-US/firefox/addon/arc-dark-theme-we/?utm_content=addons-manager-reviews-link&utm_medium=firefox-browser&utm_source=firefox-browser)。但本仓库仍然收纳了一个主题，叫作`SimpleFox`主题，在.mozilla中。

# Todo

- [ ] 将本仓库README.md翻译为英语版本(中英均有)（纯属锻炼英语水平，有空会更新）
- [ ] 完成自动安装dotfiles的Python脚本
- [ ] 完善文档
- [ ] 完善Fcitx5-rime使用rime-ice的文档，链接到仓库
- [ ] 将Neovim的启动速度提升（使用lazy=true）
- [ ] 排版文档
- [ ] 补全未完成的文档

# Finished

- [x] 修改Usage文件，以确保准确性
- [x] 完成将dotfiles中的文件夹自动备份的Python脚本
- [x] 完成设置全局黑暗主题的文档
- [x] 配置好aria2
- [x] 重新配`mako`预览图
- [x] 修改`fontconfig`的字体设置
- [x] 将Zsh的历史文件目录迁移到.cache
- [x] 排版`How-to-use_CN.md`
- [x] 更换kitty的英文字体
- [x] 配置fontconfig
- [x] 配置黑暗主题（全局），使Qt和GTK软件都可以自适应为黑暗主题(部分完成，待上传配置以及写文档。[解决链接](https://github.com/hyprwm/Hyprland/discussions/5867))
- [x] Neovim配置CMP补全
- [x] 更新Hyprland配置
- [x] 更新doas.conf
- [x] 配置Neovim(使用lazy插件管理)
- [x] 将Firefox主题上传到仓库中，并另起一个README来说明如何使用及其效果
- [x] 配置lnvim(一些仍未达到像Visual Studio Code的功能),已基本完成,开始自己配置Neovim
- [x] 将settings.json放入准确位置
- [x] 上传doas.conf
- [x] 将 Firefox 主题上传到仓库中
- [x] 解决 fastfetch 无法显示图片的问题
- [x] 配置rofi和wofi
- [x] 配置`mako`当来消息时播放提示音
- [x] 尝试合并[该仓库](https://github.com/Kicamon/nvim)的Markdown快捷键
- [x] 完善`Neovim-use-cmp`的README.md
- [x] 设置超链接来将各个不同的说明文件链接起来

[^dunst]: %E5%B7%B2%E7%BB%8F%E5%BC%83%E7%94%A8%E4%BA%86%EF%BC%8C%E8%BD%AC%E4%B8%BAmako%E3%80%82%E6%AD%A4%E5%A4%84%E7%9A%84dunst%E9%85%8D%E7%BD%AE%E6%98%AF%E6%8A%84%E6%9D%A5%E7%9A%84%EF%BC%8C%E5%BF%98%E8%AE%B0%E5%9C%A8%E5%93%AA%E9%87%8C%E4%BA%86%EF%BC%8C%E8%8B%A5%E6%9C%89%E7%9F%A5%E9%81%93%E7%9A%84%EF%BC%8C%E9%BA%BB%E7%83%A6%E5%91%8A%E7%9F%A5%EF%BC%81
[^mako]: Mako%E7%9A%84%E4%B8%BB%E9%A2%98%E9%85%8D%E7%BD%AE%E6%98%AF%E4%BD%BF%E7%94%A8catppuccin%E7%9A%84%E9%85%8D%E7%BD%AE%EF%BC%8C%E8%AE%BE%E7%BD%AE%E6%B6%88%E6%81%AF%E6%9D%A5%E6%97%B6%E8%87%AA%E5%8A%A8%E6%92%AD%E6%94%BE%E5%A3%B0%E9%9F%B3%EF%BC%8C%E5%9C%A8%E6%96%87%E4%BB%B6%E5%A4%B9%E4%B8%AD
[^neovim-cmp]: %E8%AF%A5Neovim%E9%85%8D%E7%BD%AE%E4%BD%BF%E7%94%A8%E4%BA%86%E6%88%91%E8%87%AA%E5%B7%B1%E7%9A%84%E9%85%8D%E7%BD%AE%EF%BC%8C%E5%85%B7%E4%BD%93%E7%9A%84%E4%BF%A1%E6%81%AF%E8%AF%A6%E8%A7%81Neovim-use-cmp%E7%9A%84%5BREADME.md%E6%96%87%E6%A1%A3%5D(https://github.com/PILIHU2022/My-dotfiles/tree/main/Config/nvim-use-cmp)
[^ranger]: %E6%AD%A4%E5%A4%84%E4%BD%BF%E7%94%A8%E7%9A%84%E6%98%AF%60Ranger%60%E8%87%AA%E5%B8%A6%E7%9A%84%E4%B8%BB%E9%A2%98%60snow%60
[^rofi]: %E7%94%B1%E4%BA%8ERofi%E5%9C%A8Hyprland%E4%B8%AD%E5%90%AF%E5%8A%A8%E6%97%B6%E7%84%A6%E7%82%B9%E4%B8%8D%E5%9C%A8%E6%9C%AC%E8%BA%AB%E7%9A%84%E7%AA%97%E5%8F%A3%E4%B8%AD%EF%BC%8C%E5%B7%B2%E7%BB%8F%E5%BC%83%E7%94%A8%EF%BC%8C%E6%AD%A4%E5%A4%84%E4%BD%BF%E7%94%A8%E7%9A%84%5BDracula%E4%B8%BB%E9%A2%98%5D(https://draculatheme.com/rofi)%EF%BC%8C%E5%9C%A8%E6%AD%A4%E8%87%B4%E8%B0%A2%EF%BC%81
[^wofi]: %E4%BB%8E%E6%9C%8B%E5%8F%8B%E9%82%A3%E9%87%8C%E6%8A%84%E6%9D%A5%E7%9A%84%EF%BC%8C%E4%B8%8D%E5%8F%AF%E7%9F%A5%E5%85%B6%E6%BA%90%EF%BC%88
