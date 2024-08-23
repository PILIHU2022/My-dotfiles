# 该Markdown文档记录了本仓库使用的软件
- WM:hyprland-git<sup>AUR</sup>
- Terminal:kitty<sup>包</sup>
- Shell: zsh<sup>包</sup>
- Editor:neovim<sup>包</sup>
- System Info:neofetch<sup>包</sup>,fastfetch-git<sup>AUR</sup>
- Notification:dunst mako<sup>包</sup>
- Bar:waybar-git<sup>AUR</sup>
- Files Manager:ranger(CLI),thunar<sup>包</sup>
- App Launcher:wofi,rofi<sup>包</sup>
- Audio:\均在Arch Linux官方仓库
    pipewire\
          lib32-pipewire  :32位应用支持\
          wireplumber     :目前唯一推荐的会话管理器\
          pipewire-pulse  :取代 pulseaudio 和 pulseaudio-bluetooth，（使用 pipewire-pulse.server 替换 pulseaudio.server）pactl info 查看 "Server Name:PulseAudio (on PipeWire)" 即成功
          pipewire-audio  :PulseAudio 和 JACK 兼容的服务器实现和 API兼容库来替代它们，处理蓝牙设备连接\
          pipewire-alsa   :取代 ALSA 客户端（如果安装了pulseaudio-alsa ，请移除它）\
          pipewire-jack   :jack 客户端启动支持\
          pipewire-zeroconf   :pipewire 零配置支持（自动配置）\
          alsa-utils :提供alsamixer amixer 工具\
          lib32-libpipewire 1:0.3.70-1\
          libpipewire\
          pipewire-jack\
    playerctl
- Snapshot:grim, slurp, swappy, imv<sup>包</sup>
- Clipboard:cliphist , wl-clip-persist-git, wl-clipboard<sup>?</sup>
- Record Video:obs-studio<sup>包</sup>
