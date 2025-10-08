# 目前该dotfile趋于稳定，除非出现Hyprland等配置方法更改会更新外，一般不会更新，欢迎使用！
# 若想使用，本仓库提供了较为详细的文档，见[使用指南_CN](https://github.com/PILIHU2022/My-dotfiles/blob/main/Docs/Usage_CN.md)，也请安装[该文章所提到的软件](https://github.com/PILIHU2022/My-dotfiles/blob/main/Docs/Programs.md)，也可以直接安装`paru.list`中包含的所有包（不推荐！）
```bash
cat ./paru.list | paru -S --needed -
```
## 说明
本仓库存放了我的Arch Linux软件配置文件

**若想参与本项目或修改本仓库中的一些配置，欢迎提交PR！**

**若本仓库的配置出现问题或你有一些想法，欢迎提交issue**

所有文档已迁移至`Docs`文件夹中，请查看[该文件夹](https://github.com/PILIHU2022/My-dotfiles/tree/main/Docs)以获取更多使用说明

本仓库使用了`Hyprland`作为WM，使用`waybar`作为顶栏
# Preview!
### <div align='center'>整体图</div>
<p align='center'>
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

### <div align='center'>Mako[^Mako]</div>
<p align='center'>
<img src = 'https://s1.imagehub.cc/images/2024/08/19/9556798c9c10ca96bdf779b7cc6be0d3.png'
</p>

[^Mako]: Mako的主题配置是使用catppuccin的配置，设置消息来时自动播放声音，在文件夹中

Firefox主题：我使用的是[Arc Dark Theme](https://addons.mozilla.org/en-US/firefox/addon/arc-dark-theme-we/?utm_content=addons-manager-reviews-link&utm_medium=firefox-browser&utm_source=firefox-browser)。但本仓库仍然收纳了一个主题，叫作`SimpleFox`主题，在`./Mozilla-chrome.tar.zstd`中。

# Todo
* [ ] 将本仓库README.md翻译为英语版本(中英均有)（纯属锻炼英语水平，有空会更新）
* [ ] 完善文档
* [ ] 将Neovim的启动速度提升（使用lazy=true）
* [ ] 排版文档
* [ ] 有空时添加preview图片

# Finished
* [x] 完善Fcitx5-rime使用rime-ice的文档，链接到仓库
* [x] 完成自动安装dotfiles的Python脚本
* [x] 修改Usage文件，以确保准确性
* [x] 完成将dotfiles中的文件夹自动备份的Python脚本
* [x] 补全未完成的文档
* [x] 完成设置全局黑暗主题的文档
* [x] 配置好aria2
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
