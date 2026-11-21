# audiosnoop：定位「哪个软件在什么时候播放了声音」

> 目标：电脑偶尔冒出陌生提示音时，能在一分钟内查出是哪个进程、哪个窗口、哪条
> systemd unit 放出来的，而不是靠逐个关应用去猜。
>
> 实现：`audiosnoop`（单文件 Python，仅用标准库）常驻后台，把每次「新建音频流」和
> 每次「真的出了声」都写进 SQLite，配合 `watch` / `log` / `stats` 查询。

## 1. 为什么不能只看音频流

PulseAudio 与 PipeWire 都能通过 `pactl subscribe` 告诉你「有人新建了 sink-input」，
但这条信息在本机上并不可靠：

- Firefox 常年挂着 3 条以上的 sink-input（网页、音乐、视频各一条），其中多数时间是
  静音的——「有流」不代表「在响」；
- 反过来，长驻流复用播放提示音时不会产生新流——「没新流」也不代表「没人出声」。

所以本工具同时采集两个互不依赖的证据源：

| 证据源 | 手段 | 回答的问题 |
| --- | --- | --- |
| 流生命周期 | `pactl subscribe` + `pactl -f json list sink-inputs` | 谁在什么时候建了流、媒体名是什么、属于哪个进程/unit |
| 输出电平 | `parec` 抓默认输出的 `.monitor`，20ms/帧算 RMS→dBFS | 什么时候真的听到了声音、响了多久、峰值多大 |

再用时间把两者对上：**出声前 3 秒内新建的流**几乎必然是声源（提示音、通知音、
游戏音效基本都是「临时建一条流、播完就销毁」）。

## 2. 实现结构

```
audiosnoop run
├── StreamTracker 线程
│   ├── pactl subscribe（stdbuf -oL 保证实时，断线自动重连）
│   └── refresh_streams()：JSON 快照 → diff → 新建/改名/结束
│         └── proc_metadata()：/proc/<pid>/{exe,cmdline,cgroup,environ}
│         └── WindowMapper：hyprctl -j clients ⇒ 窗口 class / title
├── AudioMonitor 线程
│   ├── parec --device=<默认 sink>.monitor --format=s16le --latency-msec=25
│   ├── 20ms 帧 → dBFS → 滞回状态机（起音/收音/合并间隙）
│   ├── 片段落库（先写行再滚动更新，长音频也实时可见）
│   └── 片段音频可选落盘（前摇 3s + 本体，最多 15s）
└── 归因：sounds.app / sounds.confidence / streams.audible
```

关键设计取舍：

- **阈值用滞回**（起音 −50 dBFS、收音 −58 dBFS）：单纯用单阈值会在语音/音乐的
  音节间隙里切出大量碎片。monitor 的静音是数字化的 −120 dBFS，因此 −50 足够灵敏
  又不会误报。
- **片段先入库后更新**：响动持续超过 40ms 就先插入一行，之后每 2 秒刷新时长与峰值，
  这样即使在放一小时音乐，也不会「等它结束才有记录」，进程被杀也只丢最后两秒。
- **归因在片段开始时就定下来**：长片段中间冒出的新流不会把归因改写到最后一个流上
  （这是实测踩过的坑：10 秒的音乐片段最后被归给了末尾 0.5 秒的提示音）。
- **每条新流单独判定一次有声**（`streams.audible`）：起流后 1.5 秒内的峰值超过起音
  阈值就标记。正在放音乐时偶发提示音会被并进同一段出声片段，此时这条依据更可靠。

## 3. 数据模型

`~/.local/share/audiosnoop/audiosnoop.db`（SQLite，WAL）：

`streams` — 每条 sink-input 一行

| 列 | 含义 |
| --- | --- |
| `key` | `index:object.serial`，防止 PipeWire 复用 index 造成串号 |
| `ts_start` / `ts_end` | 流出现/消失时间（unix 秒） |
| `app` / `binary` / `pid` / `exe` / `cmdline` | 应用名、二进制名、PID、真实可执行文件、完整命令行 |
| `unit` / `flatpak` | cgroup 里的 systemd unit/scope、Flatpak/Snap ID |
| `win_class` / `win_title` | Hyprland 窗口类名与标题 |
| `media_name` | 媒体名，常是网页标题、歌曲名、甚至音效文件路径 |
| `props` | 完整 pulse 属性 JSON（取证用，含 `client.api`、`node.name` 等） |
| `audible` / `audible_peak_db` / `audible_at` | 这条流是否真的发出了声音、峰值、判定时间 |
| `clip` | 若本次出声归因到这条流，对应的 WAV 路径 |

`sounds` — 每段「有声片段」一行

| 列 | 含义 |
| --- | --- |
| `ts_start` / `ts_end` / `duration` | 出声起止与时长 |
| `peak_db` | 片段峰值（dBFS） |
| `app` / `confidence` | 归因应用与置信度（`new`/`single`/`app-only`/`unknown`） |
| `stream_id` | 归因到的 `streams.id` |
| `candidates` | 当时的全部候选流（JSON），归因存疑时用它人工判断 |
| `clip` | 片段 WAV 路径（开启 `capture_clips` 时） |

## 4. 安装

```bash
# 1) 建立软链（仓库根目录执行）
stow -d . -t ~ audiosnoop

# 2) 启动并设为图形会话自启
systemctl --user daemon-reload
systemctl --user enable --now audiosnoop.service

# 3) 验证
audiosnoop doctor
audiosnoop selftest
```

`audiosnoop` 包会部署到以下位置：

| 包内路径 | 部署到 |
| --- | --- |
| `.local/bin/audiosnoop` | `~/.local/bin/audiosnoop`（可执行） |
| `.config/audiosnoop/{config.json,README.md}` | `~/.config/audiosnoop/` |
| `.config/systemd/user/audiosnoop.service` | `~/.config/systemd/user/audiosnoop.service` |
| `.config/systemd/user/hyprland-autostart.target.wants/audiosnoop.service` | 指向上一行的相对软链（启用入口） |

依赖只有 `pulseaudio-utils`（`pactl`/`parec`/`paplay`，Arch 上通常已随桌面安装）
与 Python 3.9+；`hyprctl`、`notify-send` 为可选增强。

## 5. 日常使用

```bash
audiosnoop watch                                  # 实时流：一边用一边看
audiosnoop watch --since 10m                      # 先回放 10 分钟再跟随
audiosnoop log --since 15m                        # 全部记录（流 + 出声）
audiosnoop log --kind sound --since 1h            # 只看「出声」
audiosnoop log --kind stream --audible --since 5m # 只看「真的响了」的新流
audiosnoop log --app Firefox --grep 哔哩          # 组合过滤（正则）
audiosnoop log --since '2026-11-20 21:00' --json  # 精确时间窗 + 全量 JSON
audiosnoop stats --since 7d                       # 谁最吵
audiosnoop stats --kind stream --audible          # 按「有声的流」统计
```

时间参数接受 `30s`、`10m`、`2h`、`7d`、`2026-11-20`、`2026-11-20 21:30`、
`21:30`（当天，若已过则取昨天）。

### 排查陌生音效的标准动作

1. 听到怪声 → `audiosnoop log --since 3m --kind stream --audible`；
2. 关注最上面那行的 `应用`、`PID`、`内容`。`内容` 若是 `.oga`/`.wav` 路径，基本就是
   系统音效文件；若是网页标题，则是浏览器某个标签页；
3. `audiosnoop log --since 3m --json` 取该流的 `props`/`cmdline`/`unit`，据此定位到
   具体进程、systemd 服务或 Flatpak 应用；
4. 需要听辨具体是哪一声时，临时打开片段保存：

   ```bash
   systemctl --user edit audiosnoop.service   # 在 [Service] 里加：
   # ExecStart=
   # ExecStart=%h/.local/bin/audiosnoop run --clips
   systemctl --user restart audiosnoop.service
   paplay /usr/share/sounds/freedesktop/stereo/bell.oga   # 先自己放一声校验
   ```

   之后每段出声都会在 `~/.local/share/audiosnoop/clips/` 留下 `<时间>-<应用>.wav`
   （含 3 秒前摇，能听到「响之前」的上下文）。

## 6. 配置

`~/.config/audiosnoop/config.json`，只写需要改的键；`_` 开头的键会被忽略（可当注释）。

| 键 | 默认 | 说明 |
| --- | --- | --- |
| `db_path` | `null` | 数据库路径；`null` 用 XDG 默认位置 |
| `clips_dir` | `null` | 片段目录；`null` 用 `~/.local/share/audiosnoop/clips` |
| `capture_clips` | `false` | 是否保存出声片段 WAV |
| `clip_preroll_sec` | `3.0` | 片段前摇长度 |
| `clip_tail_sec` | `0.8` | 片段尾部余量（实际受 `merge_gap_sec` 约束） |
| `clip_max_sec` | `15.0` | 单段片段最长秒数 |
| `sample_rate` / `channels` / `frame_ms` | `48000` / `2` / `20` | 采样参数 |
| `start_db` | `-50.0` | 起音阈值（高于它开始记录） |
| `stop_db` | `-58.0` | 收音阈值（低于它累计静音） |
| `min_burst_sec` | `0.04` | 短于此的响动丢弃（40ms 仍能覆盖最短的通知音） |
| `merge_gap_sec` | `0.45` | 间隙短于此的响动合并 |
| `attribution_window_sec` | `3.0` | 「新建流」判定窗口 |
| `audible_window_sec` | `1.5` | 新流「是否有声」的观察窗口 |
| `notify` | `false` | 新流出现时弹桌面通知 |
| `notify_sound_too` | `false` | 每次出声也弹通知（更吵） |
| `retention_days` | `30` | 保留天数，`<=0` 永久保留 |
| `poll_interval_sec` | `1.0` | 事件之外的兜底轮询间隔 |
| `sink` | `null` | 监听的 sink；`null` 跟随默认输出 |
| `use_hyprctl` | `true` | 用 hyprctl 补窗口标题 |

### 调阈值

默认值在「安静环境 + 80% 音量」下可用。若漏记：

```bash
# 看真实峰值分布（峰值列就是 dBFS）
audiosnoop log --kind sound --since 1h --json | jq -r '.[].peak_db' | sort -n | head
```

- 漏掉很轻的提示音 → 把 `start_db` 降到 `-55`、`stop_db` 降到 `-63`；
- 误报太多（录音底噪、电流声）→ 把 `start_db` 提到 `-42`，并适当加大 `min_burst_sec`；
- 语音被切成碎片 → 加大 `merge_gap_sec`（如 `0.8`）。

改完 `systemctl --user restart audiosnoop.service`，再用 `audiosnoop selftest` 校验。

## 7. 故障排查

| 现象 | 处理 |
| --- | --- |
| `doctor` 报 monitor 不存在 | `pactl list short sources \| grep monitor`；确认输出设备没被切成 HDMI/蓝牙且已连接 |
| `selftest` 播了音但没记录 | `systemctl --user status audiosnoop`；`journalctl --user -u audiosnoop -n 80`；确认库里流记录在增长 |
| 有流记录、没有出声记录 | 音量太小或阈值太高：先用 `parec`/`wpctl` 确认真的有输出，再按上节调阈值 |
| 播放时听得到、库里没有任何流 | 该客户端直连 PipeWire 绕过 `pipewire-pulse`；可临时 `pw-mon` 观察 |
| 服务起不来 | `journalctl --user -u audiosnoop -n 50`；多半是 `~/.local/bin` 不在 PATH 或没 stow |
| 数据库锁住/损坏 | 停服务后 `sqlite3 <db> "PRAGMA integrity_check"`；必要时 `audiosnoop prune --all --yes` 重建 |

## 8. 局限（请先读）

1. **混音不可分**：monitor 是最终混音，几路声音同时响时无法把能量归给某一路，
   只能给出候选列表与置信度；
2. **持续播放会吞掉偶发音效**：音乐/视频正在播放时，提示音被并入同一段出声片段——
   这是物理限制，此时请用 `log --kind stream --audible` 看新建流；
3. **只在新流上归因**：应用复用长驻流播放自己的音效时不会产生新流，只能看到
   「这段时间有声音」，无法精确到该音效；
4. **跨用户/系统级声音**：只记录当前用户会话能看到的流与默认输出设备的 monitor；
   root 或其他用户的声音看不到；
5. **PipeWire 原生客户端**：不经 `pipewire-pulse` 的客户端 `pactl` 不可见；
6. **隐私**：开启 `capture_clips` 会录下默认输出的全部内容（含会议、音乐），片段存本地、
   受 `retention_days` 清理，请自行判断是否开启。

## 9. 卸载

```bash
systemctl --user disable --now audiosnoop.service
stow -d . -t ~ -D audiosnoop
rm -rf ~/.local/share/audiosnoop        # 数据库与片段（可选，保留则以后可复用）
```
