#!/usr/bin/env bash
# =============================================================================
# patch-dsh-fs-local.sh
#
# 修复 DSH 写文件时丢失属组 / 组可读的问题（典型产物 dsh:dsh 600）。
#
# 背景（实测）：@deepseek-ai/dsh-fs-local 的 writeFileAtomic() 采用
#   「同目录建 staging 目录 → 写临时文件 → rename 就位」。
#   它在建好 staging 目录后又执行 chmod(stagingDir, 0o700)。chmod 会重写整个模式位，
#   而执行写入的进程未必属于目标目录的属组（DSH 服务进程不在 agent 组），此时内核会
#   强制清除目录从父目录继承来的 S_ISGID。于是随后创建的临时文件只能拿到进程 egid
#   （dsh），rename 之后就成了 dsh:dsh；新文件又被硬编码 0600，组里其他人连读都不行。
#
# 补丁做两件事：
#   1) 去掉那次 chmod —— mkdir({mode:0o700}) 已由 umask 保证不宽于 0700；
#      保留 setgid 后临时文件即可继承目标目录的属组。
#   2) 目标目录带 setgid（＝共享目录约定）时，临时文件按 0o660 创建且不再压回 0600，
#      让目录的默认 ACL / umask 决定最终权限（/home/Projects 下会得到 660）。
#      非 setgid 目录维持原来的 0600 私有默认，不改变既有安全语义。
#
# 用法：
#   sudo bash Docs/patch-dsh-fs-local.sh            # 打补丁
#   sudo bash Docs/patch-dsh-fs-local.sh --check    # 只看状态
#   sudo bash Docs/patch-dsh-fs-local.sh --revert   # 从最新备份回滚
#
# 注意：改的是 /usr/lib/node_modules 下的文件，DSH 升级/重装后会被覆盖，需要重打。
# =============================================================================
set -euo pipefail

TARGET="${TARGET:-/usr/lib/node_modules/@deepseek-ai/dsh/node_modules/@deepseek-ai/dsh-fs-local/lib/index.js}"
MARKER="dsh-shared-workspace-patch begin"

log()  { printf '\033[32m✓\033[0m %s\n' "$*"; }
warn() { printf '\033[33m!\033[0m %s\n' "$*"; }
die()  { printf '\033[31m✗\033[0m %s\n' "$*" >&2; exit 1; }

[[ -f $TARGET ]] || die "找不到目标文件：$TARGET"
command -v node >/dev/null || die "需要 node 来安全地做替换与语法校验"

newest_backup() { ls -1t "$TARGET".orig-* 2>/dev/null | head -1 || true; }

# ---------------------------------------------------------------------------
# --revert / --check
# ---------------------------------------------------------------------------
case "${1:-}" in
  --revert)
    bak=$(newest_backup)
    [[ -n $bak ]] || die "没有找到备份（$TARGET.orig-*），无法回滚"
    [[ -w $TARGET ]] || die "没有写权限，请用 sudo 运行"
    cp -a "$bak" "$TARGET"
    log "已回滚到 $bak"
    node --check "$TARGET" && log "语法校验通过"
    exit 0
    ;;
  --check)
    if grep -qF "$MARKER" "$TARGET"; then
      log "已打补丁：$TARGET"
    else
      warn "尚未打补丁：$TARGET"
    fi
    exit 0
    ;;
  "") ;;
  *) die "未知参数：$1" ;;
esac

[[ -w $TARGET ]] || die "没有写权限（该文件属于 root）：请用 sudo 运行本脚本"
if grep -qF "$MARKER" "$TARGET"; then
  log "已经打过补丁，无需重复操作：$TARGET"
  exit 0
fi

# ---------------------------------------------------------------------------
# 备份
# ---------------------------------------------------------------------------
BAK="$TARGET.orig-$(date +%Y%m%d-%H%M%S)"
cp -a "$TARGET" "$BAK"
log "已备份到 $BAK"

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

cat > "$WORK/patch.mjs" <<'JSEOF'
import { readFileSync, writeFileSync } from "node:fs";

const file = process.argv[2];
const src = readFileSync(file, "utf8");

const before = [
  "\t\tawait chmod(stagingDir, 448);",
  "\t\thandle = await open(tempPath, \"wx\", 384);",
  "\t\tawait handle.chmod(384);",
  ""
].join("\n");

const after = [
  "\t\t// ---- dsh-shared-workspace-patch begin ----",
  "\t\t// 不再 chmod stagingDir：chmod 会重写全部模式位，而执行写入的进程未必属于目标",
  "\t\t// 目录的属组（DSH 服务进程不在 agent 组），内核会因此清除继承来的 S_ISGID，",
  "\t\t// 临时文件随即丢失目录属组（落成 dsh:dsh）。mkdir 的 0o700 已由 umask 保证 ≤ 0700。",
  "\t\t// 目标目录带 setgid（共享目录约定）时按 0o660 建临时文件且不再压回 0600，",
  "\t\t// 让目录默认 ACL / umask 决定最终权限；非 setgid 目录维持原有 0600 私有语义。",
  "\t\tconst sharedDir = (((await stat(directory)).mode) & 0o2000) !== 0;",
  "\t\tconst tempMode = sharedDir ? 0o660 : 0o600;",
  "\t\thandle = await open(tempPath, \"wx\", tempMode);",
  "\t\tif (!sharedDir) await handle.chmod(0o600);",
  "\t\t// ---- dsh-shared-workspace-patch end ----",
  ""
].join("\n");

const hits = src.split(before).length - 1;
if (hits !== 1) {
  console.error(`预期匹配 1 处，实际 ${hits} 处；文件版本可能与补丁不匹配，已放弃。`);
  process.exit(2);
}
writeFileSync(file, src.replace(before, after));
console.log("替换完成");
JSEOF

# ---------------------------------------------------------------------------
# 打补丁 → 校验 → 失败自动回滚
# ---------------------------------------------------------------------------
if ! node "$WORK/patch.mjs" "$TARGET"; then
  warn "替换失败，文件未改动（备份保留在 $BAK）"
  exit 2
fi

if node --check "$TARGET"; then
  log "语法校验通过"
else
  cp -a "$BAK" "$TARGET"
  die "语法校验失败，已自动回滚到 $BAK"
fi

echo
echo "=== 实际改动 ==="
diff -u "$BAK" "$TARGET" | sed -n '1,40p' || true
echo
log "补丁完成。请重启 dsh web 使改动生效："
echo "   systemctl --user restart dsh-web   # 或按你平时的启动方式重启"
echo "   重启后验证：新建一个文件，属组应为 agent 而不是 dsh"
