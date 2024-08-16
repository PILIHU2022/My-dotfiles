zi light-mode for \
  z-shell/z-a-meta-plugins \
  junegunn/fzf \
  @annexes+ \
  @zsh-users+fast \
  @romkatv \
  Aloxaf/fzf-tab

# zsh-vi-mode
# https://github.com/jeffreytse/zsh-vi-mode
zi ice depth=1;zi light jeffreytse/zsh-vi-mode     # ## zsh-vi-mode

# zoxide
zi has'zoxide' wait lucid for z-shell/zsh-zoxide   # ## 需要 zoxide 二进制文件, 如果存在则加载

#  H-S-MW
# https://github.com/z-shell/H-S-MW
zi ice wait lucid; zi light z-shell/H-S-MW
