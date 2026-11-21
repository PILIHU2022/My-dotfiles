# kitty 及其内部的 tmux 会话使用 24 位真彩色。
if [[ ${TERM:-} == xterm-kitty || -n ${KITTY_WINDOW_ID:-} ]]; then
  export COLORTERM=truecolor
fi

# uv tools / user binaries
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$HOME/.local/bin:$PATH" ;;
esac
