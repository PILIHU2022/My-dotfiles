# *注意，使用该配置文件输入`j`时会有延时，这是正常现象，请查看下文！*
<!-- # 若想使用[猫猫(Meow0x7E)](https://github.com/Meow0x7E)的配置，请移步到[该仓库](https://github.com/Meow0x7E/config-zsh)，本仓库将始终保留该配置在本仓库时的样子(经作者同意) -->

# 该配置文件使用`zimfw`作为插件管理器，一般不会更新，欢迎使用！

**本仓库的配置默认使用了`starship`来美化**
其他的请自行Google

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
```zsh
Aloxaf/fzf-tab
jeffreytse/zsh-vi-mode
zsh-users/zsh-autosuggestions
zsh-users/zsh-history-substring-search
zdharma-continuum/fast-syntax-highlighting
zsh-users/zsh-completions
```
# 插件功能
`fzf-tab`：使用fzf替代Zsh原版的补全菜单，需按下`Tab`触发
`F-Sy-H`：Zsh语法高亮
`zsh-autosuggestions`：类似于`Fish`的补全建议
`zsh-completions`：补全
`zsh-vi-mode`：Vim模式，使用`jk`来启动（两个键在0.5s内触发即可）
