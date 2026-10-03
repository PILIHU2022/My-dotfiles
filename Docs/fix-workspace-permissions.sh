#!/usr/bin/env bash
# =============================================================================
# fix-workspace-permissions.sh
#
# 用途：把 /home/Projects 变成 Spark 与 dsh 两个用户都能安全读写的共享工作区。
#
# 运行：sudo bash Docs/fix-workspace-permissions.sh
#
# 特点：
#   * 幂等——可以反复执行，结果一致。
#   * 默认【不改文件属主】，只统一「属组 + 组权限 + setgid + ACL」。
#   * 递归操作不跟随符号链接，工作区之外的目标不会被误改。
#
# 可用环境变量覆盖：
#   WORKSPACE=/home/Projects      工作区根目录
#   SHARED_GROUP=agent            共享组
#   OWNER=Spark                   目录属主（改成 dsh 会连带需要重设 safe.directory）
#   OTHER_PERMS=rx                其他用户权限：rx=可读可进入，---=完全隔离
#   NO_ROOT=1                     属主模式：不要求 root、不改属主、跳过 safe.directory
#                                 （适用于"整棵树都属于你自己"的场景，例如 Spark 修自己的文件）
# =============================================================================
set -euo pipefail

WORKSPACE="${WORKSPACE:-/home/Projects}"
SHARED_GROUP="${SHARED_GROUP:-agent}"
OWNER="${OWNER:-Spark}"
OTHER_PERMS="${OTHER_PERMS:-rx}"
MEMBER_USERS=(Spark dsh)   # 需要共享这两个用户
NO_ROOT="${NO_ROOT:-}"     # 非空 = 以属主身份运行（不 chown、不写 safe.directory、不要求 root）

log()  { printf '\033[32m✓\033[0m %s\n' "$*"; }
warn() { printf '\033[33m!\033[0m %s\n' "$*"; }
die()  { printf '\033[31m✗\033[0m %s\n' "$*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# 0. 前置检查：把"权限改错"变成"启动前就报错"
# ---------------------------------------------------------------------------
if [[ -n $NO_ROOT ]]; then
  # 以属主身份运行：Spark 登录时修自己拥有的文件，根本不需要 sudo。
  # 属主模式下每个操作都加 -user 过滤：只动自己拥有的对象，别人的留给别人（或 sudo）。
  ME=$(id -un)
  [[ $OWNER == "$ME" ]] || die "NO_ROOT 模式要求 OWNER=$ME（当前 OWNER=$OWNER）"
  OWN_FILTER=(-user "$ME")
  foreign=$(find "$WORKSPACE" ! -user "$ME" -print -quit 2>/dev/null || true)
  if [[ -n $foreign ]]; then
    warn "$WORKSPACE 里存在不属于 $ME 的对象，本次将【跳过】它们，例如："
    printf '    %s\n' "$foreign"
    warn "要连它们一起修：用 sudo 运行，或以拥有它们的那个用户身份再跑一次本脚本"
  fi
else
  OWN_FILTER=()
  [[ ${EUID} -eq 0 ]] || die "需要 root 权限：sudo bash $0
      若只想修你自己拥有的对象，可以免 root：NO_ROOT=1 bash $0"
fi
getent group "$SHARED_GROUP" >/dev/null || die "共享组 $SHARED_GROUP 不存在"
id "$OWNER" >/dev/null 2>&1 || die "属主用户 $OWNER 不存在"
for u in "${MEMBER_USERS[@]}"; do
  id "$u" >/dev/null 2>&1 || die "用户 $u 不存在"
  id -nG "$u" | tr ' ' '\n' | grep -qx "$SHARED_GROUP" \
    || die "用户 $u 不在 $SHARED_GROUP 组里：sudo usermod -aG $SHARED_GROUP $u"
done
[[ -d $WORKSPACE ]] || die "目录 $WORKSPACE 不存在"
command -v setfacl >/dev/null || die "缺少 setfacl，请先安装 acl 包"

# "其他用户"这一档：目录需要 x 才能被进入，普通文件不需要 x。
# 这里显式区分，而不是用 X 条件位——显式更可预测，也不会受 ACL 状态影响。
case "$OTHER_PERMS" in
  rx|r-x) OTHER_DIR="r-x"; OTHER_FILE="r--" ;;
  ---|-)  OTHER_DIR="---"; OTHER_FILE="---" ;;
  *)      OTHER_DIR="$OTHER_PERMS"; OTHER_FILE="$OTHER_PERMS" ;;
esac

echo "== 0. 参数 =="
printf '   WORKSPACE    = %s\n' "$WORKSPACE"
printf '   OWNER        = %s\n' "$OWNER"
printf '   SHARED_GROUP = %s\n' "$SHARED_GROUP"
printf '   OTHER_PERMS  = %s   (目录 o::%s / 普通文件 o::%s)\n' \
       "$OTHER_PERMS" "$OTHER_DIR" "$OTHER_FILE"
printf '   模式         = %s\n' "$([[ -n $NO_ROOT ]] && echo '属主模式（免 root，不改属主）' || echo 'root 模式（会统一属主/属组）')"
echo

# ---------------------------------------------------------------------------
# 1. 顶层目录：属主/属组 + setgid + 访问 ACL + 默认 ACL
# ---------------------------------------------------------------------------
echo "== 1. 顶层目录 =="
if [[ -O $WORKSPACE ]]; then
  [[ -n $NO_ROOT ]] || chown "$OWNER:$SHARED_GROUP" "$WORKSPACE"
  chmod 2775 "$WORKSPACE"                                # 2 = setgid
  setfacl -m  "u::rwx,g::rwx,g:${SHARED_GROUP}:rwx,m::rwx,o::${OTHER_DIR}" "$WORKSPACE"
  setfacl -d -m "u::rwx,g::rwx,g:${SHARED_GROUP}:rwx,m::rwx,o::${OTHER_DIR}" "$WORKSPACE"
  log "顶层目录：2775 + ACL + 默认 ACL"
else
  warn "跳过顶层目录（$WORKSPACE 不属于 $ME）"
fi

# ---------------------------------------------------------------------------
# 2. 递归统一属组
# ---------------------------------------------------------------------------
echo "== 2. 递归统一属组 =="
find "$WORKSPACE" "${OWN_FILTER[@]}" \( -type f -o -type d \) \
  -exec chgrp "$SHARED_GROUP" {} +
log "属组统一为 $SHARED_GROUP"

# ---------------------------------------------------------------------------
# 3. 递归给「组」补读写
#    目录用 g+rwx（必须能进入），文件用 g+rw（不碰执行位：
#    原本可执行的脚本保持可执行，原本不可执行的不会被加上 x）
# ---------------------------------------------------------------------------
echo "== 3. 递归补齐组权限 =="
find "$WORKSPACE" "${OWN_FILTER[@]}" -type d -exec chmod g+rwx {} +
find "$WORKSPACE" "${OWN_FILTER[@]}" -type f -exec chmod g+rw {} +
log "组权限补齐（目录 g+rwx，文件 g+rw）"

# ---------------------------------------------------------------------------
# 4. 所有目录加 setgid：新建内容自动继承共享组
# ---------------------------------------------------------------------------
echo "== 4. 目录 setgid =="
find "$WORKSPACE" "${OWN_FILTER[@]}" -type d -exec chmod g+s {} +
log "setgid 设置完成"

# ---------------------------------------------------------------------------
# 5. 已有对象补 ACL（显式授权共享组）
#    用 find 而不是 setfacl -R，确保不跟随符号链接。
#    目录 → rwx；可执行文件 → rwx；普通文件 → rw（保持"不可执行"）。
#    两个容易踩的点：
#      a) 必须连同 group:: 与 mask:: 一起显式给出：文件从目录默认 ACL 继承来的
#         group::rwx 会让 setfacl 重算出的 mask 变成 rwx，普通文件会凭空多出
#         "组可执行"位（-rw-rwx---）。显式写全就不会。
#      b) 判断"可执行"必须用 owner 的 x 位（-perm -u+x），不能用 -perm /111：
#         后者的口径是文件模式里的组位，而在带 ACL 的文件上组位就是 mask，
#         一旦 mask 被抬成 rwx，"普通文件"会被误判成"可执行文件"从而永远修不回来。
# ---------------------------------------------------------------------------
echo "== 5. 已有对象的 ACL（共享组 + 其他用户）=="
find "$WORKSPACE" "${OWN_FILTER[@]}" -type d \
  -exec setfacl -m "g::rwx,g:${SHARED_GROUP}:rwx,m::rwx,o::${OTHER_DIR}" {} +
find "$WORKSPACE" "${OWN_FILTER[@]}" -type f -perm -u+x \
  -exec setfacl -m "g::rwx,g:${SHARED_GROUP}:rwx,m::rwx,o::${OTHER_DIR}" {} +
find "$WORKSPACE" "${OWN_FILTER[@]}" -type f ! -perm -u+x \
  -exec setfacl -m "g::rw-,g:${SHARED_GROUP}:rw-,m::rw-,o::${OTHER_FILE}" {} +
log "已有对象的 ACL 设置完成"

# ---------------------------------------------------------------------------
# 6. 所有目录设置默认 ACL：新建文件/目录天然带组写权限，不受 umask 影响
#    （新建文件的请求模式里没有 x 位，所以 o::r-x 只会作用于目录）
# ---------------------------------------------------------------------------
echo "== 6. 目录默认 ACL =="
find "$WORKSPACE" "${OWN_FILTER[@]}" -type d -exec setfacl \
  -m "d:u::rwx,d:g::rwx,d:g:${SHARED_GROUP}:rwx,d:m::rwx,d:o::${OTHER_DIR}" {} +
log "默认 ACL 设置完成"

# ---------------------------------------------------------------------------
# 7. 让每个成员用户都信任工作区里的 git 仓库
#    以目标用户身份执行，避免 root 写坏用户的 ~/.gitconfig 属主。
#    用 env -i 清空环境：外部的 GIT_DIR / GIT_CONFIG_GLOBAL / GIT_CONFIG_COUNT
#    等变量会让 git 去读写完全不相干的路径（实测报
#    "fatal: error reading '<某处>'"），必须隔离。
#    这一步失败不影响前面的权限修复，所以只告警、不中止。
#    属主模式下跳过（runuser 需要 root，且这一步与文件权限无关）。
# ---------------------------------------------------------------------------
echo "== 7. git safe.directory =="
step7_failed=0
if [[ -n $NO_ROOT ]]; then
  warn "属主模式：跳过 safe.directory 同步（需要 root 才能切换用户）"
  echo "   如需要，用 root 再跑一次：sudo bash $0"
else
git_as() {  # $1=用户 $2=家目录，其余参数交给 git
  local u=$1 home=$2; shift 2
  runuser -u "$u" -- /usr/bin/env -i HOME="$home" PATH=/usr/bin:/bin git "$@"
}
while IFS= read -r repo; do
  [[ -n $repo ]] || continue
  for u in "${MEMBER_USERS[@]}"; do
    home=$(getent passwd "$u" | cut -d: -f6)
    if git_as "$u" "$home" config --global --get-all safe.directory 2>/dev/null \
         | grep -qxF "$repo"; then
      log "$u 已信任 $repo"
      continue
    fi
    if err=$(git_as "$u" "$home" config --global --add safe.directory "$repo" 2>&1); then
      log "$u 新增 safe.directory: $repo"
    else
      step7_failed=1
      warn "$u 写入 safe.directory 失败：$repo"
      [[ -n $err ]] && printf '    %s\n' "$err"
    fi
  done
done < <(find "$WORKSPACE" -type d -name .git -prune -printf '%h\n' | sort -u)
fi
if (( step7_failed )); then
  warn "第 7 步有失败项（权限修复本身已经完成）。手动补法："
  echo "   sudo -u <用户> env -i HOME=<家目录> PATH=/usr/bin:/bin \\"
  echo "        git config --global --add safe.directory <仓库路径>"
fi

echo
log "全部完成。用下面的命令复核："
echo "   ls -ld  $WORKSPACE"
echo "   getfacl $WORKSPACE"
echo "   find $WORKSPACE -type d ! -perm -g+w          # 期望为空"
echo "   find $WORKSPACE ! -group $SHARED_GROUP        # 期望为空"
echo "   touch $WORKSPACE/.probe && rm -f $WORKSPACE/.probe   # 以另一个成员用户各试一次"
if [[ -z $NO_ROOT ]]; then
  echo "   sudo -u dsh   touch $WORKSPACE/.probe && rm -f $WORKSPACE/.probe"
  echo "   sudo -u Spark touch $WORKSPACE/.probe && rm -f $WORKSPACE/.probe"
fi
