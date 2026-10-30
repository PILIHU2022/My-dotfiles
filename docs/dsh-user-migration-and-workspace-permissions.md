# 工作区权限修复与 `dsh` 用户迁移说明

> 主机：`SparkPC` ｜ 工作区：`/home/Projects` ｜ 仓库：`/home/Projects/Stow-Dotfile`
> 记录时间：2026-10-02 ｜ 所有结论均为在本机实测得到的数据，非推测

---

## 摘要（TL;DR）

| 问题 | 结论 |
| --- | --- |
| `dsh` 写入工作区报 `EACCES` | **真问题**：`Stow-Dotfile` 下 **541 个目录里有 540 个组不可写**（755/750），`dsh` 不是目录属主，只能靠"组"权限，所以写不进去 |
| `❌ drwxr-xr-x nobody:nobody，组无写权限` | **沙箱视角的假象**：DSH 的 `bwrap` 沙箱把 uid/gid 做了重映射，磁盘上属于 `Spark(1000)`、组为 `wheel(998)`/`agent(1006)` 的文件在沙箱内一律显示成 `nobody:nobody`。它看到的现象"像"权限坏了，但真正的坏点在上面那条 |
| 无法创建 `index.lock` / `objects` | **误判**：`.git` 实际是 `775 Spark:wheel`，而 `dsh` 在 `wheel` 组里，`index.lock`/`objects` 本来就能创建（实测 `touch .git/xxx` 成功）。真正失败的是 `hypr/`、`mako/` 这类 755/750 的普通目录 |
| `detected dubious ownership` | **沙箱视角的假象**：真实 `dsh` 身份下 `git status` 正常；`~/.gitconfig` 里已配置 `safe.directory`。该报错只在沙箱内出现，因为沙箱内仓库属主被显示成 `65534` ≠ 进程 uid `1002` |
| 能不能"不用 root"解决 | **不能**。`dsh` 不是这些文件的属主，`chmod/chgrp/setfacl` 对别人的文件一律 `EPERM`；`sudo` 需要密码，且只有 `pacman/journalctl/dmesg/apt/dnf` 是 NOPASSWD。修复必须由 root 执行一条脚本 |

**一条命令修复**（需要你输入 sudo 密码）：

```bash
sudo bash /home/Projects/Stow-Dotfile/docs/fix-workspace-permissions.sh
```

---

## 1. 背景与目标

### 1.1 为什么要换用户

原来 `dsh web` 跑在 `Spark` 用户下，于是出现两个身份纠缠的问题：

1. **身份错配**：harness 进程以 `Spark` 运行，产生的文件（日志、缓存、git 索引、检出文件）全部属于 `Spark`；而配置、密钥、会话又要在 `dsh` 的场景里被读写，跨用户就会撞权限。
2. **无法隔离**：Harness 需要写入自己的状态目录（`~/.dsh`）和大量临时文件，用与日常桌面同一个 `Spark` 账号，等于把 Agent 的写权限等同于日常账号的写权限。
3. **工作区共享困难**：`Spark` 的 dotfiles 仓库集中在 `~/.config`，而新的工作区被搬到了 `/home/Projects`，两个用户都要能读写同一份仓库。

### 1.2 目标状态

* 新建专用账号 `dsh`，使用 `zsh`，加入共享组 `agent`；
* `Spark` 也加入 `agent`，两个账号通过**同一个组**共享工作区；
* 工作区从 `Spark` 家目录迁到 `/home/Projects`；
* `Spark` 侧：原位置改成**指向工作区的软链接**（保持老配置路径可用）；
* `dsh` 侧：`~/Projects → /home/Projects` 软链接；
* `/home/Projects` 用 **POSIX ACL** 授权，避免依赖"属主"来决定谁能写。

最终要达到的不变量（这是整个方案的核心）：

> **在工作区里，无论谁新建文件，另一方都必须仍然可读可写。**

要做到这一点，只靠 `chmod` 不够，必须同时用上 **setgid 目录 + 默认 ACL**，原因见第 5.2 节。

---

## 2. 实测现状

> 本节数据来自**迁移之后**的当前系统状态（2026-10-02）。`dsh` 用户、`agent` 组、`/home/Projects`
> 和你执行的 `setfacl` 都已在位；因此下面的问题**不是新建用户时的错误**，而是"迁移只做了一半"——
> 工作区里的历史文件还没跟着改。

### 2.1 用户与组

```console
$ getent passwd Spark SPark dsh
Spark:x:1000:998::/home/Spark:/usr/bin/zsh
SPark:x:1001:1003::/home/SPark:/usr/bin/zsh      # ← 注意：大小写不同的另一个老账号
dsh:x:1002:1005::/home/dsh:/usr/bin/zsh

$ getent group 998 1005 1006
wheel:x:998:SPark,dsh,Spark
dsh:x:1005:
agent:x:1006:Spark,dsh
```

| 用户 | UID | 主组 | 附加组 | Shell | 家目录 |
| --- | --- | --- | --- | --- | --- |
| `Spark` | 1000 | `wheel`(998) | `agent`(1006) | `/usr/bin/zsh` | `/home/Spark` |
| `dsh` | 1002 | `dsh`(1005) | `agent`(1006)、`wheel`(998) | `/usr/bin/zsh` | `/home/dsh` |
| `SPark` | 1001 | 1003 | — | `/usr/bin/zsh` | `/home/SPark` |

> ⚠️ **坑**：本机同时存在 `Spark`(1000)、`SPark`(1001)，以及 `/home/PILIHU → /home/Spark` 这个软链接。
> 写脚本、写 sudoers、`chown` 时务必区分大小写，`sudo chown -R spark:...` 这种写法会直接失败或改错对象。

### 2.2 目录与权限实测

```console
$ ls -ldn /home/Projects /home/Projects/Stow-Dotfile /home/Projects/Stow-Dotfile/.git
drwxrwxr-x+ 1 1000 998   34 /home/Projects
drwxrwx---  1 1000 998  504 /home/Projects/Stow-Dotfile
drwxrwxr-x  1 1000 998  166 /home/Projects/Stow-Dotfile/.git

$ getfacl -p /home/Projects
# file: /home/Projects
# owner: Spark
# group: root
user::rwx
group::rwx
group:agent:rwx
mask::rwx
other::r-x
default:user::rwx
default:group::rwx
default:group:agent:rwx
default:mask::rwx
default:other::r-x
```

**仓库内部统计（`find` 实测，1959 个对象）**：

| 类型 | 权限 | 数量 | 说明 |
| --- | --- | --- | --- |
| 目录 | `755` | 504 | 组只有 `r-x` → **不可写** |
| 目录 | `750` | 36 | 组只有 `r-x` → **不可写** |
| 目录 | `770` | 1 | 仓库根目录，组可写 |
| 文件 | `644` | 715 | 组不可写 |
| 文件 | `444` | 290 | 组不可写，只读 |
| 文件 | `755` | 128 | 组不可写 |
| 文件 | `750` | 99 | 组不可写 |
| 文件 | `640` | 24 | 组不可写 |
| 软链接 | `777` | 162 | 链接本身无意义 |

* **属组统计**：`1959` 个对象 **全部**是 `Spark:wheel`，**没有一个是 `agent` 组**。
* **不可写目录**：`540 / 541`（唯一例外是仓库根目录，因为它是 770）。

### 2.3 真实身份下的失败复现

以真实 `dsh` 身份（不经沙箱）执行：

```console
$ touch /home/Projects/Stow-Dotfile/hypr/.probe
touch: cannot touch '/home/Projects/Stow-Dotfile/hypr/.probe': Permission denied   # 755 目录

$ touch /home/Projects/Stow-Dotfile/mako/.probe
touch: cannot touch '/home/Projects/Stow-Dotfile/mako/.probe': Permission denied   # 750 目录

$ touch /home/Projects/Stow-Dotfile/.git/.probe && echo OK
OK                                                                                  # 775 目录，可以写
```

结论很清楚：**问题不在 `.git`，而在整个工作区 540 个 755/750 的普通目录。**

### 2.4 沙箱内的视角（解释那条 `nobody:nobody`）

DSH 执行 shell 命令时会套一层 `bwrap` 沙箱，实测其参数形如：

```console
$ ps -eo user,args | head -1
dsh  bwrap --ro-bind / / --dev /dev --unshare-pid --proc /proc \
     --die-with-parent --tmpfs /tmp \
     --bind /home/Projects/Stow-Dotfile /home/Projects/Stow-Dotfile -- bash -c ...
```

它带来三个后果，全部与"磁盘权限坏了"无关：

1. **`/home` 在沙箱里是只读的**（`--ro-bind / /`），只有工作区被单独 `--bind` 成可写。
   所以沙箱内任何 `chmod/chown` 都是 `Operation not permitted` 或 `EROFS` —— 这是设计使然。
2. **uid/gid 被重映射**。沙箱只映射极窄的 id 范围，磁盘上除"当前身份"以外的所有 uid/gid（`Spark(1000)`、`wheel(998)`、`agent(1006)` …）在沙箱内都会折叠渲染成 `nobody(65534)`；ACL 里的命名组会显示成 `group:4294967295`。
   → 于是 `drwxr-xr-x` 在沙箱里看起来像"`nobody:nobody` 且组无写权限"。
   → 反过来，**权限修好之后沙箱内依然显示 `nobody:nobody`**（例如 `drwxrwsr-x+ nobody:nobody`），但写入会成功。别用 `ls` 的显示判断修复是否生效，要用"能不能写"。真正的修复结果请在**沙箱外**用 `ls -ln` 看。
3. **`git` 认为属主可疑**。沙箱内 euid 是 1002，而仓库被显示成属于 65534，两者不等 → `git` 触发 `detected dubious ownership`。
   真实身份下这条不存在，因为 `/home/dsh/.gitconfig` 里已经有：

```ini
[safe]
	directory = /home/Projects/Stow-Dotfile
```

> 📌 **给后续排障的人**：在 DSH 的 shell 里看到 `nobody:nobody` 时，**不要**据此下结论说磁盘权限坏了；那只是沙箱的 uid 映射。要判断真实权限，用 root/Spark 身份执行 `ls -ln`。

---

## 3. 迁移操作：具体命令 + 为什么这么做

> 下面按"你描述的操作"逐步还原成可直接执行的命令。标 ✅ 的是本机已实测确认的状态，标 📝 的是推荐复现步骤。

### 3.1 新建 `dsh` 用户 ✅

```bash
# 建用户：-m 建家目录，-s 指定 zsh，-G 顺便加入共享组
sudo useradd -m -s /usr/bin/zsh -G agent dsh

# 设置密码（交互式；也可以之后只走 SSH key 不设密码）
sudo passwd dsh
```

**为什么**
* `-m`：DSH 需要可写的 `~/.dsh`、`~/.cache`、`~/.local`；没有家目录会在启动阶段就连环报错。
* `-s /usr/bin/zsh`：与 `Spark` 保持一致，`.zshrc/.zshenv` 才有意义；缺失会导致 harness 里 `$SHELL` 相关的脚本分支走错。
* `-G agent`：这一步决定后面能不能靠"组权限"共享工作区。**如果漏了，后面所有共享都会退化成"只有属主能写"。**

### 3.2 建立 `agent` 共享组，两个用户都加入 ✅

```bash
# 组已存在时 -f 不报错，方便脚本重复执行
sudo groupadd -f agent

sudo usermod -aG agent dsh
sudo usermod -aG agent Spark

# 校验：两个用户都必须列出 agent
getent group agent
id -nG Spark
id -nG dsh
```

**为什么**
* 用**附加组**而不是把主组改成 `agent`：`usermod -aG` 是追加（`-a` 必须写，否则 `-G` 会**覆盖**掉用户原有的所有附加组——这是最经典的误操作）。
* 共享组的意义：文件权限里的"组"位只能匹配一个组。把两个用户放进同一个 `agent`，就可以只用 `g+rw` 表达"我们两个可读写"，而不必动用 `o+rw`（那等于对全机开放）。
* **成员变更对已登录会话不生效**：`usermod -aG` 之后已经打开的 shell 里 `id` 不会变，必须重新登录（或 `newgrp agent`）。`dsh web` 也必须重启，否则它继承的仍是旧的组集合。

### 3.3 把工作区迁到 `/home/Projects` 📝

```bash
# 1) 建容器目录
sudo mkdir -p /home/Projects

# 2) 迁移（示例路径；实际源路径按你的布局替换）
sudo mv /home/Spark/Projects/Stow-Dotfile /home/Projects/
sudo mv /home/Spark/Projects/LaTeX         /home/Projects/

# 3) 属主仍是 Spark（保持最小惊讶），属组统一成交叉组 agent
sudo chown -R Spark:agent /home/Projects

# 4) 递归补组读写：目录 g+rwx（要能进入），文件 g+rw（不动执行位，
#    原本可执行的脚本保持可执行，.conf/.json 不会被误标成可执行）
sudo find /home/Projects -type d -exec chmod g+rwx {} +
sudo find /home/Projects -type f -exec chmod g+rw {} +

# 5) 所有目录加 setgid：今后新建的文件/子目录自动继承 agent 组
sudo find /home/Projects -type d -exec chmod g+s {} +
```

**为什么**
* **不改属主**：`Stow-Dotfile` 原本属于 `Spark`，`git` 也认这个属主；如果 `chown` 成 `dsh`，`Spark` 侧每个仓库都要补 `safe.directory`，改动面大。方案选择"属主不动、用组共享"。
* **为什么把目录和文件分开处理**：`chmod -R g+rwX` 里的 `X` 是"条件执行位"，看着方便，但它的判定依赖文件当前的执行位与 ACL 状态，在**重复执行**时行为不够直观。显式写成"目录 `g+rwx`、文件 `g+rw`"就没有歧义：文件永远不加 `x`，也不会丢掉原有的 `x`。
* `g+rw` 只加"组"的读写，其他用户依然没有任何权限（比 `chmod -R 777` 安全得多）。
* **`setgid` 是共享方案的关键**。没有它时，`dsh` 新建的文件属组是 `dsh`(1005)，`Spark` 既不是属主也不在 `dsh` 组 → 立刻失去写权限，"今天能写、明天不能写"的经典症状。有了 `g+s`，新文件属组一律继承目录的 `agent`。

### 3.4 `/home/Projects` 上的 ACL ✅（你已执行的两条）

```bash
sudo setfacl    -m u::rwx,g:agent:rwx,o::rx /home/Projects
sudo setfacl -d -m u::rwx,g:agent:rwx,o::rx /home/Projects
```

**逐项拆解**

| 片段 | 含义 |
| --- | --- |
| `-m` | **修改访问 ACL**（access ACL），即"现在谁能访问这个目录" |
| `u::rwx` / `g:...:rwx` / `o::rx` | 冒号前为空 = 属主/属组/其他人三类基本项；`g:agent:rwx` = 命名组项 |
| `-d` | 修改**默认 ACL**（default ACL），决定"以后在这个目录里新建的东西继承什么" |
| `mask::rwx`（getfacl 里出现） | ACL 的"有效权限掩码"。命名组项的实际权限 = `条目权限 & mask`。**mask 一被 `chmod` 改小，命名 ACL 就会静默失效**——这是排查 ACL"配置了但不生效"的第一嫌疑点 |

**为什么这两条有效，以及它们的边界**

* 第一、二阶段你确认"两个用户都能访问、不需要 root"，正是因为这两条作用在**已经存在**的 `/home/Projects` 目录上；ACL 里的 `group:agent:rwx` 让 `agent` 组成员（`Spark`、`dsh`）都能进入和创建。
* 但它们**只覆盖 `/home/Projects` 这一层**，不会递归。
* 而默认 ACL 只在**新建**对象时继承，对**已经存在**的对象完全无效。这就是为什么：
  * `LaTeX`、`Stow-Dotfile` 是 `mv` 过来的、早就存在的目录，它们**没有**拿到 `agent` 的 ACL；
  * 于是 `Stow-Dotfile` 停留在 `770 Spark:wheel`（靠 `dsh` 恰好也在 `wheel` 组才勉强能进出根目录），而它下面 540 个 755/750 子目录对 `dsh` 全部只读。
* 结论：**ACL 必须补齐到整棵子树**，这正是修复脚本第 5、6 步要做的事。

**关于 `o::rx` 的安全提醒**

注意一个容易忽略的差别：`/home/Projects` 本身是 `o+rx`（你手工设的），但**仓库 `Stow-Dotfile` 现在是 `other::---`，即"默认不对其他用户开放"**。而脚本默认的 `OTHER_PERMS=rx` 会让目录变成 `775`、**新建文件**（经默认 ACL）变成 `644`，等于把仓库放宽到"其他用户可读"。

如果 `/home/Projects` 里会存放含密钥、token、订阅链接、`~/.ssh/config` 之类内容的 dotfiles，建议保持当前的严格状态：

```bash
sudo OTHER_PERMS=--- bash /home/Projects/Stow-Dotfile/docs/fix-workspace-permissions.sh
```

`---` 不会影响 `Spark` 和 `dsh`（两者都在 `agent` 组里，靠组权限读写），只是把"其他用户"彻底关在门外。**改档只需要重跑脚本**：它会把新档位同时应用到已有对象和新建对象（后者靠默认 ACL 继承），不需要手工 `chmod`。

### 3.5 `Spark` 侧：原位置改为软链接 ✅/📝

思路：内容已经移到 `/home/Projects`，家目录里的老路径改成软链接，程序仍然按老路径读写。

用 **GNU Stow**（本机已有 `/usr/bin/stow`）最省事，因为仓库本身就是 stow 布局（顶层 `hypr/`、`nvim/`、`zsh/` 各是一个 package，包内是 `.config/...`）：

```bash
# --restow：先删旧链接再建，适合反复执行
# -d：stow 目录（仓库根）  -t：目标（家目录）  -n：先 dry-run 看一眼
sudo -u Spark env HOME=/home/Spark \
  stow -d /home/Projects/Stow-Dotfile -t /home/Spark -nv --restow hypr nvim zsh kitty ...

# 确认无误后去掉 -n 真正执行
sudo -u Spark env HOME=/home/Spark \
  stow -d /home/Projects/Stow-Dotfile -t /home/Spark -v --restow hypr nvim zsh kitty ...
```

或者手工建立单个链接：

```bash
sudo -u Spark ln -sfn /home/Projects/Stow-Dotfile/hypr/.config/hypr /home/Spark/.config/hypr
```

**为什么**
* 软链接让"迁移"对上层程序透明：`mpv`、`hyprland`、`zsh` 仍然读 `~/.config/xxx`，不需要改任何配置。
* `ln -sfn` 里的 `-n` 很重要：目标已是"指向目录的软链接"时，没有 `-n` 会把新链接**建到链接目标里面**（变成 `~/.config/hypr/hypr`），是极常见的翻车点。
* 用 `stow` 而非手工 `ln` 的好处：它会自动处理"目录折叠"（能整体链接就不逐文件链接），并且 `-D`/`--restow` 可以干净回滚。

**为什么用 `sudo -u Spark` 而不是直接在 root 下建链接**
`ln` 会在目标目录里写入目录项，属主由执行者决定。用 `sudo -u Spark` 才能保证链接和后续文件都归 `Spark`，不会在你家目录里混进 root 属主的文件。

> ⚠️ `/home/Spark` 是 `700`，`dsh` 无法列出它，所以这一步**必须由 Spark（或 root）执行并核对**。执行后用 Spark 身份验证：
> ```bash
> sudo -u Spark find /home/Spark -maxdepth 3 -type l -lname '*Projects*'
> ```

### 3.6 `dsh` 侧：软链接到家目录 ✅

```bash
sudo -u dsh ln -sfn /home/Projects /home/dsh/Projects
ls -l /home/dsh/Projects
# lrwxrwxrwx 1 dsh dsh 14 ... /home/dsh/Projects -> /home/Projects
```

本机**已存在**这条链接（`/home/dsh/Projects -> /home/Projects`）。

**为什么**
* 让 `dsh` 有一个顺手的短路径 `~/Projects`，同时因为 `.zshrc` 里已经写了 `~/Projects/...` 相关的别名/函数，路径不必改。
* 只链到 `/home/Projects` 这一层，**不再链到 `Stow-Dotfile`**：给工作区留出以后放别的项目（如 `LaTeX`、`deepseek-harness`）的空间。

### 3.7 让两个用户都信任仓库 📝

```bash
for u in Spark dsh; do
  h=$(getent passwd "$u" | cut -d: -f6)
  sudo -u "$u" env HOME="$h" git config --global --add safe.directory /home/Projects/Stow-Dotfile
done
```

**为什么**
`git` 从 2.35.2 起，如果仓库属主与当前用户不一致，会直接拒绝操作并提示 `detected dubious ownership`。这是防"在共享 `/tmp` 里被别人的仓库骗着执行 hook"的安全机制。
本机 `dsh` **已经配置好**了这一条（见 2.4）；如果按 `OWNER=dsh` 的方式把属主改给 `dsh`，那么 `Spark` 侧就必须补这一条。

> 📌 **不要**用 `git config --global --add safe.directory '*'` 图省事——那等于关掉这项保护。

---

## 4. 权限问题根因小结

按"现象 → 真实原因"对照：

| 现象 | 真实原因 | 处理 |
| --- | --- | --- |
| `dsh` 在 `hypr/`、`mako/` 等目录 `EACCES` | 目录 755/750，组无 `w`；`dsh` 非属主 | 修复脚本第 3 步（`chmod g+rwx` 目录 / `g+rw` 文件） |
| `nobody:nobody`、`group:4294967295` | DSH `bwrap` 沙箱的 uid/gid 重映射 | 无需处理，只是显示；判断真权限请用 `ls -ln` |
| `detected dubious ownership` | 沙箱内属主被显示成 65534 | 真实身份无此问题；必要时补 `safe.directory` |
| 无法创建 `index.lock` / `objects` | **误判**。`.git` 是 775 且 `dsh ∈ wheel`，实际可写 | 已验证可写；真正要修的是普通目录 |
| 新建的文件过一阵子别人就不能改了 | 目录没有 `setgid`，且没有默认 ACL，新文件属组跟着创建者走 / 受 `umask` 限制 | 修复脚本第 4、6 步 |
| 已存在的子目录没继承 ACL | 默认 ACL 只对**新建**对象生效 | 修复脚本第 5、6 步（递归补） |
| 搬进来的文件 `dsh` 读不了（如 `Spark:dsh 600`） | 对象自带原 mode 与属组；默认 ACL 只在"在目录内创建"时参与 | 重跑脚本；案例见第 11 节 |
| 目录权限看着没问题，Agent 仍写不进去（`Read-only file system`） | 该路径不在当前会话 workspace 内，沙箱只把 workspace + `/tmp` 挂成可写 | 换工作区（第 11.2 节第 3 点） |
| 沙箱里 `chmod` 报 `Operation not permitted` | 沙箱用 `/` 只读挂载 + 无 `CAP_FOWNER` | 设计使然；修复必须在沙箱外的 root 下做 |

---

## 5. 修复方案

### 5.1 执行

```bash
# 需要 root，会提示输入密码
sudo bash /home/Projects/Stow-Dotfile/docs/fix-workspace-permissions.sh
```

脚本**幂等**，可以反复执行。默认行为：

| 变量 | 默认 | 说明 |
| --- | --- | --- |
| `WORKSPACE` | `/home/Projects` | 工作区根目录 |
| `SHARED_GROUP` | `agent` | 共享组 |
| `OWNER` | `Spark` | 目录属主（**默认不改属主**） |
| `OTHER_PERMS` | `rx` | "其他用户"这一档：`rx` = 目录 `r-x`／普通文件 `r--`；`---` = 完全隔离 |
| `NO_ROOT` | 未设置 | 设为 `1` = **属主模式**：不要求 root、不 `chown`、跳过 `safe.directory`；运行前会校验整棵树是否都归当前用户 |

> **脚本只做三件事**：统一属组、补齐组权限、修正"其他用户"档；顺带写 `safe.directory`。
> 它**不改文件属主**、**不删文件**，且对目录/文件/可执行文件分别用显式权限位，重复执行结果完全一致。

### 5.2 脚本做了什么（逐条解释）

| 步骤 | 命令 | 为什么 |
| --- | --- | --- |
| 0 | `[[ $EUID -eq 0 ]]`、检查组/用户/成员关系 | 把"改到一半才发现用户没进组"提前成启动即报错。**成员检查**尤其重要：不在 `agent` 组里的话，后面 `g+rw` 对他毫无意义 |
| 1 | `chown "$OWNER:$SHARED_GROUP" "$WORKSPACE"`<br>`chmod 2775 "$WORKSPACE"` | 顶层目录统一属组；`2775` 的首位 `2` 是 **setgid**，是"新建内容自动继承共享组"的第一道保障 |
| 1 | `setfacl -m u::rwx,g::rwx,g:agent:rwx,m::rwx,o::rx` | 显式授权共享组，和你手动执行的那条一致 |
| 1 | `setfacl -d -m ...` | 设置默认 ACL，决定"以后新建的东西"继承什么 |
| 2 | `chgrp -R agent "$WORKSPACE"` | 全树属组从 `wheel` 改成 `agent`。`wheel` 是管理员组，把共享文档挂在 `wheel` 上既不合语义，也会让"谁可写"取决于用户是否恰好是管理员 |
| 3 | `find -type d -exec chmod g+rwx`<br>`find -type f -exec chmod g+rw` | 给组补权限。特意分开写：目录必须 `x` 才能进入，文件**永远不加 x**（也不会丢掉原有的 x）。等价于 `chmod -R g+rwX`，但不依赖 `X` 的隐式条件，重复执行结果完全一致 |
| 4 | `find -type d -exec chmod g+s` | 给**目录**补齐 setgid（顶层那条只覆盖了根） |
| 5 | `find -type d/-type f -perm -u+x/! -perm -u+x -exec setfacl -m g::…,g:agent:…,m::…,o::…` | 给已有对象补 ACL：**连 `group::` 与 `mask::` 一起显式给出**。用 `find` 而不是 `setfacl -R` 是为了**不跟随符号链接**。判定"可执行"必须用 `-perm -u+x`（owner 的执行位）而不是 `-perm /111`——后者的口径含 mask，会被上一步的 ACL 状态带偏（见 11.5） |
| 6 | `find -type d -exec setfacl -m d:...` | 给每个目录补默认 ACL。只有目录能带默认 ACL，所以单独用 `find -type d` |
| 7 | `runuser -u "$u" -- env -i HOME=... PATH=... git config --global --add safe.directory` | 以目标用户身份写各自的 `~/.gitconfig`，避免 root 生成 root 属主的配置文件。`env -i` 清空继承变量，防止外部 `GIT_*` 把 git 引到别的路径（见 5.3）；该步失败只告警，不影响权限修复 |

**为什么第 4 步和第 6 步必须同时存在**

这是整个方案里最容易漏、也最值得理解的一点：

* **只加 `setgid`**：新文件属组确实变成 `agent` 了，但**模式位仍由 `umask` 决定**。默认 `umask 022` → 新文件 `644`，组没有 `w` → 另一个用户还是改不了。
* **只加默认 ACL**：新文件的 ACL 里有 `group:agent:rw-`，在**这个目录里**可用；但如果文件被移到没有默认 ACL 的目录，或者进程在某些工具下绕过，就不再保险；而且默认 ACL 不改变目录自身的属组。
* **两者同时存在**才是稳定的：`setgid` 保证属组对，默认 ACL 保证模式位对。

### 5.3 第 7 步踩到的坑：外部 `GIT_*` 变量（已加固）

第一次执行时脚本在第 7 步中止：

```console
== 7. git safe.directory ==
fatal: error reading '/home/dsh/.git'
```

原因：**`git` 的行为会被环境变量劫持**。`GIT_DIR`、`GIT_CONFIG_GLOBAL`、`GIT_CONFIG_SYSTEM`、`GIT_CONFIG_COUNT` 这类变量一旦被继承进来，`git config --global` 就会去读写完全不相干的路径（本例中是 `/home/dsh/.git` 这个**并不存在**的文件）。而脚本是用 `runuser` **原样继承调用者环境**去执行 git 的，所以你在终端里的这类变量会一路带进去。

> 我事后以 root 身份直接复现同一条命令**没有**报错，说明问题出在"执行脚本时那个 shell 的环境"，而不是磁盘状态。
> 也正因如此，这条报错与权限修复无关——第 1–6 步此时**已经全部成功**。

加固做法：让 git 在**干净环境**里运行，并且让这一步"失败不致命"。

```bash
git_as() {   # 清空环境，只保留 HOME / PATH
  local u=$1 home=$2; shift 2
  runuser -u "$u" -- /usr/bin/env -i HOME="$home" PATH=/usr/bin:/bin git "$@"
}
```

三点说明：

* `env -i` 丢弃**全部**继承变量（`GIT_DIR`、`GIT_CONFIG_*`、`GIT_PAGER`、代理变量…），只显式给 `HOME` 和 `PATH`。这是让 `git` 行为可预测的最短路径。
* 第 7 步改为**只告警不中止**：它只写 `safe.directory`（git 的"属主不一致"白名单），与文件权限无关，不该让整个脚本以失败告终。脚本退出码仍为 `0`，并打印可手动执行的命令。
* 这一步本来就是"锦上添花"：`dsh` 的 `safe.directory` 在迁移时就已配好，`Spark` 又是仓库属主；主要收益是覆盖工作区里那 11 个**内嵌** git 仓库（`LaTeX/*`、`hypr/.config/hypr`、`zi-deprecated/...`）。

### 5.4 为什么必须用 root

`dsh` 对这些文件**既不是属主，也没有 `CAP_FOWNER`**：

```console
$ chmod 777 /home/Projects/Stow-Dotfile/.gitignore
chmod: changing permissions of '...': Operation not permitted
```

而 `sudo` 虽然对 `dsh` 开放了 `(ALL:ALL) ALL`，但**需要密码**，NOPASSWD 白名单只有 `pacman/journalctl/dmesg/apt/dnf`：

```console
$ sudo -n true
sudo: a password is required
```

所以：**AI/Agent 无法自行完成这一步**（它在沙箱内运行，`/home` 只读、无 `CAP_FOWNER`，且无法免密 sudo）。这也是为什么这里交付的是"一条你可以在终端里执行的 `sudo` 命令"，而不是替你执行。

---

## 6. 验证

修复后按顺序核对（第 1–3 条任意用户可跑；第 4–6 条需要 root 或对应用户身份）：

```bash
# 1) 顶层目录：应看到 rwxrwsr-x + 带 ACL，属组为 agent
ls -ld  /home/Projects /home/Projects/Stow-Dotfile
getfacl /home/Projects/Stow-Dotfile

# 2) 全树不应再有"组不可写"的目录（期望输出为空）
find /home/Projects -type d ! -perm -g+w

# 3) 不应再有非 agent 属组的对象（期望输出为空）
find /home/Projects ! -group agent

# 注意：不要对整个工作区跑 `find -type f ! -perm -g+w` 然后据此判断失败——
# git 的松散对象本来就是只读的 `-r--r-----`（440），这不是权限坏掉：
#   .git/objects/xx/yyyy…   -r--r-----  dsh  ← 正常
# git 改写对象靠"目录可写 + rename"，从不原地修改这些文件。
# 想查文件的组可写性，请把范围限制在 .git 之外，例如：
#   find /home/Projects -path '*/.git' -prune -o -type f ! -perm -g+w -print

# 4) 交叉写测试：两个用户都能在同一个目录里建/删文件
sudo -u dsh   bash -c 'touch /home/Projects/Stow-Dotfile/docs/.w && rm -f /home/Projects/Stow-Dotfile/docs/.w && echo dsh-ok'
sudo -u Spark bash -c 'touch /home/Projects/Stow-Dotfile/docs/.w && rm -f /home/Projects/Stow-Dotfile/docs/.w && echo Spark-ok'

# 5) 新建文件的继承是否正确（关键！属组必须是 agent，且组带 w）
#    注意：如果你是用 OTHER_PERMS=--- 跑的，期望值是 -rw-rw----+ 1 dsh agent
sudo -u dsh touch /home/Projects/Stow-Dotfile/docs/.inherit
ls -l /home/Projects/Stow-Dotfile/docs/.inherit   # 期望 -rw-rw-r--+ 1 dsh agent
rm -f /home/Projects/Stow-Dotfile/docs/.inherit

# 6) git 在两个身份下都正常
sudo -u dsh   git -C /home/Projects/Stow-Dotfile status --short
sudo -u Spark git -C /home/Projects/Stow-Dotfile status --short

# 7) 最贴近实际的验收：在 DSH 会话（沙箱内）往原本写不进去的目录写文件
touch /home/Projects/Stow-Dotfile/hypr/.probe && rm -f /home/Projects/Stow-Dotfile/hypr/.probe && echo OK
```

第 5 条是**唯一能证明"共享不会随时间退化"的检查**：如果属组不是 `agent`，说明 `setgid` 没生效；如果组没有 `w`，说明默认 ACL 没生效。

第 7 条是**最终验收**：第 1–6 条在沙箱外跑得通，只能说明权限位对；只有在 DSH 的沙箱 shell 里也能写进 `hypr/`、`mako/` 这类目录，才说明"`dsh web` 不再报 `EACCES`"这个目标真的达成了。

> ⚠️ 别用沙箱里的 `ls -l` 判断修好没有——权限修好后沙箱内**照样**显示 `nobody:nobody`。看"能不能写"。

---

## 7. 回滚

修复脚本**不改属主、不删文件**，所以回滚很轻：

```bash
# 1) 属组改回原来的 wheel
sudo chgrp -R wheel /home/Projects

# 2) 去掉本方案加的 setgid
sudo find /home/Projects -type d -exec chmod g-s {} +

# 3) 清掉 ACL（-b 清访问 ACL，-k 清默认 ACL）
#    同样用 find，避免 setfacl -R 跟随符号链接跑到工作区外
sudo find /home/Projects \( -type f -o -type d \) -exec setfacl -b {} +
sudo find /home/Projects -type d -exec setfacl -k {} +
```

`git config --global safe.directory` 的改动可用 `git config --global --unset-all safe.directory <path>` 撤销。

---

## 8. 后续加固与注意事项

1. **`umask 002`**（推荐，双保险）
   在 `Spark` 和 `dsh` 的 `~/.zshrc` 或 `/etc/zsh/zshrc` 里加：
   ```bash
   umask 002
   ```
   默认 `022` 会新建 `644` 文件；`002` 配合 setgid 生成 `664`/`775`。有默认 ACL 时 `umask` 不影响 ACL 的继承结果，但对"在没有默认 ACL 的目录里"新建的文件仍然有效。

2. **`~/.dsh` 现在是 `777`**
   实测 `/home/dsh/.dsh` 是 `drwxrwxrwx dsh:wheel`。它里面有 `.credentials.yaml`、`sessions/`、`logs/`。因为 `/home/dsh` 本身是 `700`，其他用户进不来，所以这不是紧急漏洞，但建议收紧：
   ```bash
   chgrp dsh /home/dsh/.dsh
   chmod 700 /home/dsh/.dsh          # 属主是 dsh，dsh 自己就能改
   ```

3. **`/home/dsh` 下三个 zsh 配置属组是 `root` 且 `.zprofile` 是 `700`**
   ```bash
   chgrp dsh /home/dsh/.zshrc /home/dsh/.zshenv /home/dsh/.zprofile
   chmod 644 /home/dsh/.zshrc /home/dsh/.zshenv /home/dsh/.zprofile
   ```
   属组是 `root` 属于历史遗留（大概率是从 `Spark` 家目录复制时带上来的）。

4. **`/home/Projects` 里嵌着若干独立 git 仓库**（例如 `hypr/.config/hypr/.git`）。
   脚本会一并处理它们的权限与 `safe.directory`。注意顶层 `.gitignore` 已经用 `**/.git/` 把它们排除在主仓库之外，不要误提交。

5. **不要用 root 运行 `dsh web`。**
   如果 harness 以 root 启动，它在工作区里创建的文件就会是 `root` 属主；等它退出、你再用 `dsh`/`Spark` 去写同一个文件时，就会撞回今天的 `EACCES`。永远以 `dsh` 身份启动：
   ```bash
   sudo -u dsh -H bash -lc 'cd /home/Projects/Stow-Dotfile && dsh web'
   ```
   （或配置成 `dsh` 的 user systemd 服务。）

6. **组变更后必须重新登录 / 重启服务。**
   `usermod -aG` 只影响之后建立的会话。改完组后让 `Spark`、`dsh` 各自重新登录，并重启 `dsh web`。

7. **ACL 与 `chmod` 会互相踩。**
   `chmod` 会重算 ACL 的 `mask`，把命名组项"压"下去。以后如果发现"ACL 配了却不生效"，先看 `getfacl` 里的 `mask::` 和 `#effective:`。

8. **写脚本调用 `git` 时，请用 `env -i` 或显式 `unset GIT_*`。**
   `GIT_DIR`、`GIT_CONFIG_GLOBAL`、`GIT_CONFIG_SYSTEM`、`GIT_CONFIG_COUNT`、`GIT_INDEX_FILE` 都是"行为劫持"型变量：继承进来后 `git` 会去操作完全不相干的路径。本次第 7 步的 `fatal: error reading '/home/dsh/.git'` 就是这么来的（见 5.3）。同理，DSH 自身也会把 `GIT_CONFIG_GLOBAL` 之类列进"禁止由外部文件设置"的名单。
   ```bash
   # 可预测的调用方式
   sudo -u dsh env -i HOME=/home/dsh PATH=/usr/bin:/bin git config --global --list
   ```

9. **`OTHER_PERMS` 决定"其他用户"这一档，可以随时切换、重复执行不会叠加。**
   脚本每次都**重新设定**而不是追加，所以先 `rx` 后 `---`，最终就是 `---`；反过来再跑一次 `rx` 就会重新放开。
   它同时作用于**已有对象**（第 5 步）和**新建对象**（第 6 步的默认 ACL）。目录与"可执行文件"给 `r-x`，普通文件给 `r--`，配置文件不会被带上执行位。

10. **会被"重命名式写入"绕过的继承规则（重要，日常最容易踩）。**
    实测对比（同一目录 `docs/`，已设 setgid + 默认 ACL）：

    | 写入方式 | 结果 |
    | --- | --- |
    | 在目录里直接创建（`touch`、重定向、编辑器原地写） | `1002:1006` = `dsh:agent`、`-rw-rw----` —— **继承正确** |
    | "写临时文件再 `rename()` 进目录"（很多编辑器、以及 AI 的文件写入工具） | `1002:1005` = `dsh:dsh`、`-rw-------` —— **继承失效** |

    原因：`setgid` 和默认 ACL 只在**在目录内创建 inode 的那一刻**生效；`rename()` 进来的 inode 保留它在别处创建时的属组和模式。

    后果：如果 AI/编辑器这样写文件，`Spark` 可能连读都读不到（`600`、组 `dsh`）。

    处理：
    ```bash
    # 最省事：重跑一次脚本（幂等，会把属组和权限全部拉回）
    sudo bash /home/Projects/Stow-Dotfile/docs/fix-workspace-permissions.sh
    ```
    或者在 `Spark` 需要读之前，对新增文件单独修一次：
    ```bash
    sudo chgrp -R agent /home/Projects && sudo chmod -R g+rw /home/Projects
    ```

---

## 9. 附：本次会话中"为什么 AI 不能自己修"的技术说明

排查过程中确认的事实（便于以后复现同样的结论）：

```console
# 沙箱内
$ cat /proc/self/uid_map
      1002          0          1          # 内层 1002 ↔ 外层 0
$ grep CapEff /proc/self/status
CapEff:	0000000000000000                 # 没有任何 capability
$ findmnt -T /home
/home  ... btrfs ro,...                    # /home 只读，仅工作区被单独 bind 成 rw
$ chmod 777 .gitignore
chmod: changing permissions of '.gitignore': Operation not permitted
$ chgrp agent .gitignore
chgrp: changing group of '.gitignore': Invalid argument   # gid 1006 未映射进沙箱
```

```console
# 免沙箱（危险模式）下
$ id
uid=1002(dsh) gid=1005(dsh) groups=1005(dsh),998(wheel),1006(agent)
$ ls -ln /home/Projects/Stow-Dotfile | head -3
drwxrwx--- 1 1000 998 ...                  # 真实属主 Spark:wheel
$ sudo -n true
sudo: a password is required               # 无法免密提权
```

三件事同时成立 → 权限修复**只能**由 root 在沙箱外执行：
1. 沙箱里 `/home` 只读、无 capability，`chmod/chown/setfacl` 必然失败；
2. 出沙箱后身份是普通用户 `dsh`，不是这些文件的属主；
3. `dsh` 的 sudo 需要密码（NOPASSWD 白名单里没有 `chmod/chgrp/setfacl`）。

因此交付物是**幂等脚本 + 说明文档**，由你在终端执行一次 `sudo bash …` 即可。

---

## 10. 附：最小修复（急用版）

如果不想跑整个脚本，只要达到"两个用户能互相读写"，这 4 条就够：

```bash
sudo chgrp -R agent /home/Projects
sudo find /home/Projects -type d -exec chmod g+rwx {} +
sudo find /home/Projects -type f -exec chmod g+rw {} +
sudo find /home/Projects -type d -exec chmod g+s {} +
sudo find /home/Projects -type d -exec setfacl -m d:u::rwx,d:g::rwx,d:g:agent:rwx,d:m::rwx,d:o::rx {} +
```

（脚本相比这 5 条，多了前置校验、顶层目录处理、已有对象的命名 ACL、`safe.directory` 同步、`OTHER_PERMS` 档位与验证提示。想要"其他用户完全隔离"就把最后一条的 `d:o::rx` 换成 `d:o::---`，并给已有对象补 `setfacl -m o::---`——也就是直接跑 `sudo OTHER_PERMS=--- bash docs/fix-workspace-permissions.sh`。）

---

## 11. 案例记录：`/home/Projects/Others` 在 `chown` 到 `Spark` 之后 `dsh` 访问不了

### 11.1 现象与实测

"把 `Others` 整个 `chown` 给 `Spark`，`dsh` 就进不去了"。以真实身份逐项核对后，结论是：**目录本身没坏，坏的是搬进来的文件和 DSH 沙箱的可写范围。**

```console
$ find /home/Projects/Others -printf '%u:%g %m %y %p\n'
Spark:agent 2770 d /home/Projects/Others
Spark:agent 2770 d /home/Projects/Others/.android-home
Spark:agent 2750 d /home/Projects/Others/.android-home/.android          # ← 组无 w
Spark:agent 660  f /home/Projects/Others/.android-home/.android/adbkey
Spark:agent 640  f /home/Projects/Others/.android-home/.android/adb_known_hosts.pb  # ← 组只读
Spark:agent 660  f /home/Projects/Others/.ssh-work/known_hosts
Spark:dsh   600  f /home/Projects/Others/Vaultwarden-Android-修复报告.md   # ← dsh 完全读不了

$ touch /home/Projects/Others/.probe && rm -f /home/Projects/Others/.probe
dsh 可写                                     # 目录本身对 dsh 是可读写的
```

| 位置 | 模式 | `dsh` 的实际权限 |
| --- | --- | --- |
| `Others/`、`.android-home/`、`.ssh-work/` | `Spark:agent 2770` + `group:agent:rwx` | ✅ 可进入、可读写、可新建 |
| `.android-home/.android/` | `Spark:agent 2750` | ⚠️ 可进入可读，**不能新建文件** |
| `.android-home/.android/adb_known_hosts.pb` | `Spark:agent 640` | ⚠️ 只读，不能改写 |
| `Vaultwarden-Android-修复报告.md` | **`Spark:dsh 600`** | ❌ **完全不可读** |

### 11.2 三层原因（为什么要分开看）

1. **目录之所以是好的，是默认 ACL 和 setgid 在起作用。**
   `/home/Projects` 自己带 `setgid` + `default:group:agent:rwx`，所以在它里面**新建**的目录（`Others`、`.android-home`、`.ssh-work`）会自动继承 `agent` 组、`rwx` 和 setgid。
   → 所以"`chown` 到 `Spark`"这个动作本身**并不会**破坏这些目录：`chown` 只改属主，不动 ACL。
2. **真正坏掉的是"从别处搬进来、自带 mode 和属组"的对象。**
   默认 ACL 只在**在目录内创建 inode 的那一刻**参与计算；`cp -p`/`mv`/解压进来的文件会把原来的模式位和属组一起带过来：
   * `Vaultwarden-Android-修复报告.md` 是 `600` 且属组还是 `dsh` → 只有 `Spark`（属主）能读，`dsh` 连读都不行；
   * `.android` 是 Android 工具自己用受限掩码建的 `750` → 组只有 `r-x`；
   * `adb_known_hosts.pb` 是 `640` → 组只读。
   同理，程序以 `0600` 回写配置时，内核会用**请求的 mode** 去夹默认 ACL，把 `mask::` 压成 `---`，让 `group:agent:rwx` 变成 `#effective:---`（见第 8 节第 10 条）。
3. **如果你是在 `dsh web` 里"访问不了"，那是另一层：沙箱的可写范围。**
   DSH 的 `bwrap` 沙箱只把 `/tmp` 和**当前会话的 workspace** 挂成可写，其余一律只读。本会话的 workspace 是 `/home/Projects/Stow-Dotfile`，所以：

   ```console
   $ touch /home/Projects/Others/.probe
   touch: cannot touch '...': Read-only file system     # 不是 EACCES，是只读挂载
   ```

   这和文件权限无关，改 `chmod` 也没用。要在 Agent 里读写 `Others`，得把**工作区切到 `/home/Projects`（或 `/home/Projects/Others`）**——这两个已经在你的工作区列表里（`~/.dsh/storages/workspace.json`）：在 Web GUI 里选择对应工作区，或从该目录启动：

   ```bash
   cd /home/Projects && dsh web        # workspace = /home/Projects，Others 随之可写
   cd /home/Projects/Others && dsh web # 只要这一个目录
   ```

### 11.3 修复命令

> **先看 11.4**：`Others` 里的对象都属于 `Spark`，所以**以 `Spark` 身份修复根本不用 `sudo`**。
> 下面这条需要 root 的写法适用于"存在不属于你的文件"（例如 `dsh` 要修 `Spark` 的东西）的情况。

**一条命令即可**（脚本是递归的，`Others` 会被一起处理；它会 `chgrp` 到 `agent`、给目录 `g+rwx`、给文件 `g+rw`、补 setgid 与 ACL）：

```bash
sudo OTHER_PERMS=--- bash /home/Projects/Stow-Dotfile/docs/fix-workspace-permissions.sh
```

如果只想动 `Others` 一处，等价的最小命令是：

```bash
sudo chgrp -R agent /home/Projects/Others
sudo find /home/Projects/Others -type d -exec chmod g+rwx {} +
sudo find /home/Projects/Others -type f -exec chmod g+rw {} +
sudo find /home/Projects/Others -type d -exec chmod g+s {} +
sudo find /home/Projects/Others \( -type d -o -type f -perm -u+x \) \
     -exec setfacl -m g::rwx,g:agent:rwx,m::rwx,o::--- {} +
sudo find /home/Projects/Others -type f ! -perm -u+x \
     -exec setfacl -m g::rw-,g:agent:rw-,m::rw-,o::--- {} +
```

验证（两条都要过）：

```bash
# 1) 真实身份下：任何一项都不该是 "DENY"
sudo -u dsh bash -c 'for p in /home/Projects/Others \
  /home/Projects/Others/.android-home \
  /home/Projects/Others/.android-home/.android \
  "/home/Projects/Others/Vaultwarden-Android-修复报告.md"; do
    [ -r "$p" ] && [ -w "$p" ] && [ -x "$p" ] && echo "OK   $p" || echo "DENY $p"; done'

# 2) 全树不该再有"属组不是 agent"或"组不可写"的对象
find /home/Projects/Others ! -group agent
find /home/Projects/Others -type d ! -perm -g+w
find /home/Projects/Others -type f ! -perm -g+w
```

> 📌 **经验**：以后往 `/home/Projects` 里搬东西时，`cp -a`/`mv`/`rsync -a`/解压**都会保留原 mode 与属组**，搬完重跑一次脚本即可。想少踩坑就用 `cp` 而不用 `cp -p`，或者在搬完后立刻补一次 `chgrp -R agent … && find … -exec chmod g+rw …`。

### 11.4 `Others` 其实**不需要 root**：属主模式修复

`Others` 里所有对象都属于 `Spark`，而 **属主本来就有权 `chmod` / `chgrp` / `setfacl` 自己的文件**。所以正确做法是**以 `Spark` 身份修复，不需要 `sudo`**：

```bash
# 在 Spark 的会话里执行（或在 Spark 的终端里）
cd /home/Projects/Stow-Dotfile

NO_ROOT=1 OWNER=Spark OTHER_PERMS=--- \
  bash docs/fix-workspace-permissions.sh
```

只想修 `Others` 这一个子树：

```bash
NO_ROOT=1 OWNER=Spark OTHER_PERMS=--- WORKSPACE=/home/Projects/Others \
  bash /home/Projects/Stow-Dotfile/docs/fix-workspace-permissions.sh
```

脚本在 `NO_ROOT=1` 时会：
* 跳过 `chown`（不动属主）与 `safe.directory` 同步（那一步才需要 root）；
* 先校验 `WORKSPACE` 整棵树是否都属于当前用户，不属于就直接报错并提示改用 `sudo`，避免"改一半失败"。

**为什么 `dsh` 自己修不了**：`dsh` 既不是这些文件的属主、也没有 `CAP_FOWNER`，`chmod`/`setfacl` 只会得到 `EPERM`；它唯一能用的杠杆是目录的组写权限（能删/建目录项），但那改变不了已有文件的权限位。

#### 只修一个文件（最小操作）

那个 Markdown 打不开的真正原因就是 **mask 被夹成了 `---`**：

```console
$ getfacl -p "/home/Projects/Others/Vaultwarden-Android-修复报告.md"
# owner: Spark
# group: dsh
user::rw-
group::rwx          #effective:---     ← 组是 dsh，但被 mask 判为无效
group:agent:rwx     #effective:---
mask::---           ← 元凶：mask
other::---
```

`mode 600` 的文件在带默认 ACL 的目录里创建/复制时，内核会拿**请求的 mode 去夹继承来的 ACL**，于是 `mask::` 变成 `---`，所有组条目（包括 `group:agent`）全部失效。所以只要把 mask 放开，`dsh` 立刻就能读写（它同时在 `dsh` 和 `agent` 两个组里）：

```bash
# 以属主 Spark 身份，任选一条：
setfacl -m m::rw "/home/Projects/Others/Vaultwarden-Android-修复报告.md"   # 只放开 mask
# 或者更彻底：把属组交给共享组并给组读写
chgrp agent "/home/Projects/Others/Vaultwarden-Android-修复报告.md"
chmod g+rw  "/home/Projects/Others/Vaultwarden-Android-修复报告.md"
```

批量修"刚搬进来的一批文件"（同样以属主身份）：

```bash
chgrp -R agent /home/Projects/Others
find /home/Projects/Others -type d -exec chmod g+rwx {} +
find /home/Projects/Others -type f -exec chmod g+rw {} +
find /home/Projects/Others -type d -exec chmod g+s {} +
find /home/Projects/Others -type d -exec setfacl \
     -m d:u::rwx,d:g::rwx,d:g:agent:rwx,d:m::rwx,d:o::--- {} +
```

> ⚠️ 什么时候才真的需要 root：工作区里**存在不属于你的对象**且你**必须**改它时。属主模式下，别人的对象会被自动跳过（不是报错），所以两个用户各自跑一次就能覆盖全树（见 11.5）。

### 11.5 反向案例：`dsh` 写的文件 `Spark` 打不开（Typora）

**现象**：以 `Spark` 启动 Typora，打开 `/home/Projects/Stow-Dotfile/docs/nvim_ds-lazyvim_doc/` 下的 Markdown，提示无权限。

**实测**：

```console
$ ls -ln /home/Projects/Stow-Dotfile/docs/nvim_ds-lazyvim_doc/
drwxrws---+ Spark agent   108 .
-rw-------+ dsh   dsh   18673 lazyvim-plugins.md     # ← dsh:dsh 600，Spark 读不了
-rw-------+ dsh   dsh    7268 markdown-writing.md    # ← 同上
-rw-rw-r--+ Spark agent 26349 neogit-keymaps.md      # 正常
```

原因是 **Agent 的写文件工具是"写临时文件再 `rename()`"**（第 8 节第 10 条）：新 inode 保留临时文件的 `600` 与属组 `dsh`，既没继承目录的 `setgid`，也没继承默认 ACL。于是 `dsh` 自己写的文档，`Spark` 反而打不开。

**修复**：这些文件属于 `dsh`，而修权限只需要**属主**身份——所以由 `dsh` 跑属主模式即可，**不需要 root**：

```bash
# 在 dsh 的会话里
cd /home/Projects/Stow-Dotfile
NO_ROOT=1 OWNER=dsh OTHER_PERMS=--- WORKSPACE=/home/Projects \
  bash docs/fix-workspace-permissions.sh
```

**推荐的双人免 root 流程**（实测属主分布：`Spark` 2727 个对象 + `dsh` 128 个对象，两边各跑一次就覆盖全树）：

```bash
# Spark 的会话里
NO_ROOT=1 OWNER=Spark OTHER_PERMS=--- WORKSPACE=/home/Projects \
  bash /home/Projects/Stow-Dotfile/docs/fix-workspace-permissions.sh

# dsh 的会话里
NO_ROOT=1 OWNER=dsh   OTHER_PERMS=--- WORKSPACE=/home/Projects \
  bash /home/Projects/Stow-Dotfile/docs/fix-workspace-permissions.sh
```

脚本会**自动跳过不属于当前用户的对象**并给出提示，所以顺序无所谓、重复执行也无副作用。

#### 这次修复时踩到的两个 ACL 坑（脚本已修正）

1. **`setfacl` 会把 mask 抬高，普通文件凭空多出"组可执行"位。**
   文件从目录默认 ACL 继承了 `group::rwx`，而 `setfacl -m g:agent:rw-` 只改命名条目、随后**按所有条目的并集重算 mask** → `mask::rwx` → 模式里的组位变成 `rwx`：

   ```console
   -rw-rwx---+  dsh agent  lazyvim-plugins.md
   user::rw-
   group::rwx              ← 继承自默认 ACL
   group:agent:rwx
   mask::rwx               ← 被 setfacl 抬上来的
   other::---
   ```

   修法：**把 `group::` 和 `mask::` 一起显式写出来**（脚本第 5 步已改成 `g::rw-,g:agent:rw-,m::rw-,o::---`）。

2. **判断"文件是否可执行"不能用 `-perm /111`。**
   在带 ACL 的文件上，模式里的组位就是 **mask**。mask 一旦被抬成 `rwx`，`-perm /111` 就会把普通文件判成"可执行文件"，于是永远走"给 rwx"的分支，**再也修不回来**。必须用 **owner 的执行位 `-perm -u+x`**（对应 ACL 的 `user::`，不受 mask 影响）。

   自查命令（应为空）：

   ```bash
   # 普通文件不该出现"组可执行但没有属主可执行"的畸形组合
   find /home/Projects -type f ! -perm -u+x -perm -g+x
   ```

> 📌 **结论**：`mask` 是这套共享方案里最容易被忽略的变量。凡是"明明 ACL 里写了 `group:agent:rwx` 却还是没权限"或"文件莫名变成可执行"，先 `getfacl` 看 `mask::` 和 `#effective:`；凡是脚本里判断执行位，一律用 `-perm -u+x`。

### 11.6 根因定位：DSH 写文件为什么会产出 `dsh:dsh 600`（Neovim 报错案例）

**现象**（在 `Spark` 会话里打开 Neovim）：

```console
Error in /home/Projects/Stow-Dotfile/nvim_ds-lazyvim/.config/nvim/init.lua:
Failed to load `plugins.snacks`:
cannot open /home/Spark/.config/nvim/lua/plugins/snacks.lua: 权限不够
Failed to load `plugins.trouble`:
cannot open /home/Spark/.config/nvim/lua/plugins/trouble.lua: 权限不够
```

`nvim_ds-lazyvim` 这个 stow 包属于 `Spark`，`~/.config/nvim` 指向它；而这两个文件是 Agent（`dsh`）新写的：

```console
$ ls -ln .../nvim_ds-lazyvim/.config/nvim/lua/plugins/snacks.lua
-rw-------  dsh dsh 4820   snacks.lua      # ← 600 + 属组 dsh，Spark 读不了
```

**根因**：`@deepseek-ai/dsh-fs-local` 的 `writeFileAtomic()` 用"**同目录建 staging 目录 → 写临时文件 → `rename()` 就位**"。本次安装版本（`lib/index.js`）关键片段：

```js
const stagingDir = join(directory, `.${basename}.${pid}.${uuid}.tmpdir`);
await mkdir(stagingDir, { mode: 448 });        // 0o700；此刻还继承了父目录的 setgid + agent 组
await chmod(stagingDir, 448);                  // ← 缺陷①：整位覆盖，setgid 被清掉
handle = await open(tempPath, "wx", 384);      // ← 0o600；所在目录已无 setgid，属组只能取进程 egid(dsh)
await handle.chmod(384);                       // ← 缺陷②：新文件被硬编码成 0600
...
if (mode !== void 0) await handle.chmod(mode); // 只有"覆盖已存在文件"时才恢复原模式
await rename(tempPath, absolutePath);
```

* **缺陷①**：`chmod(stagingDir, 0o700)` 把 staging 目录从父目录继承来的 **setgid 清掉**了。之后在这个目录里创建临时文件，内核只能给它**进程的有效 gid**（`dsh`），拿不到目录属组 `agent`。
  为什么 `chmod` 会清掉 setgid？内核规则是：调用进程**不在该目录的属组里**、又没有该 inode 上的 `CAP_FSETID` 时，写模式位会强制清掉 `S_ISGID`。也就是说，**执行写入的进程不在 `agent` 组里**——最可能的原因是 `dsh web` 启动早于 `usermod -aG agent dsh`，进程持有的是旧的组集合（这也解释了为什么沙箱里的 `bash` 创建文件反而正常：那个进程的组集合里有 `agent`）。
* **缺陷②**：新文件被固定成 `0600`。即使属组修对了，`Spark` 依旧读不到（组位是 `---`）——因为目录的默认 ACL 只能"往下夹"，不能替程序加上权限。

**取证过程**（可复现）：用 Agent 的写文件工具在 `docs/` 里建一个探针文件，然后 `getfacl`：

```console
$ ls -ln docs/.acl-probe.md
-rw-------+ 1 1002 1005 36 .acl-probe.md            # 属组是 dsh
$ getfacl -p docs/.acl-probe.md
user::rw-
group::rwx              #effective:---
group:4294967295:rwx    #effective:---                # ← 这里就是 agent 条目！
mask::---                                            # ← 被 0600 夹成 ---
other::---
```

`group:agent` 条目**确实被继承到了**，说明临时文件就是在目标目录内的 staging 目录里创建的（默认 ACL 继承正常）；但属组是 `dsh`，说明 staging 目录的 setgid 已被清掉。两条线索合起来锁定了缺陷①。

状态对照实验（在同一个 setgid 目录 `docs/`，`2770 dsh:agent` 下）：

| staging 目录 | 创建方式 | 落地文件 |
| --- | --- | --- |
| 保留 setgid（`2770`） | `open(..., 0o660)`，不 chmod | `660 dsh:agent` ✅ 期望结果 |
| setgid 被清（`770`） | `open(..., 0o600)` + `chmod 0600` | `600 dsh:dsh` ❌ 与工具产物一致 |

于是行为固定成：

| 动作 | 结果 |
| --- | --- |
| Agent **新建**文件 | `dsh:dsh 600`（属组和组可读都丢） |
| Agent **改写**已有文件 | 模式被 `mode` 保住，但**属组丢成 `dsh`**（例如 `dsh:dsh 660`） |

**这一条解释了本文档里所有反复出现的症状**（`Others` 的报告文件、`docs/nvim_ds-lazyvim_doc` 的 Markdown、Typora 打不开、Neovim 的 `snacks.lua`/`trouble.lua`……）。

**处置一：立刻修**——文件属主是 `dsh`，不需要 root：

```bash
NO_ROOT=1 OWNER=dsh OTHER_PERMS=--- WORKSPACE=/home/Projects \
  bash /home/Projects/Stow-Dotfile/docs/fix-workspace-permissions.sh
```

**处置二：给 DSH 打补丁（根治，本次交付了脚本）。** 需要 root（目标是 `/usr/lib/node_modules/…`），而且**升级 DSH 会覆盖**：

```bash
sudo bash /home/Projects/Stow-Dotfile/docs/patch-dsh-fs-local.sh          # 打补丁
sudo bash /home/Projects/Stow-Dotfile/docs/patch-dsh-fs-local.sh --check  # 只看状态
sudo bash /home/Projects/Stow-Dotfile/docs/patch-dsh-fs-local.sh --revert # 回滚
```

脚本做的事（幂等、自动备份、`node --check` 校验失败自动回滚）：

```diff
 		await mkdir(stagingDir, { mode: 448 });
 		stagingCreated = true;
-		await chmod(stagingDir, 448);
-		handle = await open(tempPath, "wx", 384);
-		await handle.chmod(384);
+		// 不再 chmod stagingDir：进程不在目录属组时会清掉继承来的 S_ISGID
+		const sharedDir = (((await stat(directory)).mode) & 0o2000) !== 0;
+		const tempMode = sharedDir ? 0o660 : 0o600;
+		handle = await open(tempPath, "wx", tempMode);
+		if (!sharedDir) await handle.chmod(0o600);
 		if (platform === "win32" && mode !== void 0) await copyFileDacl(absolutePath, tempPath);
```

> 安全取舍：补丁**只在目标目录带 setgid（＝共享目录约定）时**才用 `0o660` 并让默认 ACL/umask 决定最终权限；普通目录继续沿用原来的 `0600` 私有默认，不影响其他地方的安全语义。

**处置三（可选）：装"安全网"定时任务。** 每个账号只需要修**自己拥有**的对象，所以完全不需要 root。以 `dsh` 的 user timer 为例（每 2 分钟归一化一次）：

```bash
mkdir -p ~/.config/systemd/user
cat > ~/.config/systemd/user/dsh-workspace-perms.service <<'EOF'
[Unit]
Description=Normalize /home/Projects group ownership for dsh-owned files
[Service]
Type=oneshot
Environment=NO_ROOT=1 OWNER=dsh OTHER_PERMS=---
ExecStart=/usr/bin/bash /home/Projects/Stow-Dotfile/docs/fix-workspace-permissions.sh
EOF
cat > ~/.config/systemd/user/dsh-workspace-perms.timer <<'EOF'
[Unit]
Description=Run workspace permission normalizer every 2 minutes
[Timer]
OnBootSec=1min
OnUnitActiveSec=2min
[Install]
WantedBy=timers.target
EOF
systemctl --user daemon-reload
systemctl --user enable --now dsh-workspace-perms.timer
```

`Spark` 侧同理（把 `OWNER=dsh` 换成 `OWNER=Spark`，服务名换掉）。这样即使 DSH 再写坏，也会在 2 分钟内自动恢复，Neovim/Typora 不会再报错。

**自查命令**（三条都应为 `0`）：

```bash
find /home/Projects -user dsh ! -group agent            # dsh 的文件属组是否都归 agent
find /home/Projects -user dsh ! -perm -g+r              # dsh 的文件是否都对组可读
find /home/Projects -type f ! -user Spark ! -group agent ! -group wheel ! -perm -o+r
```

### 11.7 为什么 `umask` 解决不了这个问题（含实测）

**`umask` 是什么**：它不是"设置文件权限"的命令，而是一个**进程级掩码**。创建文件/目录时内核按

```
最终权限 = 请求的 mode & ~umask
```

计算。所以它**只会做减法**，永远加不上任何权限位；它是 shell 内建命令，改的是当前进程（及其后 fork/exec 的子进程）的掩码，对**已存在**的文件毫无影响。

**实测（本机）**：

```console
$ umask
0022

# ① 只会减，不会加
umask 000 → 666      umask 022 → 644      umask 077 → 600

# ② 0022 恰好会把"组写"去掉，与共享目标相反
umask 000 → 666      umask 002 → 664      umask 022 → 644
                     ↑ 共享场景想要的     ↑ 组写被拿掉

# ③ 显式 chmod 完全无视 umask
umask 000 + chmod 600 → 600

# ④ 目录带默认 ACL 时，umask 直接被忽略（/home/Projects 正是这种情况）
umask 000/002/022/077 → 全是 660

# ⑤ 属组由 setgid 决定，和 umask 无关
umask 000 → 660 dsh:agent    umask 077 → 660 dsh:agent
```

**结论：不能，而且 `umask 0022` 方向是反的。** 三条理由：

1. **本 bug 的两个症状都不归 umask 管。**
   * *模式*：DSH 是 `open(..., 0o600)` 之后又显式 `chmod(0o600)`，实测 ③ 表明**显式 `chmod` 无视 umask**；而且 POSIX 里"创建时请求的 mode 是权限上限"，ACL 与 umask 都只能往下夹——只要程序请求 `0600`，任何外部设置都救不回来。
   * *属组*：那是 `setgid` 继承 / `chmod` 清 `S_ISGID` 的问题（实测 ⑤），umask 根本不参与。
2. **工作区里 umask 本来就被忽略**（实测 ④）：`/home/Projects` 的目录都带 `default:` ACL，POSIX 规定此时由默认 ACL 决定，umask 失效——改成 `0022` 也不会改变任何东西。
3. **`0022` 是"收紧"而不是"共享"**：真要设，共享目录该用 **`002`**（→ `664`/`775`），它只在"没有默认 ACL 的目录"里对新文件起作用，属于锦上添花，不是解药。

**那么最优解是什么**

按"能不能真正保证不变量"排序：

| 层次 | 手段 | 能修什么 | 代价 |
| --- | --- | --- | --- |
| ① 创作者（唯一治本） | `docs/patch-dsh-fs-local.sh` | 属组 + 新文件组可读，**同时**修掉 | 需 root；升级 DSH 被覆盖 |
| ② 环境 | 让 `dsh web` 带着 `agent` 组重启（`usermod -aG` 对已运行进程无效） | 只修属组那一半 | 免费，但不足以单独解决问题 |
| ③ 兜底 | user timer 归一化（11.6 处置三） | 事后修复**任何**来源的权限漂移 | 有最长几分钟的窗口；零侵入 |
| ④ 习惯 | `umask 002`（配 setgid）；`Spark`/`dsh` 各自重登 | 只在无默认 ACL 的目录里有效 | 与本 bug 无关 |

**最优组合**：① + ②（+ ③ 如果还有别的程序会写坏）。④ 可以有，但请不要指望它解决这个问题。

> 上游最干净的修法是让 DSH 提供"新文件权限策略"（或按目标目录的属组/默认 ACL 语义创建）。`docs/patch-dsh-fs-local.sh` 就是这个思路的最小实现，本次取证（探针文件 ACL + 状态对照实验）可以直接作为报给上游的依据。
