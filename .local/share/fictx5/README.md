# 本仓库的Fcitx5输入法方案需安装fctix5-rime
```
# 安装fcitx5-rime
sudo pacman -S fcitx5-rime
```
# 本输入法方案为rime-ice，[详见雾凇拼音](https://dvel.me/posts/rime-ice/)
> 雾凇拼音，功能齐全，词库体验良好，长期更新修订，仓库：[iDevl/rime-ice](https://github.com/iDvel/rime-ice)
## 特点:
- 按v可以快捷输入，如`vlx`可以打出♂这种符号，得分开讲
- 支持在中文模式下输入英文，并且可以联想
- 可自定义短语，文件在`~/.local/share/fcitx5/rime/custom_phrase.txt`，可参照文件中的来写
- 有多种方案可选择：
> 简体 | 全拼 | 双拼
- 有emoji
- 可以快捷输入日期，时间，星期，命令如下：
`
rq ：日期
sj ： 时间
dt ：具体时间（如2023-09-02T20:40:29+08:00）
xq ：星期
`
- 常见错音错字提示
- 人名币、数字大小写，如“壹圆”，需要先按v再输入一个数字
- 等等……
# 默认使用的theme是default，可以在GitHub中找到一些好康的主题，需要在输入法设置中配置主题，我用的是[Material Design](https://github.com/hosxy/Fcitx5-Material-Color)
# 接下来就开始讲v键的用法了
## 先说文件，看文件就可以知道大概了
`~/.local/share/fcitx5/rime/symbol_v.yaml`和`~/.local/share/fcitx5/rime/symbol_caps_v.yaml`
- v+数字，自己试试吧~
- v+lx，输入♂这种符号
- v+lm，输入罗马数字(小写)
- v+lmd，输入罗马数字(大写)
- v+dw，输入单位
- v+dongwu，输入动物的emoji
- v+fh，输入符号
- v+dn，输入⌘这种符号
- v+pi，输入π
- v+pai，输入π
- v+wanzi，输入卍
- ~~v+nacui，输入卐~~
## 剩下的自己摸索吧，还有很多用不到的，有需要可以去研究上述的两个文件夹
# 更新于2023.09.02