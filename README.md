# Stow-Dotfile

一套用 [GNU Stow](https://www.gnu.org/software/stow/) 管理的 dotfiles 集合，覆盖 Arch Linux + Hyprland(Wayland) 桌面下的窗口管理器、状态栏、终端、输入法、字体、代理与各种脚本。仓库按「一个顶层目录 = 一个 stow 包」组织，各包内部保持相对于 `$HOME`（或 `/`）的真实目录层级，因此可以直接用 `stow` 建立软链接，而不必手工复制。

> 本仓库已做脱敏：所有密钥 ID、邮箱、指纹、订阅地址、项目管理 ID、内网/公网主机名与个人家目录路径都已替换为占位符或通用值。使用前请按下方「约定」一节替换成自己的值。

## 目录结构（stow 包一览）

| 包 | 部署位置 | 内容 |
| --- | --- | --- |
| `aria2` | `~/.config/aria2` | aria2 下载器配置（RPC、BT、DHT 等） |
| `Code` | `~/.config/Code` | VS Code 用户设置 |
| `dunst` | `~/.config/dunst` | dunst 通知守护配置（含备份主题） |
| `electron` | `~/.config` | Electron 应用通用启动参数 |
| `etc` | `/etc` | 系统级配置（`doas.conf`、`pacman.conf`、`paru.conf`、风扇曲线与 `fancontrol.service` 等），需要 root 权限部署 |
| `fastfetch` | `~/.config/fastfetch` | fastfetch 系统信息展示 |
| `fcitx5` | `~/.config/fcitx5` | fcitx5 输入法配置 |
| `filepicker` | `~/.local/bin` + `~/.config/systemd/user` | 统一文件选择器：Thunar 与 GTK 文件对话框的“文件夹优先 + 名称 A-Z”排序、Thunar 作为默认目录打开程序（含用户服务） |
| `fontconfig` | `~/.config/fontconfig` | 全局字体替换规则与 `conf.d/` 片段（Typora、网页图标字体等） |
| `fuzzel` | `~/.config/fuzzel` | fuzzel 应用启动器 |
| `gtk3.0` | `~/.config/gtk-3.0` | GTK3 主题与外观 |
| `hypr` | `~/.config/hypr` | Hyprland 配置（Lua DSL）及辅助脚本 |
| `kitty` | `~/.config/kitty` | kitty 终端配置与配色 |
| `mako` | `~/.config/mako` | mako 通知守护（含点击聚焦、免打扰提示音脚本） |
| `mihomo` | `/etc/mihomo` | mihomo 代理内核配置（**仅示例文件**，真实订阅与运行时数据不入库） |
| `mpv` | `~/.config/mpv` | mpv 播放器配置 |
| `neofetch` | `~/.config/neofetch` | neofetch 配置 |
| `nvim` | `~/.config/nvim` | 常规 Neovim 配置 |
| `nvim_ds-lazyvim` | `~/.config/nvim` | 基于 LazyVim 的另一套 Neovim 配置（与 `nvim` 包二选一） |
| `pinentry` | `~/.config/pinentry` + `~/.local/bin` | 把 GPG/SSH 弹窗里的机器标识替换成可读名称 |
| `qt6ct` | `~/.config/qt6ct` | Qt6 主题设置 |
| `ranger` | `~/.config/ranger` | ranger 文件管理器 |
| `rofi` | `~/.config/rofi` | rofi 启动器与脚本 |
| `satty` | `~/.config/satty` | satty 截图标注工具 |
| `starship` | `~/.config` | starship 提示符 |
| `steam` | `~/.local/share/applications` | Steam 输入法修复（XWayland / 原生 Wayland 两档 desktop 文件） |
| `systemd` | `~/.config/systemd/user` | 用户级 systemd unit 与启动模块化 |
| `tmux` | `~/.config/tmux` | tmux 配置：本地/SSH 双层前缀避让、性能监测、Vim 风格窗格操作与 Catppuccin Mocha 主题 |
| `uwsm` | `~/.config/uwsm` | uwsm 会话管理 |
| `waybar` | `~/.config/waybar` | waybar 状态栏、样式与通知历史/免打扰脚本 |
| `wofi` | `~/.config/wofi` | wofi 启动器 |
| `xdg-desktop-portal` | `~/.config/xdg-desktop-portal` | 桌面门户配置 |
| `yazi` | `~/.config/yazi` | yazi 文件管理器 |
| `zi-deprecated` | `~/.config/zi` | 已弃用的 zi/zinit 插件目录（插件以 git submodule 引入） |
| `zsh` | `~/` | `.zshenv`、`.zprofile`、`.zshrc`（终端自动新建 tmux 会话） |
| `zsh-zim` | `~/.config/zsh-zim` | zim 框架配置 |
| `zsh-zinit` | `~/.config/zsh` | zinit 框架配置 |

此外：

- `docs/` 是**文档目录**，不参与 stow，见下方索引。
- `zi-deprecated/` 下的 zsh 插件是 submodule，克隆后需执行
  `git submodule update --init --recursive` 才会出现内容。

## Stow 用法

在仓库根目录执行（`-d` 指定 stow 目录，`-t` 指定目标目录）：

```bash
# 安装 / 首次建立软链接
stow -d . -t ~ <package>

# 更新：先删除旧链接再重新建立，适合包内增删文件之后
stow -d . -t ~ --restow <package>

# 卸载：删除该包创建的所有软链接（回滚）
stow -d . -t ~ -D <package>

# 一次处理多个包
stow -d . -t ~ --restow aria2 kitty waybar zsh
```

系统级包（`etc/`、`mihomo/`）的目标目录是 `/`，需要 root 且建议先 `--simulate` 预览：

```bash
sudo stow -d . -t / -n -v --no-folding etc      # 只预览，不落盘
sudo stow -d . -t / --no-folding etc
```

注意事项：

- 系统级包一律加 `--no-folding`：避免目标目录缺失时把 `/etc/systemd/system` 之类
  的整个目录折叠成指向用户可写仓库的软链（详见 `docs/stow-mihomo-management.md` §3.3）。
- 目标路径已有同名真实文件时 stow 会报冲突，且**整包操作会整体中止**，先备份或删除再 stow。
- `etc` 包里的 `etc/systemd/system/fancontrol.service` 会部署为
  `/etc/systemd/system/fancontrol.service`（覆盖发行版同名 unit），并自带
  `multi-user.target.wants/` 启用链；本机若已 `systemctl enable fancontrol`，
  先 `sudo systemctl disable fancontrol.service` 再 stow，否则启用链会冲突。
- `nvim` 与 `nvim_ds-lazyvim` 都部署到 `~/.config/nvim`，**不要同时 stow**。
- 删除/回滚后若仍有残留空目录，可自行 `rmdir` 清理。

## docs/ 索引

| 文档 | 主题 |
| --- | --- |
| [mihomo-config-structure.md](docs/mihomo-config-structure.md) | mihomo 配置结构：分组分层、profile 机制与部署 |
| [stow-mihomo-management.md](docs/stow-mihomo-management.md) | 用 GNU Stow 管理 mihomo 配置的可行性与方案 |
| [tailscale-mihomo-fakeip-conflict.md](docs/tailscale-mihomo-fakeip-conflict.md) | Tailscale 与 mihomo（TUN/fake-ip）冲突的排查与修复 |
| [apple-music-storefront-redirect.md](docs/apple-music-storefront-redirect.md) | Apple Music 网页版跳 /us、/cn 与播放报错的根因和修复 |
| [systemd-units-review-and-modularization.md](docs/systemd-units-review-and-modularization.md) | systemd user unit 审查与启动模块化 |
| [tmux-configuration.md](docs/tmux-configuration.md) | tmux 键位、复制模式、会话操作与 Catppuccin Mocha 主题 |
| [tmux-keybindings.md](docs/tmux-keybindings.md) | tmux 按键详细说明：操作步骤、后续切换与会话树重命名 |
| [file-dialog-ime-and-clipboard.md](docs/file-dialog-ime-and-clipboard.md) | Firefox 系统文件对话框的输入法与剪贴板问题 |
| [filepicker-unification.md](docs/filepicker-unification.md) | 文件选择器统一：Thunar + GTK 对话框的排序、默认程序与 portal 后端 |
| [dsh-user-migration-and-workspace-permissions.md](docs/dsh-user-migration-and-workspace-permissions.md) | 工作区权限修复与用户迁移说明 |
| [dsh-write-tool-permission-behavior.md](docs/dsh-write-tool-permission-behavior.md) | DSH write 工具权限行为的实测结论 |
| [dsh-pnpm-store-mismatch-after-user-migration.md](docs/dsh-pnpm-store-mismatch-after-user-migration.md) | pnpm store 不一致（`ERR_PNPM_UNEXPECTED_STORE`）的排查与修复 |
| [nvim_ds-lazyvim_doc/](docs/nvim_ds-lazyvim_doc/) | LazyVim 插件清单、Markdown 写作模块、Neogit 快捷键总表 |

`docs/` 下另有若干可执行排查/修复脚本（`*.sh`），用法见各脚本头部注释。

## 约定

- **提交规范**：使用 [Conventional Commits](https://www.conventionalcommits.org/)，
  按包/主题拆分提交（如 `feat(waybar): …`、`fix(hypr): …`、`chore(git): …`、`docs: …`），
  保证每个提交语义单一、可单独回滚。
- **脱敏与占位**：仓库中不出现真实个人信息。常见占位符：
  - 邮箱 `user@example.com`、密钥 ID `0123456789ABCDEF`、SSH 指纹 `SHA256:PLACEHOLDER_FINGERPRINT`
  - 家目录统一写作 `/home/user`（脚本内优先用 `$HOME` / `os.path.expanduser("~")`）
  - 订阅与节点：`YOUR_SUBSCRIPTION_TOKEN`、`YOUR_AIRPORT_HOST`、`YOUR_LIANGXIN_HOST` 等
  - 公网 VPS 示例地址：`203.0.113.1`（文档保留段）
  - 字体族名 `Iosevka Spark Mono` 等属于真实字体名，按原样保留（改名会导致字体匹配失败）
- **运行时数据不入库**：`mihomo/config.yaml`、`profiles/`、`GeoIP.dat`、`cache.db`，
  aria2 的 `dht*.dat`、`session.lock`，以及各类 `*.tgz`、`__pycache__/`、编译产物等已被
  `.gitignore` 排除，请勿强制添加。
- **截图/媒体不入库**：`*.png`、`*.jpg`、视频等只在本地保留；需要展示效果时在文档里描述。
- **字体与主题**：字体名、主题名（Catppuccin Mocha 等）保持与上游一致，便于对照。

## 免责声明

本仓库是个人配置的整理与备份，按「现状」提供，不保证适用于其他机器或发行版版本。
其中的脚本可能修改系统配置、启动服务或改动网络设置，使用前请自行审阅并做好备份；
因直接套用造成的任何损失由使用者自行承担。文档中的域名、IP、密钥 ID、凭据均为示例或占位值，
请替换为你自己的真实值后再部署。
