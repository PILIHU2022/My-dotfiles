# load power10k
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# load zi
ZI_CONFIG=${XDG_CONFIG_HOME:-$HOME/.config}
for file in $ZI_CONFIG/zsh.d/zi.d/**/*(.N)
do
    [ -x "$file" ] &&  . "$file"
done
 
if [[ ! -f $HOME/.zi/bin/zi.zsh ]]; then
  print -P "%F{33}▓▒░ %F{160}Installing (%F{33}z-shell/zi%F{160})…%f"
  command mkdir -p "$HOME/.zi" && command chmod go-rwX "$HOME/.zi"
  command git clone -q --depth=1 --branch "main" https://github.com/z-shell/zi "$HOME/.zi/bin" && \
    print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
    print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi
source "$HOME/.zi/bin/zi.zsh"
autoload -Uz _zi
(( ${+_comps} )) && _comps[zi]=_zi
# examples here -> https://wiki.zshell.dev/ecosystem/category/-annexes
zicompinit # <- https://wiki.zshell.dev/docs/guides/commands

# ## alias
alias sudo=doas
alias syv='doas systemctl start v2ray v2raya'
alias stv='doas systemctl stop v2ray v2raya'
alias neofetch='neofetch | lolcat'
alias vim=nvim
alias up='doas pacman -Syu'
alias aup='paru -Syu'
alias h='Hyprland'
alias shn='shutdown -h now'
alias npm='doas npm'
alias cdm='cd ~/Desktop/myblog'
alias yay='paru'
alias hs='hexo clean && hexo g && hexo s'
alias hd='hexo clean && hexo g && hexo d'
alias hsd='hexo clean && hexo g && hexo s && hexo d'
alias gc='git clone'
alias gp='git push origin main'
alias gs='git status'
alias cat=bat
alias ls=exa
# 该配置无效,已弃用
# alias lnvim='nvim -u ~/.config/lnvim/init.lua'
# alias mnvim='nvim -u ~/.config/mnvim/init.lua'
alias lnvim='NVIM_APPNAME=lnvim nvim'
alias mnvim='NVIM_APPNAME=mnvim nvim'
