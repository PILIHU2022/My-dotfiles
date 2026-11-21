# audiosnoop

记录本机「哪个软件在什么时候播放了声音」，用于排查陌生提示音/音效的来源。
面向 PulseAudio 与 PipeWire（含 `pipewire-pulse`）。

## 为什么不能只看音频流

Firefox、Steam、Chromium 会常年挂着若干条空闲 sink-input，「有流」不等于「在响」。
因此本工具分两路取证：

1. **流跟踪**：`pactl subscribe` 捕捉 sink-input 出现/消失/改名，再用
   `pactl -f json list sink-inputs` 补齐 PID、可执行文件、systemd unit、Flatpak ID
   与 Hyprland 窗口标题；
2. **出声检测**：从默认输出的 monitor 源用 `parec` 实时采样，20ms 一帧算 RMS→dBFS，
   用滞回阈值切出真正出声的片段，记录起止时间与峰值（可选存 WAV 片段）。

归因规则（写进 `sounds.confidence`）：`new` = 出声前 3 秒内新建的流（提示音几乎必然
是它）、`single` = 当时只有一条活动流、`app-only` = 多条流但同属一个应用、
`unknown` = 无法区分。此外每条新流都会在起流后 1.5 秒内被独立判定一次「是否真的有
能量」（`streams.audible`）——正在放音乐时这条依据往往比片段归因更可靠。

## 常用命令

```bash
audiosnoop watch                     # 实时滚动：谁建了流、谁出了声
audiosnoop log --since 10m           # 刚才十分钟的音流与出声
audiosnoop log --kind stream --audible --since 5m   # 只列「真的响了」的新流
audiosnoop log --app Firefox --json  # 精确导出
audiosnoop stats --since 7d          # 按应用聚合
audiosnoop doctor                    # 自检（音频服务、monitor、数据库、服务状态）
audiosnoop selftest                  # 播一声已知提示音，验证捕获与归因
audiosnoop prune --days 7 --vacuum   # 清理
```

## 排查陌生音效的推荐流程

1. 听到怪声后立刻执行 `audiosnoop log --since 2m --kind stream --audible`；
2. 看那一行的 `应用`/`PID`/`内容`（媒体名常直接是音效文件路径或网页标题），
   再用 `--json` 取 `props`、`cmdline`、`unit` 定位到具体进程/服务；
3. 需要听辨时开 `capture_clips`（或 `audiosnoop run --clips`），回放
   `~/.local/share/audiosnoop/clips/*.wav`（每段含 3 秒前摇）；
4. 若怀疑是某个应用的自定义音效，用 `audiosnoop log --grep '<关键词>'` 检索。

## 数据与配置

| 内容 | 路径 |
| --- | --- |
| 数据库（SQLite） | `~/.local/share/audiosnoop/audiosnoop.db` |
| 片段 WAV | `~/.local/share/audiosnoop/clips/` |
| 配置 | `~/.config/audiosnoop/config.json`（只写要改的键） |

环境变量 `AUDIOSNOOP_DB`、`AUDIOSNOOP_DATA_DIR`、`AUDIOSNOOP_CONFIG` 可临时覆盖路径。

## 局限

- monitor 是混音后的信号，无法把同一时刻多路声音分离；几条流同时出声时只能给出候选。
- 持续性播放（音乐/视频）会把偶发提示音并入同一段出声片段，此时请用
  `--kind stream --audible` 看新建流。
- 只在**新建** sink-input 上做归因：若某应用复用长驻流播放自己的提示音，不会产生新流，
  只能看到「某段时间有声音」，无法精确到该音效。
- 直接连 PipeWire（不经 `pipewire-pulse`）的原生客户端，`pactl` 看不到其流。
