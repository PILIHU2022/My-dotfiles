# systemd user unit 审查 + 启动模块化

> 主机：`SparkPC` ｜ 仓库：`/home/Projects/Stow-Dotfile` ｜ 包：`systemd`
> 审查范围：`systemd/.config/systemd/user/` 下全部 unit + `.wants/` 启用链 + `hypr/.config/hypr/hyprland.lua` 里残留的命令式启动
> 校验方式：`systemd-analyze --user verify`（第二轮后 16 个文件全部 `rc=0`：7 个 service + 1 个 target + 8 条启用链），并用 folded / unfolded 两种 stow 布局模拟验证软链可解析；`hyprland.lua` 用 `luac -p` 做过语法检查
>
> **第二轮更新**（见 §9）：kitty 已退出 systemd、改为 `hyprland.lua` 自动启动；dunst 定为卸载；新增 [compare-secrets-backends.sh](compare-secrets-backends.sh) 供你对比两个密钥后端的 UI。
> **第三轮更新**：第一版密钥对比脚本弹不出窗，已定位并修掉脚本自身的 4 个 bug（§9.3.1），并补上「GUI 一定可行」的路子（§9.3.3）。
> **第四轮更新**：按你的决定改用 **KWallet 6**——删掉 `gnome-keyring.service`，新增 `ksecretd.service`（KWallet 6 真正的 `org.freedesktop.secrets` 实现）+ portal 覆盖，并新增 [`sync-systemd-units.sh`](sync-systemd-units.sh) 把单元覆盖到 `~/.config/systemd/`。见 §9.4。

---

## 0. 结论速览

| 问题 | 答案 |
| --- | --- |
| **你的通知软件是哪一个？** | **mako**。它持有 D-Bus 名 `org.freedesktop.Notifications`，`mako.service` 是仓库里唯一被 enable 的通知 unit。`dunst` 虽然装了、仓库里也留着配置，但**没有任何 unit、没有任何地方启动它**（已决定卸载）。 |
| 通知软件是否已独立？ | 是。`mako.service` 现在是唯一的通知 unit，自带 `Conflicts=dunst.service`，`stop`/`start`/`restart` 只影响自己。 |
| 各软件能否单独 stop？ | 能。**5 个**应用各自一个 unit，`systemctl --user stop <app>.service` 只停自己；`stop hyprland-autostart.target` 停整组。kitty 已移出（改由合成器拉起）。 |
| 密钥后端选了哪个？ | **KWallet 6**（你定的）。`gnome-keyring.service` 已从仓库删除，新增 `ksecretd.service` —— 它才是 KWallet 6 的 `org.freedesktop.secrets` 实现。依据与验证见 §9.4。 |
| 最严重的原有缺陷 | `.wants/` 里 15 个软链**全部是绝对路径且指向旧家目录 `/home/Spark`**，仓库搬到 `/home/Projects` 后**全部断链**——启动链其实早就断了。 |

---

## 1. 通知软件到底是哪一个

### 1.1 证据

| 证据 | 内容 |
| --- | --- |
| 仓库里的 unit | `mako.service`（`Description=Mako notification daemon`），被 enable 在 `graphical-session.target.wants/` 和 `hyprland-autostart.target.wants/` 两处 |
| 合成器配置 | `hyprland.lua:51` 注释「避免每次开机 **mako** 弹出这条无意义通知」；`hyprland.lua:58` 已注释掉的旧自动启动块里写的是 `hl.exec_cmd("mako")` |
| dunst 的存在形式 | `pacman` 装了 `dunst`，仓库有 `dunst/.config/dunst/dunstrc`，但：**没有** `dunst.service`（仓库和 `/usr/lib/systemd/user/` 都没有）、**没有** 任何一处 exec 它、全仓库 grep 只剩它自己的配置目录 |
| D-Bus 激活文件 | 三个文件抢同一个名字 |

```
/usr/share/dbus-1/services/fr.emersion.mako.service             -> SystemdService=mako.service
/usr/share/dbus-1/services/org.knopwob.dunst.service            -> SystemdService=dunst.service   ← 该 unit 不存在
/usr/share/dbus-1/services/org.kde.plasma.Notifications.service -> plasma_waitforname org.freedesktop.Notifications
```

**结论：mako 是实际在用的通知守护进程。** dunst 只是历史残留（配置 + 已安装的包），plasma 的那一条是 `plasma-workspace` 带来的第三方竞争者。

### 1.2 为什么这可能让你困惑

`org.freedesktop.Notifications` 是**先到先得、谁先占谁赢**，三个激活文件没有优先级。正常情况下 mako 随会话先起来并占住名字；但**如果 `.wants/` 断链导致 mako 没被拉起**（见 §2 F1），那么某次通知会触发 D-Bus 激活，由 dbus-broker 在三个候选里挑一个——挑到 dunst 就会得到 dunst 的样式，挑到 `plasma_waitforname` 就会挂在那儿等 Plasma。这正是"我到底在用哪个通知软件"变得说不清的原因。

### 1.3 已做的处理

* `mako.service` 加上 `Conflicts=dunst.service`：将来若真的出现 `dunst.service`，两者不会同时持有总线名。
* **dunst 已定为卸载**（你的决定）。命令见 §9.2 —— 一个好消息：`pacman -Rns dunst` 实际**只会删掉 dunst 本身**，不会牵连任何依赖，因为 dunst 的 9 个依赖全都被其它已装包需要（逐项核对过）：

| dunst 的依赖 | 去掉 dunst 后还有谁需要它 |
| --- | --- |
| `libxinerama` | activate-linux, gtk2/3/4, lib32-libxinerama, libreoffice-fresh, obs-studio, xdotool |
| `libxss` | firefox, google-chrome, lib32-libxss, mpv, xunlei-bin |
| `libxrandr` | activate-linux, cef, ddcutil, firefox, gtk2/3/4, libreoffice-fresh, mpv, qt6-*, telegram-desktop, xorg-xrandr … |
| `dbus` / `systemd` / `wayland` / `pango` / `gdk-pixbuf2` / `glib2` | 数十个包（显然） |

* 仓库里的 `dunst/` 配置目录**尚未删除**（那是你的数据，等你说一声；见 §9.2）。

---

## 2. 单元编写问题清单

严重度：**阻塞** = 直接导致该功能不工作｜**高** = 行为与预期不符｜**中** = 隐患/误导｜**低** = 风格

| # | 严重度 | 问题 | 已做的修复 |
| --- | --- | --- | --- |
| F1 | **阻塞** | `.wants/` 下 15 个软链全是指向 `/home/Spark/...` 的**绝对路径**。仓库搬到 `/home/Projects` 后全部断链；而且 stow 明确拒绝绝对软链作为源（`source is an absolute symlink`），所以 `stow systemd` 从来没能成功 | 全部改为**相对**软链（`../xxx.service`），并用 folded / unfolded 两种 stow 布局验证过可解析 |
| F2 | **高** | `hyprland-autostart.target` 的 `Wants=polkit-kde-agent.service` 是**悬空引用**——该文件已改名 `polkit-kde-agent.service.back`。真正在用的是发行版 `hyprpolkitagent.service`，却由 `hyprland.lua:49` 的 `systemctl --user start` 命令式拉起 | target 改为 `Wants=hyprpolkitagent.service`；删除 `hyprland.lua` 里那行命令式启动 |
| F3 | **高** | `PartOf=` 不一致：只有 `fcitx5.service` 声明了 `PartOf=hyprland-autostart.target`，其余 5 个只声明 `PartOf=graphical-session.target`。于是 `systemctl --user stop hyprland-autostart.target` **只会停掉 fcitx5**，waybar / mako / swww / kitty 照跑 | 各应用统一 `PartOf=graphical-session.target hyprland-autostart.target`，`After=` 同款（kitty 后来整体移出，见 F12） |
| F4 | **中** | 双重启用：应用 `[Install]` 同时 `WantedBy=graphical-session.target hyprland-autostart.target`，`.wants/` 里于是有两份软链，两个 target 各拉一遍 | 应用只 `WantedBy=hyprland-autostart.target`；`graphical-session.target.wants/` 只留聚合 target + `kwalletd6` |
| F5 | **高** | `kwalletd6.service` 的启用位置与它自己的注释**直接矛盾**：注释明说「只在图形会话里启动，`default.target` 早于合成器会 Qt abort（Failed to create wl_display）」，但启用链却放在 `default.target.wants/` 里 | 移到 `graphical-session.target.wants/`，与 `WantedBy=graphical-session.target` 一致 |
| F6 | **中** | `fcitx5.service` 写了**重复的 `PartOf=` 两行**，且漏掉 `After=hyprland-autostart.target` | 合并为一行并补齐 `After=` |
| F7 | **中** | `gnome-keyring.service` 写死 `Environment=GNOME_KEYRING_CONTROL=/run/user/1000/keyring`。UID 硬编码；而且这个变量只喂给守护进程自己，**客户端读不到**，属于误导 | 改用 `--control-directory=%t/keyring`（`%t` = `XDG_RUNTIME_DIR`），删掉那行 `Environment=` |
| F8 | **中** | `swww-wallpaper.service` 用 `After=swww-daemon.service` 就假定 daemon 就绪，但 `Type=exec` 只保证「进程已 exec」，不保证 Wayland socket 可连接 → 偶发 `failed to connect to daemon`。且 daemon 重启后壁纸不会重新贴 | 加最多 10 秒重试；再加 `PartOf=swww-daemon.service`，使 `restart swww-daemon` 连带重贴壁纸 |
| F9 | **低** | `polkit-kde-agent.service.back` 是死文件，但被 target 引用着（见 F2） | 文件按仓库 `.back` 习惯保留，**解除引用**即可 |
| F10 | **中** | 通知总线名三方争抢（mako / dunst / plasma） | mako 加 `Conflicts=dunst.service`；dunst 的处置见 §1.3 |
| F11 | **中** | **两套密钥后端同时在跑**：`gnome-keyring.service`（`default.target.wants/`）+ `kwalletd6.service`。但 `org.freedesktop.secrets` 与 `org.freedesktop.impl.portal.Secret` 两个名字**都指向 gnome-keyring** | **已按你的决定解决**：删 `gnome-keyring.service`，改用 KWallet 6（新增 `ksecretd.service` + portal 覆盖），见 §9.4 |
| F12 | **低** | `kitty.service` 把终端当服务跑。`Restart=no` 是对的；但 systemd 启动的 kitty 拿不到合成器注入的环境（如 `HYPRLAND_INSTANCE_SIGNATURE`），窗口规则相关行为可能与手动启动不同 | **已按你的决定删除该 unit**，改为 `hyprland.lua` 里 `hl.exec_cmd(terminal)`，详见 §9.1 |
| F13 | **提示** | 没有加发行版 `hyprpolkitagent.service` 那样的 `ConditionEnvironment=WAYLAND_DISPLAY` | **故意没加**，理由见 §4.3 |
| F14 | **提示** | 原 unit 没有 cgroup 归组 | 已加 `Slice=app-graphical.slice`（uwsm 对 XDG autostart 应用就是这么处理的），额外送你一个「停掉整组图形应用」的把手 |

### F1 的根因（值得单独记一笔）

那些绝对软链是**当年在仓库目录里跑 `systemctl --user enable` 留下的**：stow 折叠目录后 `~/.config/systemd/user/*.wants/` 就是仓库里的目录，`systemctl enable` 直接往里写，于是把「本机绝对路径」提交进了仓库。这个坑在 `docs/file-dialog-ime-and-clipboard.md` §5.1 已经记录过一次，本次把源头的**绝对软链**改成了**相对软链**，从根上消除。

> **重要习惯**：这个包 stow 之后，**不要**再用 `systemctl --user enable/disable` 管这些 unit——它会经折叠目录写回仓库。
> 用 `stow --no-folding`（见 §3.2）可以让 `.wants/` 变成真实目录，`enable/disable` 就只动 live 文件、不进仓库。

---

## 3. 重构后的结构

### 3.1 依赖图

```
graphical-session.target                  （由 uwsm 拉起；RefuseManualStart=yes）
├── hyprland-autostart.target             ← 唯一的应用启用入口
│   ├── Wants=hyprpolkitagent.service     （发行版 unit，含 ConditionEnvironment）
│   └── hyprland-autostart.target.wants/
│       ├── fcitx5.service
│       ├── mako.service                  ← 通知守护进程，Conflicts=dunst.service
│       ├── swww-daemon.service
│       ├── swww-wallpaper.service        （Requires + PartOf swww-daemon）
│       └── waybar.service
├── ksecretd.service                      ← org.freedesktop.secrets 的实现（KWallet 6）
│   └── Wants/After kwalletd6.service     （它通过 D-Bus 用 kwalletd6 存取钱包）
└── kwalletd6.service                     （会话级守护进程，不属于"应用"组）

kitty                                     ← 不再走 systemd，由 hyprland.lua 的
                                             hl.on("hyprland.start") 里 hl.exec_cmd(terminal) 拉起
```

每个应用 unit 的形状统一为：

```ini
[Unit]
PartOf=graphical-session.target hyprland-autostart.target   # 谁停我
After=graphical-session.target hyprland-autostart.target    # 我何时起

[Service]
Type=exec
ExecStart=/usr/bin/<绝对路径>
Restart=…                                                   # 见 §4.1
Slice=app-graphical.slice

[Install]
WantedBy=hyprland-autostart.target                          # 只在这一个 target 下 enable
```

`PartOf=` 是单向的（只把 target 的 stop/restart 传下来），所以**不影响单独启停**：

```bash
systemctl --user stop waybar.service          # 只停 waybar
systemctl --user stop hyprland-autostart.target   # 停一整组（其余 unit 不受影响）
```

### 3.2 文件清单

| 文件 | 状态 |
| --- | --- |
| `hyprland-autostart.target` | 重写：去掉悬空 `polkit-kde-agent`，改 `Wants=hyprpolkitagent.service` |
| `mako.service` | 重写：独立通知 unit + `Conflicts=dunst.service` |
| `waybar.service` / `swww-daemon.service` / `fcitx5.service` | 重写：统一 `PartOf`/`After`/`WantedBy`/`Slice` |
| ~~`kitty.service`~~ | **已删除**（连同 `hyprland-autostart.target.wants/kitty.service`），改由合成器拉起 |
| `swww-wallpaper.service` | 重写：重试 + `PartOf=swww-daemon.service` |
| ~~`gnome-keyring.service`~~ | **已删除**（连同 `default.target.wants/gnome-keyring.service`，该目录已空并移除），改用 KWallet 6 |
| `ksecretd.service` | **新增**：KWallet 6 的 `org.freedesktop.secrets` 实现，随 `graphical-session.target` 起，`Before=hyprland-autostart.target` |
| `xdg-desktop-portal/.config/xdg-desktop-portal/portals.conf` | **新增包**：把 portal 的 Secret 接口钉死到 `kwallet`，见 §9.4 |
| `kwalletd6.service` | 合并重复 `After=`，注明启用位置必须与 `WantedBy=` 一致 |
| `polkit-kde-agent.service.back` | 未动，但已无任何引用 |
| `.wants/` 全部软链 | 删除绝对软链，重建为**相对**软链（8 条） |
| `hypr/.config/hypr/hyprland.lua` | 删除命令式 `systemctl --user start hyprpolkitagent`；**新增** `hl.exec_cmd(terminal)`（kitty 的启动入口） |

生成相对软链的等价命令（如需重做）：

```bash
cd /home/Projects/Stow-Dotfile/systemd/.config/systemd/user
mkdir -p default.target.wants graphical-session.target.wants hyprland-autostart.target.wants
ln -sf ../gnome-keyring.service         default.target.wants/gnome-keyring.service
ln -sf ../hyprland-autostart.target     graphical-session.target.wants/hyprland-autostart.target
ln -sf ../kwalletd6.service             graphical-session.target.wants/kwalletd6.service
for u in fcitx5 mako swww-daemon swww-wallpaper waybar; do
  ln -sf "../$u.service" hyprland-autostart.target.wants/"$u.service"
done
```

---

## 4. 三个需要你知道的设计取舍

### 4.1 `Restart=` 的选择

| unit | `Restart=` | 理由 |
| --- | --- | --- |
| `mako` / `waybar` / `swww-daemon` | `on-failure` | 正常退出（你主动 stop）不该被拉起；崩溃才拉起 |
| `fcitx5` | `always` | 输入法必须一直活着，沿用原设置 |
| ~~`kitty`~~ | — | 已移出 systemd；终端"关了就是关了"，`Restart=` 语义本来就不合适 |
| `swww-wallpaper` | 不适用（`Type=oneshot`） | 一次性动作，重试逻辑写在 `ExecStart` 里 |

显式 `systemctl --user stop` 不会触发 `Restart=`，所以「停掉」永远是停掉。

### 4.2 为什么用 `Slice=app-graphical.slice`

该 slice 由 uwsm 提供（`/usr/lib/systemd/user/app-graphical.slice`），自带 `PartOf=graphical-session.target`，uwsm 也正是把 XDG autostart 应用塞进这里。收益：

* cgroup 归组，`systemd-cgtop` / `systemd-cgls` 里能一眼看到会话应用；
* 多一个「停掉整组图形应用」的把手：

```bash
systemctl --user stop app-graphical.slice    # 停掉这一组 systemd 托管的图形应用
```

注意：kitty 已不在这个 slice 里（它由合成器直接拉起），所以停 slice **不会**关掉终端。

代价：会话关闭时的回收路径从「逐个停」变成「slice 先收」，属于更规范的做法，但**这是本次唯一无法在沙箱里实测的行为变化**，如果不喜欢，删掉 5 个 unit 里的 `Slice=` 行即可回到原状。

### 4.3 为什么**没有**加 `ConditionEnvironment=WAYLAND_DISPLAY`

发行版的 `hyprpolkitagent.service` 用了它。但沙箱里：

* 没有 `Spark` 的 user systemd bus（`systemctl --user` 报 `Failed to connect to user scope bus`），无法确认 manager 环境里到底有没有 `WAYLAND_DISPLAY`；
* 一旦没有，加这个条件会让**整个会话的应用被静默 skip**（bar / 通知 / 壁纸全没），而且不报错，极难排查。

所以选择不加。你可以自己确认，再决定要不要把它加到 5 个 GUI unit 上：

```bash
systemctl --user show-environment | grep WAYLAND_DISPLAY
# 有输出 ⇒ 可以安全地给 GUI unit 加 ConditionEnvironment=WAYLAND_DISPLAY
```

---

## 5. 让改动真正生效（**需要你在真机上执行**）

⚠️ 关键前提：按 `docs/file-dialog-ime-and-clipboard.md` §5.1 的记录，本机 `~/.config/systemd/user/` 下的 unit 是**真实文件**（不是指向仓库的软链），所以 `systemd` 这个包在本机是「**配置备份**」，**我改仓库不会自动影响 live 状态**。而且 Agent 身份是 `dsh(1002)`、`/home/Spark` 是 `700`，**我自己写不进 `~/.config/systemd/`**。

### 5.1 推荐做法：跑现成的覆盖脚本（第四轮新增）

[`sync-systemd-units.sh`](sync-systemd-units.sh) 把上面那套手工步骤固化下来了，**以你（Spark）的身份跑**：

```bash
bash /home/Projects/Stow-Dotfile/docs/sync-systemd-units.sh --dry-run   # 先看要做什么
bash /home/Projects/Stow-Dotfile/docs/sync-systemd-units.sh             # 真正覆盖
```

它做四件事：

1. 备份到 `~/systemd-user-backup-<时间戳>/`；
2. 删除已退役的 live 单元（`gnome-keyring.service`、`kitty.service`、`polkit-kde-agent.service*`）；
3. 覆盖 7 个 service + 1 个 target，并重建 8 条 `.wants` **相对**链接（同时清掉 10 条过期链接和已空的 `default.target.wants/`）；
4. `daemon-reload`、重启 `kwalletd6`/`ksecretd`，并做**关键验证**——查出 `org.freedesktop.secrets` 到底被哪个进程持有（见 §9.4）。

脚本只碰上面这些名字的单元，**不会动你 live 目录里其它软件的 unit**（已在模拟环境里用无关单元 `foo-unrelated.service` 验证过）。

### 5.2 备选：改用 stow 管理

本次改动顺手修掉了 §5.1 的第 2 个阻塞点（绝对软链），所以整包 stow 现在也可行了。若你想改成 stow 管理：

```bash
# 0) 备份
B=~/systemd-user-backup-$(date +%F); mkdir -p "$B/moved"; cp -a ~/.config/systemd/user/. "$B/"
# 1) 把 live 的真实 unit 挪走（含已退役的 kitty.service / gnome-keyring.service）
cd ~/.config/systemd/user
for f in fcitx5.service mako.service swww-daemon.service swww-wallpaper.service \
         waybar.service ksecretd.service kwalletd6.service hyprland-autostart.target \
         kitty.service gnome-keyring.service; do
  [ -e "$f" ] && mv -v "$f" "$B/moved/"
done
# 2) 用 --no-folding：让 .wants/ 成为真实目录，
#    这样以后 systemctl enable/disable 只动 live 文件，不会写回仓库（F1 的根因）
cd /home/Projects/Stow-Dotfile
stow --no-folding -v -t ~ systemd xdg-desktop-portal
# 3) 重载并核对
systemctl --user daemon-reload
systemctl --user list-dependencies hyprland-autostart.target
```

> 想先看 stow 会做什么：把 `-v` 换成 `-nv`（dry-run）。
> **不要**用 `stow --adopt`：它会把 live 文件搬进仓库，覆盖掉这次的整份重构。

### 5.3 别忘了这两件事

> ⚠️ **`kitty.service` / `gnome-keyring.service` 最容易漏**：仓库里已经删了，但 live 那份是真实文件，不会自己消失。
> `sync-systemd-units.sh` 已经处理；若你手工做，请务必删掉 `hyprland-autostart.target.wants/kitty.service`
> （不删的话可能变成「systemd 起一个 kitty + hyprland.lua 再起一个」= 两个终端）。收尾自查：
>
> ```bash
> systemctl --user list-unit-files 'kitty*' 'gnome-keyring*'   # 期望：只有 gnome-keyring-daemon.{service,socket}（发行版的）
> find ~/.config/systemd/user -name 'kitty.service' -o -name 'gnome-keyring.service'   # 期望：什么都没有
> ```

改完 `hyprland.lua`（删掉命令式 polkit 启动、加上 `hl.exec_cmd(terminal)`）需要**重新加载 Hyprland 配置**或重登一次；`polkit` 代理此后由 `hyprland-autostart.target` 拉起。

---

## 6. 命令速查

```bash
# —— 通知 ——
systemctl --user status  mako.service
systemctl --user restart mako.service
systemctl --user stop    mako.service        # 只停通知，别的照跑
makoctl reload                               # 只重载 ~/.config/mako/config，不重启进程

# —— 单个软件 ——
systemctl --user restart waybar.service
systemctl --user restart swww-daemon.service # 会连带重新贴一次壁纸

# —— 整组 ——
systemctl --user stop  hyprland-autostart.target
systemctl --user start hyprland-autostart.target
systemctl --user list-dependencies hyprland-autostart.target

# —— kitty 现在不归 systemd 管 ——
# 关掉它 = 直接关窗口；想让它开机自启由 hyprland.lua 的 hl.exec_cmd(terminal) 负责

# —— 排查 ——
systemctl --user list-units 'mako*' 'waybar*' 'swww*'
systemctl --user daemon-reload
journalctl --user -u mako.service -n 50 --no-pager
systemd-analyze --user verify ~/.config/systemd/user/*.service ~/.config/systemd/user/*.target
```

---

## 7. 仍待你决定

| # | 事项 | 选项 |
| --- | --- | --- |
| 1 | ~~密钥后端二选一~~ | ✅ **已定：KWallet 6**，见 §9.4 |
| 2 | **仓库里的 `dunst/` 配置目录是否删除**（包已定卸载） | A. 直接删（`rm -rf dunst/`，git 里可找回）｜B. 改名 `dunst.unused` 存档｜C. 保持原样 |
| 3 | **是否给 GUI unit 加 `ConditionEnvironment=WAYLAND_DISPLAY`**（F13） | 先按 §4.3 自查，有 `WAYLAND_DISPLAY` 再加 |
| 4 | **`Slice=app-graphical.slice` 是否保留**（§4.2） | 保留 = 多一个组级把手；删除 = 行为与改动前完全一致 |
| 5 | **`polkit-kde-agent.service.back` 是否删除**（F9） | 已无引用，留着只是历史记录 |
| 6 | **gnome-keyring 的包要不要留着**（`code-features` 与 `qtkeychain-qt6` 依赖它，**不能卸**） | 已确认必须留着；它的 D-Bus 激活文件仍在 `/usr/share`，只是**不再由本仓库启动**。若哪天你发现 secrets 又回到 gnome-keyring，见 §9.4 的排查 |

---

## 8. 沙箱里**无法**验证的部分（请你在真机上确认）

1. **live unit 内容**：`/home/Spark` 是 `700`，运行身份 `dsh(1002)` 无权读取 `~/.config/systemd/user/`，因此以上全部基于**仓库**内容分析。如果 live 已经和仓库漂移，§5 的 `cp -a` 备份后请对比一下。
2. **user systemd bus**：`systemctl --user` 在沙箱里报 `Failed to connect to user scope bus`，所以「改动前哪些 unit 处于 active/failed」我无法查。请执行：

```bash
systemctl --user list-units --all 'mako*' 'waybar*' 'swww*' 'fcitx5*' 'kitty*' 'hyprland-autostart*'
systemctl --user list-unit-files 'mako*' 'waybar*' 'swww*' 'hyprland-autostart*'
```

3. **`Slice=app-graphical.slice` 的实际回收行为**（§4.2）。
4. **`ExecStart` 里的重试循环**（`swww-wallpaper.service`）：`systemd-analyze verify` 语法通过，但真机上 `swww img` 是否需要重试、重试是否成功，只有实际重启时才看得到。手动验证：

```bash
systemctl --user restart swww-wallpaper.service && systemctl --user status swww-wallpaper.service
```

5. **无法代你弹出任何 UI**（第二轮新增）：Agent 身份是 `dsh(1002)`，图形会话属于 `Spark(1000)`，`/run/user/1000` 是 `700`，`/run/user/1000/bus` 直接 `Permission denied`；Agent 自己的 `WAYLAND_DISPLAY` 也是空的。
   * 能验证的：所有 D-Bus 调用的**形状**（`CreateCollection` 确实返回了 `<collection>=/` 与真实的 `<prompt>=/org/freedesktop/secrets/prompt/pN`，说明签名与参数都对）。
   * **不能验证的**：窗口有没有真的画出来。对那个 prompt 调 `Prompt s ""` 只拿到 `Call failed: Access denied`（无显示环境下的预期结果）。所以脚本里把「GUI 一定可行」单列一节（§9.3.3）。
6. **无法卸载软件包**（第二轮新增）：`sudo` 在本沙箱里被 `no new privileges` 标志挡住（`sudo: The "no new privileges" flag is set, which prevents sudo from running as root`），因此 `pacman -Rns dunst`、`pacman -S seahorse` 都必须你自己执行。
7. **无法写入 `~/.config/systemd/`**（第四轮新增）：Agent 身份 `dsh(1002)`，而 `/home/Spark` 是 `700`，`ls /home/Spark/.config` 直接 `Permission denied`（四个层级全不可写）。所以「覆盖 .config/systemd 中的单元」这一步我只能做成 [`sync-systemd-units.sh`](sync-systemd-units.sh) 交给你跑；该脚本已在模拟的 live 目录上完整验证过（含「不误伤无关单元」与「无断链」两项）。

---

## 9. 第二轮变更（按你的决定执行）

### 9.1 kitty 退出 systemd，改为合成器启动

**仓库侧已改：**

| 动作 | 文件 |
| --- | --- |
| 删除 unit | `systemd/.config/systemd/user/kitty.service` |
| 删除启用链 | `systemd/.config/systemd/user/hyprland-autostart.target.wants/kitty.service` |
| 新增自动启动 | `hypr/.config/hypr/hyprland.lua` 的 `hl.on("hyprland.start")` 里加 `hl.exec_cmd(terminal)`（`terminal` 变量在第 29 行 = `"kitty"`） |

改完后的 hook 长这样：

```lua
hl.on("hyprland.start", function()
  hl.exec_cmd(terminal)                       -- kitty：合成器直接拉起
  hl.exec_cmd("systemctl --user mask --now drkonqi-coredump-launcher.socket 2>/dev/null || true")
end)
```

理由：systemd 启动的 kitty 拿不到合成器注入的环境（`HYPRLAND_INSTANCE_SIGNATURE` 等），窗口规则 / `hyprctl` 相关行为会与手动启动不一致。代价是**不再能 `systemctl --user stop kitty`** —— 关掉终端就是关窗口。

live 侧的清理见 §5 第 1、2 步（`kitty.service` 是真实文件，不会自己消失；顺手删掉 `hyprland-autostart.target.wants/kitty.service`，否则可能起两个终端）。

### 9.2 卸载 dunst

**我没能代你执行**（§8 第 6 条：沙箱里 `sudo` 被 `no new privileges` 挡住）。请你自己跑：

```bash
sudo pacman -Rns dunst
```

好在**不会牵连任何依赖**：dunst 的 9 个依赖（`libxinerama` `dbus` `systemd` `wayland` `libxss` `pango` `gdk-pixbuf2` `libxrandr` `glib2`）全都被其它已装包需要，逐项核对见 §1.3。所以 `-s` 这一步实际什么都不会多删。

卸载后验证：

```bash
pacman -Qq dunst            # 期望：error: package 'dunst' was not found
pacman -Qdtq | grep -E 'libxinerama|libxss|libxrandr'   # 期望：无输出（没变成孤儿）
```

`Optional Deps: libnotify: dunstify [installed]` —— `dunstify` 会一起消失；它只是 `notify-send` 的替代品，`notify-send`（libnotify）仍在。

仓库里的 `dunst/` 配置目录**尚未删除**，等你决定（§7 第 2 项）。

### 9.3 对比两个密钥后端的 UI

脚本：[compare-secrets-backends.sh](compare-secrets-backends.sh)（`chmod 775`）。

```bash
bash /home/Projects/Stow-Dotfile/docs/compare-secrets-backends.sh
# 可选： --diag（打印原始输出）  --force-new（强制走新建路径）  --no-prompt（不交互）
```

#### 9.3.1 第一版为什么弹不出窗 —— 四个实测出来的坑

第一版脚本在真机上什么 UI 都没弹出来。逐条排查后确认是**脚本自己的四个 bug**，不是环境问题：

| # | 坑 | 症状 | 修法 |
| --- | --- | --- | --- |
| 1 | **中文 label** | `secret-tool` 直接失败并打印 usage，报 `Invalid byte sequence in conversion input`（rc=2）。GLib 在 POSIX/C locale 下无法转换 `--label='DSH 密钥后端对比测试'` | 所有 label 改纯 ASCII |
| 2 | **`gdbus` 的文本参数会静默错配** | `gdbus call ... NameHasOwner "['x']"` **不报错**，但语义是错的（实测返回 `false`）。锁密钥环要的是 `ao` 参数，用 `['/path']` 传过去等于「锁了个寂寞」→ 密钥环一直是解锁状态 → **永远不弹窗** | 所有 D-Bus 调用改用 `busctl` 的**强类型**参数 |
| 3 | **`busctl` 签名要整体作为一个参数** | 写成 `... AddNotification s "x" a{sv} 1 ...` 报 `Too many parameters for signature` | 写成 `... AddNotification "sa{sv}" "x" 1 key type value`；`a{sv}` 元素格式是 `<个数> <键> <值类型> <值>` |
| 4 | **`secret-tool --collection` 只认 `default` 或完整对象路径** | `--collection='DSH-UI-Test'` 报 `collection must be a full path, or the 'default' alias`。想凭空造密钥环只能用 D-Bus | `CreateCollection "a{sv}s" 1 Label s DSH-UI-Test ""` → 拿到 `oo <collection> <prompt>` → 对 `<prompt>` 调 `Prompt s ""`。**busctl 打印的对象路径带双引号，必须先 `tr -d '"'`**，否则报 `Invalid object path` |

另外还有个「不是 bug 但会让你以为坏了」的情形：**没有 `login` 密钥环时**，`secret-tool store` 会直接报 `Object does not exist at path .../collection/login`，而不是弹窗。脚本现在能识别并提示改走 `--force-new`。

> 这四个坑都是 Agent 在本机反复实测定位的（gnome-keyring 在自己的沙箱会话里应答了这些调用，`--diag` 能看到原始返回），不是猜的。

#### 9.3.2 现在的脚本做什么

1. **数据在哪**（不需要任何弹窗）— 列 `~/.local/share/keyrings/*.keyring` 和 `~/.local/share/{kwalletd,kwallet}/*.kwl` 的大小与修改时间。**这一步往往就够做决定了**：哪个库里有真数据、时间更新，那个才是你实际在用的。
2. **总线归属** — 五个名字各由谁持有。
3. **确保两个后端都真的在跑** — 没跑就先 `systemctl --user start`，再退到 D-Bus 激活。没跑就一定弹不出窗，这一步是第一版缺失的。
4. **GNOME Keyring** — 有 `login` 密钥环就 `secret-tool lock` → 读 `Locked` 属性确认锁上了 → `secret-tool store` 触发；没有就直接走新建路径。
5. **KWallet** — `busctl` 列钱包 → `closeAllWallets` → `kwallet-query -l <钱包>` 触发。
6. **最可靠的一招：GUI** — 见下。

脚本用**耗时判定**兜底：人类至少要 1.5 秒才能读完对话框并输入密码，所以如果触发命令在 1.5 秒内就返回了，脚本会明确告诉你「没有弹窗」，而不是让你猜。

#### 9.3.3 如果 CLI 还是弹不出来：直接用 GUI（推荐）

CLI 触发依赖 `gcr-prompter` / `kwalletd6` 在自己这套环境里能把窗口画出来。Agent 的沙箱没有显示（`WAYLAND_DISPLAY` 未设置），`Prompt` 调用只拿到 `Call failed: Access denied`，**这一步我无法验证**，所以给你一条一定可行的路：

| 后端 | 工具 | 状态 | 用法 |
| --- | --- | --- | --- |
| KDE Wallet | `kwalletmanager5` | ✅ **已安装**（包 `kwalletmanager` 26.08，依赖 `kwallet`=KF6，所以它连的就是 `kwalletd6`） | `kwalletmanager5 &` → 左侧点任意钱包就会弹密码框；`File → New Wallet` 可新建 |
| GNOME Keyring | `seahorse` | ❌ 未安装 | `sudo pacman -S seahorse` → `seahorse &` → 左侧「登录」钥匙环，双击即弹解锁框 |

`seahorse` 是 gnome-keyring 的官方图形前端，**打开就一定会弹解锁/新建密钥环对话框**，不存在「无密码所以没 UI」以外的失败情形。

#### 9.3.4 决定时还要注意这条硬约束

```
/usr/share/dbus-1/services/org.freedesktop.secrets.service            -> gnome-keyring-daemon
/usr/share/dbus-1/services/org.freedesktop.impl.portal.Secret.service -> gnome-keyring-daemon
/usr/share/dbus-1/services/org.freedesktop.impl.portal.desktop.kwallet.service -> ksecretd
```

当时这两个名字都指向 gnome-keyring。所以「改用 KWallet」不是「停掉 gnome-keyring」那么简单——**怎么解决见 §9.4**。

---

### 9.4 第四轮：改用 KWallet 6 作密钥后端

#### 9.4.1 先搞清楚 KWallet 6 到底谁提供 `org.freedesktop.secrets`

这一步差点做错，所以把证据列出来。`gnome-keyring` 的包**不能卸**（`code-features`、`qtkeychain-qt6` 依赖它），所以「卸掉 gnome-keyring」这条路根本不存在；而它的 D-Bus 激活文件在 `/usr/share`（需要 root 才能删）。真正要找的是：**KWallet 侧谁负责这个名字？**

答案是 **`ksecretd`**（属于 `kwallet` 6.30.0 包），不是 `kwalletd6`：

| 证据 | 结果 |
| --- | --- |
| `ksecretd` 内嵌的接口 XML | `org.freedesktop.Secret.{Service,Collection,Item,Session,Prompt}` + `org.freedesktop.impl.portal.Secret` + `org.kde.kwalletcompat` |
| `kwalletd6` 内嵌的接口 XML | 没有 `org.freedesktop.Secret.*` |
| 二进制里的 bus name | `ksecretd` 里有**独立的** `org.freedesktop.secrets` 字符串；`kwalletd6` 里**没有** |
| 发行版给的 systemd unit | **两个都没有**（`ksecretd` 只有两个 D-Bus 激活文件：`org.kde.secretservicecompat` / `org.freedesktop.impl.portal.desktop.kwallet`） |

> ⚠️ **一个会误导人的坑**：`org.freedesktop.secrets` 在 `ksecretd` 里是**以 Qt `QStringLiteral` 也就是 UTF-16 存的**。
> 用 `strings` / ASCII `grep` 搜**只有** `org.freedesktop.secrets.aliases`（一个 KConfig 组名）会被命中，看起来就像
> 「ksecretd 根本不注册这个名字」。必须按 UTF-16LE 搜才能看到那个独立的 NUL 结尾字符串：
>
> ```bash
> python3 -c "
> d=open('/usr/bin/ksecretd','rb').read(); p='org.freedesktop.secrets'.encode('utf-16-le')
> i=-1
> while (i:=d.find(p,i+1))>=0: print(i, d[i:i+60].split(b'\x00\x00')[0].decode('utf-16-le'))"
> # 398056 org.freedesktop.secrets          ← 独立字符串 = 真正的 bus name
> # 398456 org.freedesktop.secrets.aliases  ← 另一个
> ```

#### 9.4.2 改了哪些东西

| 动作 | 文件 |
| --- | --- |
| **删除** | `systemd/.config/systemd/user/gnome-keyring.service` |
| **删除** | `systemd/.config/systemd/user/default.target.wants/gnome-keyring.service`（该目录随后变空，已移除） |
| **新增** | `systemd/.config/systemd/user/ksecretd.service` |
| **新增** | `systemd/.config/systemd/user/graphical-session.target.wants/ksecretd.service -> ../ksecretd.service` |
| **新增包** | `xdg-desktop-portal/.config/xdg-desktop-portal/portals.conf` |
| 补注释 | `kwalletd6.service` 注明 `ksecretd` 用 `Wants=` 依赖它 |

`ksecretd.service` 的三个关键点：

```ini
Wants=kwalletd6.service
After=kwalletd6.service          # ksecretd 通过 D-Bus 借用 kwalletd6 存取钱包
Before=hyprland-autostart.target # 必须早于需要密钥的应用，否则总线名会被 gnome-keyring 抢走
Environment=QT_QPA_PLATFORM=wayland;xcb   # ksecretd 链接 libQt6Gui，与 kwalletd6 同理
```

**为什么不需要 `BusName=org.freedesktop.secrets` 的 `Type=dbus`**：本机的 session bus 是 dbus-broker，而该名字同时还有一个发行版的 legacy 激活文件（指向 gnome-keyring）。让 systemd 也去声明这个名字属于「两套机制抢同一个总线名」——正是 `kwalletd6.service` 注释里刻意避免的情形（万一 dbus-broker 处理冲突失败，代价是整个会话总线起不来）。所以选择**靠启动顺序**：`ksecretd` 随 `graphical-session.target` 起、且在应用之前，它自己会把名字占住，gnome-keyring 的激活文件就永远不会被查。

#### 9.4.3 portal 侧：显式钉到 KWallet

两个 portal 后端都提供 Secret：

```
gnome-keyring.portal   DBusName=org.freedesktop.secrets                    UseIn=gnome
kwallet.portal         DBusName=org.freedesktop.impl.portal.desktop.kwallet UseIn=kde
```

本机 `XDG_CURRENT_DESKTOP=Hyprland`，**两个 `UseIn` 都不匹配**，所以后端是靠字典序兜底挑的（`gnome-keyring` < `kwallet`），属于碰巧而不可靠。新增的用户级覆盖把它钉死（`portals.conf(5)` 规定的最高优先级位置，值是 `.portal` 文件去掉扩展名的后端名）：

```ini
[preferred]
org.freedesktop.impl.portal.Secret=kwallet
```

只覆盖 Secret 这一个接口，不动其它 portal。

> 顺带一提：就算这条配置失效、portal 退回选 `gnome-keyring` 后端，它调用的是 `DBusName=org.freedesktop.secrets`——而那个名字现在也归 `ksecretd`。
> **两条路都通向 KWallet**，这也是让 `ksecretd` 持有该名字比改 portal 更根本的原因。

#### 9.4.4 改完怎么验证（关键一条）

```bash
# ① ksecretd 在跑吗
systemctl --user status ksecretd.service

# ② org.freedesktop.secrets 到底被哪个进程持有 —— 这一条才是真正的判据
CONN=$(busctl --user call org.freedesktop.DBus /org/freedesktop/DBus \
         org.freedesktop.DBus GetNameOwner s org.freedesktop.secrets | awk '{print $2}' | tr -d '"')
PID=$(busctl --user call org.freedesktop.DBus /org/freedesktop/DBus \
        org.freedesktop.DBus GetConnectionUnixProcessID s "$CONN" | awk '{print $2}')
ps -p "$PID" -o pid,comm,args
#   期望：ksecretd
#   若显示 gnome-keyring-daemon：说明 ksecretd 没起来，名字被激活文件抢走了

# ③ ksecretd 暴露的对象树应当就是标准 Secret Service 布局
busctl --user tree org.freedesktop.secrets
```

`sync-systemd-units.sh` 的第 7 节会自动跑这三步并直接告诉你「归 ksecretd ✓ / 归 gnome-keyring ✗」。

#### 9.4.5 遗留风险（说清楚）

1. **启动竞态**：如果某个应用在 `ksecretd` 占名之前就请求密钥，总线会按发行版激活文件拉起 gnome-keyring 并让它占名。`Before=hyprland-autostart.target` 把窗口压到最小，但没有 `BusName=` 就无法从机制上杜绝（原因见 §9.4.2）。**验证命令能立刻发现**这种情况。
2. **gnome-keyring 的包仍在**（`code-features`/`qtkeychain-qt6` 依赖），只是不再由本仓库启动。它的 `~/.local/share/keyrings` 数据也原样保留，没有迁移到 KWallet——**原先存在 gnome-keyring 里的密钥不会自动出现在 KWallet 里**。需要迁移的话得逐个重新登录保存，或临时把两边都跑起来手工导出。
3. **portal 覆盖要重启 portal 才生效**：`systemctl --user restart xdg-desktop-portal.service`，否则下次登录才生效。
