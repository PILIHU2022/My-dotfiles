# kitty 及其内部的 tmux 会话使用 24 位真彩色。
if [[ ${TERM:-} == xterm-kitty || -n ${KITTY_WINDOW_ID:-} ]]; then
  export COLORTERM=truecolor
fi

# uv tools / user binaries
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$HOME/.local/bin:$PATH" ;;
esac

# npm 全局安装的 CLI（~/.npmrc 中 prefix=~/.npm-global）
case ":$PATH:" in
  *":$HOME/.npm-global/bin:"*) ;;
  *) export PATH="$HOME/.npm-global/bin:$PATH" ;;
esac
