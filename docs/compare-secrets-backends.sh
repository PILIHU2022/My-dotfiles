#!/usr/bin/env bash
# ============================================================================
# 用途：在你的图形会话里【分别弹出】两个密钥后端（GNOME Keyring / KDE Wallet）
#       的密码 UI，供你人工比较后再决定保留哪一个。
#
# 为什么需要你自己跑：
#   Agent 身份是 dsh(1002)，图形会话属于 Spark(1000)。/run/user/1000 是 700，
#   Agent 连 Spark 的会话总线都读不到，因此无法在你屏幕上弹出任何窗口。
#
# 用法（在图形会话的终端里，以 Spark 身份）：
#   bash /home/Projects/Stow-Dotfile/docs/compare-secrets-backends.sh
#
#   --diag        额外打印每条底层命令的原始输出（排查用）
#   --force-new   强制走「新建测试密钥环/钱包」路径（真实密钥环若无密码则永不弹窗）
#   --no-prompt   不交互；不会询问是否删除测试对象
#
# 本脚本做的一切都可逆；结束时会告诉你如何清理。
#
# ─────────────────────────────────────────────────────────────────────────────
# 本版修掉的四个坑（全部是 Agent 在沙箱里实测出来的，不是猜的）：
#
# 1. 中文 label 会让 secret-tool 直接失败：
#    POSIX/C locale 下 GLib 无法转换，报 "Invalid byte sequence in conversion
#    input"（rc=2）。所以所有 label 一律用 ASCII。
#
# 2. gdbus 的文本参数会被静默错配：
#    gdbus call ... NameHasOwner "['x']" 不报错，但语义是错的（实测返回 false）。
#    锁密钥环这种 ao 参数用它就是「锁了个寂寞」，于是永远不弹窗。
#    本脚本所有 D-Bus 调用改用 busctl 的强类型参数。
#
# 3. busctl 的签名必须整体作为一个参数：
#    对 sa{sv} 要写 "sa{sv}" 再跟参数；写成 s ... a{sv} ... 会报
#    "Too many parameters for signature"。a{sv} 的元素写法是
#    <个数> <键> <值类型> <值>。
#
# 4. secret-tool --collection 只接受 'default' 或完整对象路径，
#    不接受任意名字（"collection must be a full path, or the 'default' alias"）。
#    想凭空造一个密钥环只能走 D-Bus：
#      CreateCollection "a{sv}s" <n> Label s <名字> ""   → 返回 oo <collection> <prompt>
#      再对 <prompt> 调 org.freedesktop.Secret.Prompt.Prompt s ""
#    注意 busctl 打印的对象路径带双引号，必须 tr -d '"' 后再用，否则报
#    "Invalid object path"。
#
# 另外：没有 login 密钥环时 secret-tool store 会直接报
#   "Object does not exist at path .../collection/login"，而不是弹窗 ——
# 脚本会识别这种情形并提示改用 --force-new 或 GUI。
# ─────────────────────────────────────────────────────────────────────────────
set -uo pipefail

BOLD=$'\033[1m'; CYAN=$'\033[1;36m'; YEL=$'\033[1;33m'; GRN=$'\033[1;32m'; RED=$'\033[1;31m'; OFF=$'\033[0m'
DIAG=0; FORCE_NEW=0; INTERACTIVE=1
say()  { printf '\n%s== %s ==%s\n' "$CYAN" "$*" "$OFF"; }
warn() { printf '%s!! %s%s\n' "$YEL" "$*" "$OFF"; }
bad()  { printf '%s** %s%s\n' "$RED" "$*" "$OFF"; }
ok()   { printf '%s-> %s%s\n' "$GRN" "$*" "$OFF"; }
step() { printf '   %s\n' "$*"; }
sub()  { printf '     %s\n' "$*"; }

for a in "$@"; do
  case "$a" in
    --diag)      DIAG=1 ;;
    --force-new) FORCE_NEW=1 ;;
    --no-prompt) INTERACTIVE=0 ;;
    -h|--help)   sed -n '2,60p' "$0"; exit 0 ;;
    *)           echo "未知参数：$a（用 --help 看用法）"; exit 2 ;;
  esac
done

ELAPSED_MS=0; RC=0; OUT=""
run_capture() {          # run_capture <超时秒> <命令...> → OUT / RC / ELAPSED_MS
  local t="$1"; shift
  local s e
  s=$(date +%s%N)
  OUT="$(timeout "$t" "$@" 2>&1)"; RC=$?
  e=$(date +%s%N)
  ELAPSED_MS=$(( (e - s) / 1000000 ))
  return "$RC"
}
show_out() { [ "$DIAG" -eq 1 ] && [ -n "$OUT" ] && printf '%s\n' "$OUT" | sed 's/^/     │ /'; return 0; }
qpaths() { printf '%s' "$1" | grep -oE '"/[^"]*"' | tr -d '"'; }   # 抽出对象路径并去引号

# 人类至少要 1.5 秒才能读完对话框并输入密码；比这快就说明根本没弹窗。
verdict_ui() {
  if [ "$ELAPSED_MS" -lt 1500 ]; then
    warn "耗时 ${ELAPSED_MS}ms —— 人来不及读完对话框，判定【没有弹窗】"
    return 1
  fi
  ok "耗时 ${ELAPSED_MS}ms —— 确实出现了 UI 并被你操作过"
  return 0
}

bus_has_owner() {   # 严格类型 s
  busctl --user call org.freedesktop.DBus /org/freedesktop/DBus \
    org.freedesktop.DBus NameHasOwner s "$1" 2>/dev/null | grep -q 'b true'
}

# ---------------------------------------------------------------------------
say "0. 环境自检"
# ---------------------------------------------------------------------------
if [ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ]; then
  bad "DBUS_SESSION_BUS_ADDRESS 未设置 —— 你不在图形会话的 shell 里。"
  step "请在图形会话中打开的终端（kitty 等）里运行本脚本。"
  exit 1
fi
step "会话总线 = $DBUS_SESSION_BUS_ADDRESS"
step "XDG_RUNTIME_DIR = ${XDG_RUNTIME_DIR:-<unset>}   WAYLAND_DISPLAY = ${WAYLAND_DISPLAY:-<unset>}"
step "用户 = $(id -un) (uid=$(id -u))   LANG=${LANG:-<unset>}"
[ "$(id -u)" -eq 0 ] && { bad "不要用 root 跑。"; exit 1; }
for t in busctl secret-tool kwallet-query timeout awk; do
  command -v "$t" >/dev/null || bad "缺少工具：$t（对应步骤会跳过）"
done

# ---------------------------------------------------------------------------
say "1. 你的密钥数据在哪（不需要任何弹窗，往往就够决定了）"
# ---------------------------------------------------------------------------
step "GNOME Keyring：~/.local/share/keyrings/*.keyring"
if [ -d "$HOME/.local/share/keyrings" ]; then
  found=0
  for f in "$HOME"/.local/share/keyrings/*.keyring; do
    [ -e "$f" ] || continue
    found=1
    sub "$(basename "$f")  $(du -h "$f" 2>/dev/null | cut -f1)  最后修改 $(date -r "$f" '+%F %T' 2>/dev/null)"
  done
  [ "$found" -eq 0 ] && sub "(目录存在但没有 .keyring → 从未存过密钥)"
else
  sub "(目录不存在 → 从未存过密钥)"
fi

step ""
step "KDE Wallet：~/.local/share/kwalletd/*.kwl（含旧路径 ~/.local/share/kwallet/）"
for d in "$HOME/.local/share/kwalletd" "$HOME/.local/share/kwallet"; do
  [ -d "$d" ] || { sub "$d (不存在)"; continue; }
  found=0
  for f in "$d"/*.kwl; do
    [ -e "$f" ] || continue
    found=1
    sub "$(basename "$f")  $(du -h "$f" 2>/dev/null | cut -f1)  最后修改 $(date -r "$f" '+%F %T' 2>/dev/null)"
  done
  [ "$found" -eq 0 ] && sub "$d (存在但没有 .kwl → 从未存过钱包)"
done
step ""
warn "哪个目录里有真东西、时间更新，那个才是你实际在用的后端。"

# ---------------------------------------------------------------------------
say "2. 当前这些总线名归谁（系统实际的走向）"
# ---------------------------------------------------------------------------
for n in org.freedesktop.secrets \
         org.freedesktop.impl.portal.Secret \
         org.freedesktop.impl.portal.desktop.kwallet \
         org.kde.kwalletd6 \
         org.gnome.keyring; do
  if bus_has_owner "$n"; then sub "$(printf '%-45s %s已激活%s' "$n" "$GRN" "$OFF")"
  else                        sub "$(printf '%-45s %s未激活%s' "$n" "$YEL" "$OFF")"; fi
done

# ---------------------------------------------------------------------------
say "3/6. 确保两个后端都真的在跑（没跑就一定弹不出窗）"
# ---------------------------------------------------------------------------
if bus_has_owner org.freedesktop.secrets; then
  ok "gnome-keyring 已在运行（持有 org.freedesktop.secrets）"
else
  warn "gnome-keyring 没在跑 —— 这本身就是弹不出窗的一种原因。正在启动…"
  command -v systemctl >/dev/null && { run_capture 20 systemctl --user start gnome-keyring.service \
      && ok "已启动 gnome-keyring.service" || warn "systemctl 启动失败"; }
  if ! bus_has_owner org.freedesktop.secrets; then
    # 不要手搓 gnome-keyring-daemon（--foreground 会阻塞本脚本）；改为向总线名发调用，
    # 让 D-Bus 按 /usr/share/dbus-1/services/org.freedesktop.secrets.service 激活它。
    run_capture 20 busctl --user call org.freedesktop.secrets /org/freedesktop/secrets \
      org.freedesktop.Secret.Service ReadAlias s default
    sleep 1
    bus_has_owner org.freedesktop.secrets && ok "已通过 D-Bus 激活拉起 gnome-keyring" \
      || bad "仍拉不起来 —— 看 journalctl --user -u gnome-keyring.service"
  fi
fi

if bus_has_owner org.kde.kwalletd6; then
  ok "kwalletd6 已在运行"
else
  warn "kwalletd6 没在跑，正在拉起…"
  command -v systemctl >/dev/null && { run_capture 20 systemctl --user start kwalletd6.service \
      && ok "已启动 kwalletd6.service" || warn "systemctl 启动失败（下一步会尝试 D-Bus 激活）"; }
  sleep 1
  bus_has_owner org.kde.kwalletd6 && ok "kwalletd6 现在已经在跑了" \
    || warn "kwalletd6 仍未激活 —— KDE 侧可能弹不出窗，看下一节的报错"
fi

# ===========================================================================
say "4/6. GNOME Keyring 的密码 UI"
# ===========================================================================
warn "看着屏幕：应当出现【GTK 风格】对话框（/usr/lib/gcr-prompter 提供），"
step "文案类似 'Enter password to unlock your login keyring' /「输入密码以解锁登录密钥环」。"
step ""

GKR_COLL=""
if bus_has_owner org.freedesktop.secrets; then
  run_capture 20 busctl --user call org.freedesktop.secrets /org/freedesktop/secrets \
    org.freedesktop.Secret.Service ReadAlias s default
  show_out
  GKR_COLL="$(qpaths "$OUT" | grep '/collection/' | head -1)"
  [ -n "$GKR_COLL" ] && step "默认 collection = $GKR_COLL" \
                     || warn "没有默认 collection（还没有 login 密钥环）"
fi

if ! bus_has_owner org.freedesktop.secrets; then
  bad "gnome-keyring 仍未运行，GNOME 侧无法测试。先修好第 3 节再重跑。"
elif [ "$FORCE_NEW" -eq 1 ] || [ -z "$GKR_COLL" ]; then
  [ "$FORCE_NEW" -eq 0 ] && step "→ 走「新建测试密钥环」路径（没有现成密钥环可解锁）"
  step "CreateCollection 建一个 DSH-UI-Test，再对返回的 prompt 对象调 Prompt —— 这会弹出"
  step "gnome-keyring 的「新建密钥环」密码对话框。"
  run_capture 25 busctl --user call org.freedesktop.secrets /org/freedesktop/secrets \
    org.freedesktop.Secret.Service CreateCollection "a{sv}s" 1 \
    "org.freedesktop.Secret.Collection.Label" s "DSH-UI-Test" ""
  show_out
  if [ $RC -ne 0 ]; then
    bad "CreateCollection 调用失败：$(printf '%s' "$OUT" | head -1)"
  else
    P_COLL="$(qpaths "$OUT" | sed -n 1p)"
    P_PROMPT="$(qpaths "$OUT" | sed -n 2p)"
    step "collection=$P_COLL  prompt=$P_PROMPT"
    if [ -n "$P_PROMPT" ] && [ "$P_PROMPT" != "/" ]; then
      step "对 prompt 对象调 Prompt(\"\") —— 此时看屏幕（最多等 120 秒）"
      run_capture 120 busctl --user call org.freedesktop.secrets "$P_PROMPT" \
        org.freedesktop.Secret.Prompt Prompt s ""
      show_out
      if [ $RC -eq 0 ]; then verdict_ui || true
      else
        bad "Prompt 调用失败：$(printf '%s' "$OUT" | head -1)"
        case "$OUT" in
          *"Access denied"*) sub "（Access denied 通常表示 gnome-keyring 没能在当前环境弹出窗口）" ;;
        esac
        sub "改用 GUI 一定可行：见第 6 节（seahorse）"
      fi
    else
      warn "没有返回 prompt 对象 —— 说明密钥环是不带密码直接建好的（那就没有密码 UI 可言）"
    fi
  fi
else
  step "① secret-tool 自带的 lock 子命令锁上默认 collection"
  run_capture 30 secret-tool lock
  show_out
  run_capture 20 busctl --user get-property org.freedesktop.secrets "$GKR_COLL" \
    org.freedesktop.Secret.Collection Locked
  case "$OUT" in
    *true*)  ok "已确认 Locked=true → 下一次访问必定弹窗" ;;
    *false*) warn "仍报告 Locked=false → 该密钥环【没有密码】，锁不住、也不会弹窗（这本身就是结论）" ;;
    *)       warn "读不到 Locked 属性：$OUT" ;;
  esac
  step "② 触发访问：写入一条测试密钥（此时看屏幕）"
  run_capture 120 bash -c "printf 'dsh-ui-probe' | secret-tool store --label='DSH keyring UI test' dsh-ui-probe backend"
  show_out
  if [ $RC -eq 0 ]; then
    if ! verdict_ui; then
      step ""
      step "→ 没有弹窗 = 该密钥环没有密码。没有密码 ⇒ 永远不会有密码 UI，也就谈不上打扰。"
      step "  想亲眼看 gnome-keyring 的密码对话框：重跑并加 --force-new"
    fi
  else
    case "$OUT" in
      *"does not exist"*)
        warn "默认密钥环对象不存在 → 请用 --force-new（会新建一个来强制弹窗）" ;;
      *)
        bad "rc=$RC —— 被取消/失败也是有效观察：记下你看到的对话框"
        [ -n "$OUT" ] && sub "$(printf '%s' "$OUT" | head -3)" ;;
    esac
    [ "$RC" -eq 124 ] && warn "超时：可能对话框弹出来了但一直没人操作"
  fi
  step ""
  step "清理刚才写入的测试条目"
  secret-tool clear dsh-ui-probe backend >/dev/null 2>&1 && ok "已清理" || sub "（无条目可清）"
fi

[ "$INTERACTIVE" -eq 1 ] && { printf '\n%s看完 GNOME Keyring 的 UI 后按回车，继续 KDE Wallet…%s' "$BOLD" "$OFF"; read -r _; }

# ===========================================================================
say "5/6. KDE Wallet (kwalletd6) 的密码 UI"
# ===========================================================================
warn "看着屏幕：应当出现【Qt 风格】对话框，标题类似 'KDE Wallet Service'。"
step "文案类似 'Please enter the password for the wallet kdewallet' /「请输入钱包 kdewallet 的密码」。"
step ""

KW_WALLET="kdewallet"; KW_FOUND=0
run_capture 30 busctl --user call org.kde.kwalletd6 /modules/kwalletd6 org.kde.KWallet wallets
show_out
if printf '%s' "$OUT" | grep -qiE 'failed|error|not found|no owner|unknown'; then
  warn "读不到钱包列表：$(printf '%s' "$OUT" | head -1)"
else
  KWS="$(printf '%s\n' "$OUT" | grep -oE '"[^"]+"' | tr -d '"')"
  if [ -n "$KWS" ]; then
    step "kwalletd6 报告的钱包："
    printf '%s\n' "$KWS" | sed 's/^/     /'
    KW_WALLET="$(printf '%s\n' "$KWS" | head -1)"; KW_FOUND=1
  else
    warn "钱包列表为空（还没有任何钱包）"
  fi
fi

if ! command -v kwallet-query >/dev/null; then
  bad "kwallet-query 不存在，KDE 侧只能靠第 6 节的 GUI"
elif [ "$FORCE_NEW" -eq 1 ] || [ "$KW_FOUND" -eq 0 ]; then
  [ "$FORCE_NEW" -eq 0 ] && step "→ 走「新建测试钱包」路径（没有现成钱包可解锁）"
  step "打开一个【不存在的】钱包 DSH-UI-Test —— kwalletd6 会要求为它设定密码，从而弹窗"
  run_capture 120 kwallet-query -l DSH-UI-Test
  show_out
  if [ $RC -eq 0 ]; then verdict_ui || true
  else
    bad "rc=$RC —— 原始输出：$(printf '%s' "$OUT" | head -2)"
    sub "这个路径依赖 kwalletd6 对「不存在的钱包」的处理，不保证弹窗；"
    sub "最稳的是第 6 节的 kwalletmanager5（已安装）。"
  fi
else
  step "① 先关掉所有已打开的钱包（busctl 严格类型）"
  run_capture 30 busctl --user call org.kde.kwalletd6 /modules/kwalletd6 org.kde.KWallet closeAllWallets
  show_out
  sleep 1
  step "② 触发打开钱包 $KW_WALLET（此时看屏幕）"
  run_capture 120 kwallet-query -l "$KW_WALLET"
  show_out
  if [ $RC -eq 0 ]; then
    if ! verdict_ui; then
      step ""
      step "→ 没有弹窗 = 该钱包没有密码，或本来就开着。零打扰，但密钥只靠文件权限保护。"
    fi
  else
    bad "rc=$RC —— 原始输出：$(printf '%s' "$OUT" | head -2)"
    [ "$RC" -eq 124 ] && warn "超时：可能对话框弹出来了但一直没人操作"
    bus_has_owner org.kde.kwalletd6 || sub "（kwalletd6 不在总线上：先 systemctl --user start kwalletd6.service）"
  fi
fi

# ---------------------------------------------------------------------------
say "6/6. 最可靠的一招：GUI 界面（点开钱包/密钥环就一定弹密码框）"
# ---------------------------------------------------------------------------
if command -v kwalletmanager5 >/dev/null; then
  ok "kwalletmanager5 已安装 —— KWallet 的图形管理器，一定有密码对话框"
  sub "跑： kwalletmanager5 &     ← 左侧点任意钱包；或 File → New Wallet 新建一个"
  sub "（包 kwalletmanager 26.08 依赖 kwallet=KF6，所以它连的就是 kwalletd6）"
else
  step "kwalletmanager5 未安装；想装： sudo pacman -S kwalletmanager"
fi
if command -v seahorse >/dev/null; then
  ok "seahorse 已安装（GNOME「密码和钥匙」）—— 一定有解锁/新建密钥环对话框"
  sub "跑： seahorse &"
else
  step "seahorse 未安装（GNOME Keyring 的图形前端）"
  sub "想装（推荐，这是唯一保证能看到 gnome-keyring 密码框的办法）："
  sub "  sudo pacman -S seahorse     然后跑： seahorse &  → 左侧「登录」钥匙环，双击就会弹解锁框"
fi

# ---------------------------------------------------------------------------
say "怎么据此做决定"
# ---------------------------------------------------------------------------
cat <<'EOF'
   1) 【第 1 节】哪个目录里有真实数据、时间更新 → 那才是你实际在用的后端。
      换掉它意味着要迁移或丢失已有密钥。这是最重要的一条。
   2) 【第 4/5 节 + 第 6 节】哪个弹窗了、哪个没弹：
        没弹 = 该密钥环/钱包没有密码 = 日常零打扰（代价是密钥只靠文件权限保护）
        弹了 = 每次登录/首次访问都要输一次密码
   3) 【第 2 节】当前总线归属：
        org.freedesktop.secrets            -> gnome-keyring
        org.freedesktop.impl.portal.Secret -> gnome-keyring
      两个名字都在 gnome-keyring 手里；KWallet 只有在走 KDE portal
      （org.freedesktop.impl.portal.desktop.kwallet -> ksecretd）时才被用到。
      ⚠ 「改用 KWallet」必须同时让 ksecretd 在跑 + portal 解析到 KDE，
        否则会出现 libsecret 存到 A、portal 存到 B，两个库互不可见。
EOF

# ---------------------------------------------------------------------------
say "清理 / 复原"
# ---------------------------------------------------------------------------
step "真实密钥环/钱包的数据没有被本脚本改写；被关掉的钱包会在下次访问时自动重开。"
KR_LEFT=0
if bus_has_owner org.freedesktop.secrets; then
  COLLS="$(busctl --user get-property org.freedesktop.secrets /org/freedesktop/secrets \
             org.freedesktop.Secret.Service Collections 2>/dev/null | grep -oE '"/[^"]+"' | tr -d '"')"
  for c in $COLLS; do
    LBL="$(busctl --user get-property org.freedesktop.secrets "$c" \
             org.freedesktop.Secret.Collection Label 2>/dev/null | sed -e 's/^s //' -e 's/"//g')"
    [ "$LBL" = "DSH-UI-Test" ] && { KR_LEFT=1; step "发现测试密钥环：$c (Label=$LBL)"; }
  done
fi
KW_LEFT=0
for f in "$HOME/.local/share/kwalletd/DSH-UI-Test.kwl" "$HOME/.local/share/kwallet/DSH-UI-Test.kwl"; do
  [ -e "$f" ] && { KW_LEFT=1; step "发现测试钱包：$f"; }
done

if [ "$KR_LEFT" -eq 0 ] && [ "$KW_LEFT" -eq 0 ]; then
  ok "没有残留的测试密钥环/钱包。"
elif [ "$INTERACTIVE" -eq 0 ]; then
  step "（--no-prompt）未删除。手动清理："
  sub "GNOME： 对上面那个 collection 调 org.freedesktop.Secret.Collection.Delete，或 seahorse 里删"
  sub "KDE  ： rm -f ~/.local/share/{kwalletd,kwallet}/DSH-UI-Test.kwl 然后 systemctl --user restart kwalletd6.service"
else
  printf '%s要删除上面这些测试对象吗？[y/N] %s' "$BOLD" "$OFF"; read -r ans
  case "$ans" in
    [yY]*)
      for c in $COLLS; do
        LBL="$(busctl --user get-property org.freedesktop.secrets "$c" \
                 org.freedesktop.Secret.Collection Label 2>/dev/null | sed -e 's/^s //' -e 's/"//g')"
        if [ "$LBL" = "DSH-UI-Test" ]; then
          run_capture 30 busctl --user call org.freedesktop.secrets "$c" \
            org.freedesktop.Secret.Collection Delete
          step "Delete $c → $(printf '%s' "$OUT" | head -1)"
          DP="$(qpaths "$OUT" | head -1)"
          [ -n "$DP" ] && [ "$DP" != "/" ] && \
            busctl --user call org.freedesktop.secrets "$DP" org.freedesktop.Secret.Prompt Prompt s "" >/dev/null 2>&1
        fi
      done
      rm -fv "$HOME/.local/share/kwalletd/DSH-UI-Test.kwl" "$HOME/.local/share/kwallet/DSH-UI-Test.kwl"
      ok "清理完成。"
      ;;
    *) step "已保留。手动清理见 --no-prompt 的提示。" ;;
  esac
fi

say "决定之后告诉我，我来改 systemd/ 里的 unit 与 enable 链"
