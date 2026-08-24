if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
  cd ${HOME}
  # 设置语言环境为中文
  # export LANG=zh_CN.UTF-8
  # 解决QT程序缩放问题
  # export QT_AUTO_SCREEN_SCALE_FACTOR=1
  # QT使用wayland和gtk
  # export QT_QPA_PLATFORM="wayland;xcb"
  # export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
  # 使用qt5ct软件配置QT程序外观
  # export QT_QPA_PLATFORMTHEME=qt5ct

  # 一些游戏使用wayland
  # export SDL_VIDEODRIVER=wayland
  # 解决java程序启动黑屏错误
  # export _JAVA_AWT_WM_NONEREPARENTING=1
  # GTK后端为 wayland和x11,优先wayland
  # export GDK_BACKEND="wayland,x11"
  #
  # export MOZ_ENABLE_WAYLAND=1 firefox
  #
  # export XDG_SESSION_TYPE=wayland
  # export XDG_SESSION_DESKTOP=Hyprland
  # export XDG_CURRENT_DESKTOP=Hyprland
  # Hyprland
fi

# 启动 wayland 桌面前设置一些环境变量
# function set_wayland_env
# {
#   cd ${HOME}
#   # 设置语言环境为中文
#   export LANG=zh_CN.UTF-8
#   # 解决QT程序缩放问题
#   export QT_AUTO_SCREEN_SCALE_FACTOR=1
#   # QT使用wayland和gtk
#   export QT_QPA_PLATFORM="wayland;xcb"
#   export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
#   # 使用qt5ct软件配置QT程序外观
#   export QT_QPA_PLATFORMTHEME=qt5ct
#
#   # 一些游戏使用wayland
#   export SDL_VIDEODRIVER=wayland
#   # 解决java程序启动黑屏错误
#   export _JAVA_AWT_WM_NONEREPARENTING=1
#   # GTK后端为 wayland和x11,优先wayland
#   export GDK_BACKEND="wayland,x11"
#
# }

# 命令行输入这个命令启动hyprland,可以自定义
# function start_hyprland
# {
#   set_wayland_env
#
#   export XDG_SESSION_TYPE=wayland
#   export XDG_SESSION_DESKTOP=Hyprland
#   export XDG_CURRENT_DESKTOP=Hyprland
# }

if uwsm check may-start; then
    exec uwsm start default
fi
