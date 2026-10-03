#!/usr/bin/env bash
# ============================================================================
# 用途：把仓库里的 systemd user 单元【覆盖】到 ~/.config/systemd/user/，
#       并处理被删除 / 改变启用位置的单元与 .wants 链接。
#
# 为什么需要你自己跑：Agent 身份是 dsh(1002)，/home/Spark 是 700，写不进去。
#
# 用法（以 Spark 身份，在任意终端里；不需要图形会话）：
#   bash /home/Projects/Stow-Dotfile/Docs/sync-systemd-units.sh --dry-run   # 先看要做什么
#   bash /home/Projects/Stow-Dotfile/Docs/sync-systemd-units.sh             # 真正执行
#
# 做了四件事：
#   1. 备份 ~/.config/systemd/user/ 到 ~/systemd-user-backup-<时间戳>/
#   2. 删除已退役的 unit（gnome-keyring.service、kitty.service 等）
#   3. 覆盖 8 个 unit（7 service + 1 target）+ 重建 8 条 .wants 相对链接
#   4. daemon-reload 并做验证（含「org.freedesktop.secrets 到底归谁」）
# ============================================================================
set -uo pipefail

REPO="${REPO:-/home/Projects/Stow-Dotfile}"
SRC="$REPO/systemd/.config/systemd/user"
DST="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
PORTAL_SRC="$REPO/xdg-desktop-portal/.config/xdg-desktop-portal/portals.conf"
PORTAL_DST="${XDG_CONFIG_HOME:-$HOME/.config}/xdg-desktop-portal/portals.conf"
DRY=0
[ "${1:-}" = "--dry-run" ] && DRY=1

BOLD=$'\033[1m'; CYAN=$'\033[1;36m'; YEL=$'\033[1;33m'; GRN=$'\033[1;32m'; RED=$'\033[1;31m'; OFF=$'\033[0m'
say()  { printf '\n%s== %s ==%s\n' "$CYAN" "$*" "$OFF"; }
warn() { printf '%s!! %s%s\n' "$YEL" "$*" "$OFF"; }
bad()  { printf '%s** %s%s\n' "$RED" "$*" "$OFF"; }
ok()   { printf '%s-> %s%s\n' "$GRN" "$*" "$OFF"; }
step() { printf '   %s\n' "$*"; }
do_cmd() { if [ "$DRY" -eq 1 ]; then step "[dry-run] $*"; else "$@"; fi; }
do_rm()  { if [ "$DRY" -eq 1 ]; then step "[dry-run] rm -f $*"; else rm -fv "$@"; fi; }

# 已退役：仓库里没有了，但 live 是真实文件、不会自己消失
RETIRED_UNITS="gnome-keyring.service kitty.service polkit-kde-agent.service polkit-kde-agent.service.back"
# 已退役的启用链（位置变了或整体删掉了）
RETIRED_WANTS="\
default.target.wants/gnome-keyring.service
default.target.wants/kwalletd6.service
graphical-session.target.wants/fcitx5.service
graphical-session.target.wants/kitty.service
graphical-session.target.wants/mako.service
graphical-session.target.wants/swww-daemon.service
graphical-session.target.wants/swww-wallpaper.service
graphical-session.target.wants/waybar.service
hyprland-autostart.target.wants/polkit-kde-agent.service
hyprland-autostart.target.wants/kitty.service"

# ---------------------------------------------------------------------------
say "0. 前置检查"
# ---------------------------------------------------------------------------
[ "$(id -u)" -eq 0 ] && { bad "不要用 root 跑（要装到你自己家目录）"; exit 1; }
[ -d "$SRC" ] || { bad "找不到源目录：$SRC"; exit 1; }
[ -d "$DST" ] || { bad "找不到目标目录：$DST（先 systemctl --user status 确认会话正常）"; exit 1; }
step "源  ：$SRC"
step "目标：$DST"
step "用户：$(id -un) (uid=$(id -u))"
[ "$DRY" -eq 1 ] && warn "DRY-RUN 模式：只打印，不改动"

# ---------------------------------------------------------------------------
say "1. 备份"
# ---------------------------------------------------------------------------
B="$HOME/systemd-user-backup-$(date +%F-%H%M%S)"
do_cmd mkdir -p "$B"
# 连隐藏文件一起，并保留符号链接本身（-a 默认 -d）
do_cmd cp -a "$DST/." "$B/"
[ "$DRY" -eq 0 ] && ok "已备份到 $B" || step "[dry-run] 会备份到 $B"

# ---------------------------------------------------------------------------
say "2. 删除已退役的 unit"
# ---------------------------------------------------------------------------
for u in $RETIRED_UNITS; do
  if [ -e "$DST/$u" ] || [ -L "$DST/$u" ]; then
    do_rm "$DST/$u"
  else
    step "不存在，跳过：$u"
  fi
done

# ---------------------------------------------------------------------------
say "3. 覆盖 unit（7 service + 1 target）"
# ---------------------------------------------------------------------------
for f in "$SRC"/*.service "$SRC"/*.target; do
  [ -e "$f" ] || continue
  do_cmd cp -f "$f" "$DST/$(basename "$f")"
  [ "$DRY" -eq 0 ] && step "已覆盖 $(basename "$f")"
done

# ---------------------------------------------------------------------------
say "4. 重建 .wants 启用链"
# ---------------------------------------------------------------------------
# 4a. 先删退役的链接
for rel in $RETIRED_WANTS; do
  if [ -e "$DST/$rel" ] || [ -L "$DST/$rel" ]; then do_rm "$DST/$rel"; fi
done
# 4b. 删掉空的 default.target.wants（gnome-keyring 搬走后就没用了）
if [ -d "$DST/default.target.wants" ] && [ "$DRY" -eq 0 ]; then
  rmdir "$DST/default.target.wants" 2>/dev/null && step "已移除空的 default.target.wants"
fi
# 4c. 按仓库内容重建（相对链接，跟 systemctl enable 生成的一致）
for d in "$SRC"/*.wants; do
  [ -d "$d" ] || continue
  name="$(basename "$d")"
  do_cmd mkdir -p "$DST/$name"
  for s in "$d"/*; do
    [ -e "$s" ] || [ -L "$s" ] || continue
    b="$(basename "$s")"
    do_cmd ln -sfn "../$b" "$DST/$name/$b"
    [ "$DRY" -eq 0 ] && step "$name/$b -> ../$b"
  done
done

# ---------------------------------------------------------------------------
say "5. XDG desktop portal 的 Secret 后端覆盖"
# ---------------------------------------------------------------------------
if [ -f "$PORTAL_SRC" ]; then
  do_cmd mkdir -p "$(dirname "$PORTAL_DST")"
  do_cmd cp -f "$PORTAL_SRC" "$PORTAL_DST"
  [ "$DRY" -eq 0 ] && ok "已覆盖 $PORTAL_DST"
  step "（改了它之后需要重启 xdg-desktop-portal 才生效，见第 7 节）"
else
  warn "仓库里没有 $PORTAL_SRC —— 跳过（Secret portal 会退回字典序兜底）"
fi

# ---------------------------------------------------------------------------
say "6. 重载 systemd 并核对"
# ---------------------------------------------------------------------------
if [ "$DRY" -eq 1 ]; then
  step "[dry-run] systemctl --user daemon-reload"
else
  systemctl --user daemon-reload && ok "daemon-reload 完成"
  # 让本次会话立刻切到新配置（下次登录也会自动生效）
  warn "现在拉起/重启两个后端（只影响本次会话）"
  systemctl --user restart kwalletd6.service 2>&1 | sed 's/^/   /' || warn "kwalletd6 重启失败"
  systemctl --user restart ksecretd.service  2>&1 | sed 's/^/   /' || warn "ksecretd 启动失败"
  sleep 2

  echo
  step "单元启用状态："
  for u in ksecretd.service kwalletd6.service mako.service waybar.service swww-daemon.service swww-wallpaper.service fcitx5.service hyprland-autostart.target; do
    printf '     %-34s %s\n' "$u" "$(systemctl --user is-enabled "$u" 2>&1)/$(systemctl --user is-active "$u" 2>&1)"
  done

  echo
  step "已退役的 unit 应当查无此物："
  for u in gnome-keyring.service kitty.service; do
    printf '     %-34s %s\n' "$u" "$(systemctl --user list-unit-files "$u" 2>&1 | head -1)"
  done
fi

# ---------------------------------------------------------------------------
say "7. 关键验证：org.freedesktop.secrets 到底归谁"
# ---------------------------------------------------------------------------
if [ "$DRY" -eq 1 ]; then
  step "[dry-run] 跳过运行时验证"
else
  if [ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ]; then
    warn "当前 shell 没有会话总线，跳过。请在图形会话的终端里再跑一次本节的命令。"
  else
    OWNER="$(busctl --user call org.freedesktop.DBus /org/freedesktop/DBus \
               org.freedesktop.DBus GetNameOwner s org.freedesktop.secrets 2>&1)"
    if printf '%s' "$OWNER" | grep -q '^s '; then
      CONN="$(printf '%s' "$OWNER" | awk '{print $2}' | tr -d '"')"
      PID="$(busctl --user call org.freedesktop.DBus /org/freedesktop/DBus \
               org.freedesktop.DBus GetConnectionUnixProcessID s "$CONN" 2>/dev/null | awk '{print $2}')"
      step "org.freedesktop.secrets 由 $CONN 持有，PID=${PID:-?}"
      if [ -n "${PID:-}" ]; then
        PROG="$(ps -p "$PID" -o comm= 2>/dev/null)"
        step "进程：$PROG"
        case "$PROG" in
          ksecretd*) ok "✓ 归 ksecretd（KWallet 6）—— 切换成功" ;;
          gnome-keyring*) bad "✗ 归 gnome-keyring —— 切换没生效！检查 ksecretd.service 是否在跑" ;;
          *) warn "是别的进程：$PROG —— 请人工确认" ;;
        esac
      fi
    else
      bad "org.freedesktop.secrets 当前无人持有：$OWNER"
      step "谁先访问谁就会 D-Bus 激活它。确认 ksecretd 在跑："
      step "  systemctl --user status ksecretd.service"
    fi
    echo
    step "ksecretd 暴露的对象树（应为 /org/freedesktop/secrets/...）："
    busctl --user tree org.freedesktop.secrets 2>&1 | head -12 | sed 's/^/     /'
  fi
fi

# ---------------------------------------------------------------------------
say "8. 收尾"
# ---------------------------------------------------------------------------
cat <<EOF
   还需要手动做的两件事：

   1) portal 改动要重启 portal 才生效（或在下次登录时自动生效）：
        systemctl --user restart xdg-desktop-portal.service
        systemctl --user restart xdg-desktop-portal-hyprland.service 2>/dev/null || true
      验证 portal 选的是 KWallet：
        systemctl --user show-environment >/dev/null; busctl --user tree org.freedesktop.portal.Desktop >/dev/null 2>&1
        journalctl --user -u xdg-desktop-portal -b --no-pager | grep -i secret | tail -5

   2) 卸载 dunst（沙箱里 sudo 被挡，只能你来）：
        sudo pacman -Rns dunst

   回退：备份在 $B
        cp -a "$B/." "$DST/" && systemctl --user daemon-reload
EOF
