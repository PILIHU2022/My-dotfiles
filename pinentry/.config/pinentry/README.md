# pinentry 名称显示（stow 包 `pinentry`）

把 gpg-agent 密码弹窗里的机器标识换成手写文本，并支持按场景（SSH / OpenPGP）取不同文本。

## 组件链路（本机实测）

```
gpg / ssh
  └─ gpg-agent
       └─ pinentry-program 指向 /usr/bin/pinentry（Arch 包装脚本，按桌面自动选后端）
            └─ pinentry-gnome3
                 └─ D-Bus org.gnome.keyring.SystemPrompter
                      └─ /usr/lib/gcr-prompter   ← 真正画窗口的进程（窗口类名 gcr-prompter）
```

gpg-agent 只通过 Assuan 协议发机器标识，GnuPG 没有“显示密钥名”的原生开关
（`ssh-fingerprint-digest` 只能选 md5/sha1/sha256），所以在中间加一层过滤器。

## 密钥是统一的

SSH 与 OpenPGP 共用同一把 GPG 密钥，不需要单独的 SSH 密钥：

```
Spark <Spark-CN@outlook.com>（主钥 623B7C89A9BE9F48）
  ├─ e 子钥 48F45046DDB7B033   → 加密
  ├─ s 子钥 420D855B9B82BD3B   → 签名
  └─ a 子钥 F25B6CB0CF3F272C   → 认证（就是 SSH 用的那把）
        keygrip 64D949A70A5C4C616608202C9DDE44A4F5F5758F
        SSH 指纹 SHA256:gAOVsakm7Zl63ScocGkE5QlVA8QUATC0onlaYruUot4
```

因此同一个密钥可以在两张表里按场景给出不同文本。

## 文件

| 仓库内 | stow 后位置 | 说明 |
| --- | --- | --- |
| `pinentry/.local/bin/pinentry-named` | `~/.local/bin/pinentry-named` | Assuan 过滤器，改写 `SETDESC` |
| `pinentry/.config/pinentry/names.conf` | `~/.config/pinentry/names.conf` | 密钥标识 → 显示名称（可加 `ssh:` / `gpg:` 前缀） |
| `pinentry/.config/pinentry/text.conf` | `~/.config/pinentry/text.conf` | 首行说明的字面文字修正（如 `ssh` → `SSH`） |

## 安装

```sh
cd ~/Projects/Stow-Dotfile && stow -v -t ~ pinentry
gpgconf --reload gpg-agent        # 让 gpg-agent 重新读取 pinentry-program
```

并在 `~/.gnupg/gpg-agent.conf` **末尾**加一行（放在 GPGConf 标记块之后，Kleopatra
重写该文件时不会动它）：

```
pinentry-program /home/Spark/.local/bin/pinentry-named
```

## 配置

`names.conf` 每行 `<匹配键> <显示名称>`，匹配键支持带场景前缀：

| 写法 | 生效范围 |
| --- | --- |
| `ssh:<匹配键>` | 只作用于 SSH 弹窗 |
| `gpg:<匹配键>` | 只作用于 OpenPGP 弹窗 |
| `<匹配键>` | 两种场景都生效（兜底） |

`<匹配键>` 可用 16 位密钥 ID、40 位 keygrip 或 `SHA256:` 指纹（十六进制大小写不敏感）。
`text.conf` 每行 `<原文> <替换文本>`，只对弹窗首行说明做字面替换，不动密钥名称。

两张表都在每次弹窗前重新读取，**改完立即生效**，不需要重启 gpg-agent。

## 使用

```sh
pinentry-named --list      # 列出可写进 names.conf 的匹配键（密钥 ID / keygrip / SSH 指纹）
pinentry-named --rewrite   # 喂 Assuan 流做离线自检，不弹窗
```

## 效果（本机实测）

截图不入库（`screenshots/` 已移除），差异记录如下。

**SSH 弹窗**

- 改前：首行是小写的 `请输入 ssh 密钥`，第二行直接摊开 `SHA256:gAOVsakm7Zl63ScocGkE5QlVA8QUATC0onlaYruUot4` 指纹，太长折成两行，末尾缀「的密码」。
- 改后：首行变成大写的 `请输入 SSH 密钥`（`text.conf` 的字面替换），第二行换成 `Spark-CN · SSH 认证子钥 的密码`，指纹不再出现，单行可读。

**OpenPGP 弹窗**

- 改前：首行 `请输入密码以解锁 OpenPGP 私钥：`，其下依次是 `"Spark@And <Spark@Android>"`、`255 位 EDDSA 密钥，标识 B5BB2FA791A9AC00`、`创建于 2026-05-30。` 三行机器信息。
- 改后：只剩两行——首行说明 + `Spark@And <Spark@Android>`；算法、密钥 ID 和创建时间整块被替换掉。

## 已知限制

- `--list` 里的 SSH 指纹来自 `ssh-add -L`，与弹窗中的 `ssh-fingerprint-digest`（默认
  sha256）一致；若改用 md5，匹配键要写成 `MD5:…`。用 keygrip 做匹配键则与摘要算法无关。
- OpenPGP 场景目前会把“`%22UID%22` + 算法/密钥 ID + 创建时间”整块换成你写的名称；
  没写进 `names.conf` 的密钥保持原样（首行说明的文字修正仍会应用）。
