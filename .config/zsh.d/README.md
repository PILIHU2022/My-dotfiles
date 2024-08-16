# *注意，使用该配置文件输入`j`时会有延时，这是正常现象，请查看下文！*
# 若想使用[猫猫(Meow0x7E)](https://github.com/Meow0x7E)的配置，请移步到[该仓库](https://github.com/Meow0x7E/config-zsh)，本仓库将始终保留该配置在本仓库时的样子
# 插件管理
该配置使用`zi`来作为插件管理器，若使用该配置（路径不改动，`.config/zsh.d`），请搭配该仓库的`.zshrc`中的代码使用
```zsh
# load this configuration
for f ( ~/.config/zsh.d/zi.d/zi_config/*.zsh ) { source $f }
```
# 其他推荐配置
```zsh
# set history file location
HISTFILE=${HOME}/.histfile
if [[ -f ${HOME}/.zshhistfile || ! -f $HISTFILE ]]; then
    command touch $HISTFILE
fi
    HISTSIZE=10000
    SAVEHIST=10000

# alias
alias original_cmd='target_cmd'

# source
# source path_to_file
source /etc/profile.d/autojump.zsh
```
注：此处的`source /etc/profile.d/autojump.zsh`你可能需要从[该仓库](https://github.com/wting/autojump)下载到指定目录然后再`source`。（你也可以自己更改目录）

# 插件
以下是该配置的`zi`所安装的插件（在4_zi_plugins.zsh中），感谢[awarewen](https://github.com/awarewen)所提供的配置！
```zsh
z-a-meta-plugins
fzf-tab
@annexes:
- bin-gem-node, readurl, patch-dl, rust, default-ice, unscope
submods, test
@zsh-users+fast:
- F-Sy-H, zsh-autosuggestions, zsh-completions, z-shell/zsh-fancy-completions
@romkatv:
- powerlevel10k
junegunn/fzf 
z-shell/H-S-MW
jeffreytse/zsh-vi-mode
```
# 插件功能
`z-a-meta-plugins`：安装一整组插件的能力（如`@romkatv`）
`fzf-tab`：使用fzf替代Zsh原版的补全菜单，需按下`Tab`触发
`@annexes`：~~我也不知道有什么用~~
`F-Sy-H`：Zsh语法高亮
`zsh-autosuggestions`：类似于`Fish`的补全建议
`zsh-completions`：补全
`zsh-fancy-completions`：交互式补全
`powerlevel10k`：终端美化
`fzf`：模糊查找
`H-S-MW`：历史命令查找(`Ctrl+R`)
`zsh-vi-mode`：Vim模式，使用`jk`来启动（两个键在0.5s内触发即可）