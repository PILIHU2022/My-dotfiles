# 文件选择器统一：Thunar + GTK 文件对话框

> 目标：桌面上打开/选择文件的入口不再各自为政 —— 文件浏览用 Thunar，
> 应用内文件对话框统一走 GTK；两者默认都按
> **“文件夹在前 → 文件在后，各自按名称 A→Z（大小写不敏感）”** 排列。

## 一、盘点：此前可用的入口

| 入口 | 位置 | 排序现状（改前） |
| --- | --- | --- |
| Thunar | `Super+E`（`fileManager`） | 名称升序；`misc-folders-first` 默认 true、大小写不敏感默认 false |
| GTK 文件对话框 | Firefox / GTK 应用 / portal | GTK3 的 `sort-directories-first` **默认 false**，且本机 `sort-column` 被改成了 `type` → 文件夹与文件混排、按类型排 |
| yazi | `yazi` 命令 | 目录优先 + 字母序（已满足，但不作为系统默认） |
| ranger | `ranger` 命令 | 目录优先 + natural 排序（同上） |
| Dolphin / Nemo / kitty-open | 注册在 `inode/directory` 关联里 | `xdg-open <dir>` 实际落在 `kitty-open.desktop`（`kitty +open`），不是 Thunar |

结论：文件浏览统一到 **Thunar**，应用内对话框统一到 **GTK**（`xdg-desktop-portal-gtk`）；
终端里的 yazi/ranger 保留，只是不再作为“打开目录”的默认程序。

## 二、实际落点

| 设置 | 存储位置 | 值 |
| --- | --- | --- |
| GTK3 文件对话框排序 | dconf `org.gtk.Settings.FileChooser` | `sort-column='name'`、`sort-order='ascending'`、`sort-directories-first=true` |
| GTK4 文件对话框排序 | dconf `org.gtk.gtk4.Settings.FileChooser` | 同上（GTK4 默认已是目录优先） |
| Thunar 排序 | xfconf 频道 `thunar` | `misc-folders-first=true`、`misc-case-sensitive=false`、`last-sort-column=THUNAR_COLUMN_NAME`、`last-sort-order=GTK_SORT_ASCENDING` |
| 打开目录的默认程序 | `~/.config/mimeapps.list` | `inode/directory=thunar.desktop` |
| portal FileChooser 后端 | `~/.config/xdg-desktop-portal/portals.conf` | `org.freedesktop.impl.portal.FileChooser=gtk` |

`last-sort-*` 是 Thunar “新窗口的默认排序”（不是每目录记忆），登录时重置为名称升序。

## 三、为什么用脚本 + oneshot，而不是纯 Stow

dconf（GTK）、xfconf（Thunar）、mimeapps.list（默认程序）都是运行时数据库或由
程序改写的文件：把仓库里的文件软链过去，第一次写入就会被原子替换成普通文件，
Stow 链接随之失效。因此：

- `filepicker` 包提供 `~/.local/bin/filepicker-defaults`（幂等脚本）；
- `filepicker-defaults.service` 在登录时执行一次，`--check` 可随时核对。

`portals.conf` 是纯文本，仍由 `xdg-desktop-portal` 包直接 Stow。

## 四、部署与验证

```bash
stow -d . -t ~ --restow filepicker xdg-desktop-portal
systemctl --user daemon-reload
systemctl --user enable --now filepicker-defaults.service
systemctl --user restart xdg-desktop-portal.service   # 让 portals.conf 生效
```

验证：

```bash
~/.local/bin/filepicker-defaults --check
gsettings get org.gtk.Settings.FileChooser sort-column
gsettings get org.gtk.Settings.FileChooser sort-directories-first
xfconf-query -c thunar -p /misc-folders-first
xdg-mime query default inode/directory   # thunar.desktop
```

## 五、回滚

```bash
systemctl --user disable --now filepicker-defaults.service
stow -d . -t ~ -D filepicker
```

运行时值不会自己恢复：按需在 Thunar 首选项 / GTK 对话框的列头里改回，
或 `dconf reset org.gtk.Settings.FileChooser sort-directories-first`。

## 六、已知边界

- GTK3 的排序键是**每用户 dconf**，不是 portal 级配置；KDE 原生对话框（不使用
  portal 的 Qt 程序）不在此列。
- 终端选择器（yazi/ranger）和 Neovim 的 telescope/neo-tree 未改动。
- `xdg-mime default` 只改 `[Default Applications]` 里的一行，其它关联保持不变。
