# Fontconfig配置

我创建了三个配置文件，
`./fonts_with_Noto.conf`:使用`Noto Sans`，来自`双猫CC`

`./fonts_with_Harmony_Mono_Noto.conf`:使用`HarmonyOS Sans`显示中文，等宽字体使用`Noto Sans`，在kitty中可以用于显示`Nerd Fonts`图标

`./fonts_wik_Harmony_Mono_Cascadia.conf`:使用`HarmonyOS Sans`显示中文，等宽字体使用`Cascadia Code Mono`(Microsoft)，无法在kitty中可以用于显示`Nerd Fonts`图标

`./fonts_with_Harmony_Mono_Cascadia_NF.conf`:使用`HarmonyOS Sans`显示中文，等宽字体使用`Cascadia Code Mono`(Microsoft)，在kitty中可以用于显示`Nerd Fonts`图标

`./fonts_with_LXGW_Wenkai.conf`:使用`LXGW WenKai Screen`显示中文，等宽字体使用`Noto Sans`，在kitty中可以用于显示`Nerd Fonts`图标

# 注：`fonts_with_Harmony_Mono_Noto.conf`，`fonts_with_Harmony_Mono_Cascadia_NF.conf`，`fonts_wik_Harmony_Mono_Cascadia.conf`貌似均未解决双猫CC中提到的中文引号问题！

# Typora 跟随全局设置

`./conf.d/50-typora-use-global-fonts.conf`：让 Typora（Electron）遵循本目录 `fonts.conf` 的全局设置。

Typora 在自带 CSS 里写死了字体栈（正文要 `Helvetica`/`Arial`、代码要 `Lucida Console`/`Consolas`、界面要 `Segoe UI`/`Verdana`、emoji 要 `Segoe UI Emoji`），不处理的话它只会命中这些字体，全局设置的 `sans-serif`/`serif`/`monospace` 轮不到生效。该文件把 Typora 请求的每个族改写成对应的通用族，再由 `fonts.conf` 展开成全局字体；规则都用 `prgname="Typora"` 限定，只对 Typora 生效，其它程序不受影响。

放在 `conf.d/` 而不是写进 `fonts.conf` 是有意的：fontconfig 先读 `~/.config/fontconfig/conf.d/*.conf`，再读 `~/.config/fontconfig/fonts.conf`，而通用族规则必须在被插入的族之后执行；这样无论启用上面哪个 `fonts_with_*.conf` 变体，本文件都继续有效。部署时别漏掉 `conf.d/`（`stow fontconfig` 会一并带上；手动复制的话要把整个 `conf.d` 目录放过去），然后重启 Typora 生效。

已知限制：github/pixyll/newsprint 主题用 `@font-face` 自带的网页字体（如 github 的 Open Sans）优先于 fontconfig，这些主题正文的**拉丁字母**改不动；中文、emoji、行内代码和界面则会跟随全局设置。

# 等宽字体

当前生效的 `fonts.conf`（即上面 LXGW 变体改过的版本）等宽字体已改为：

* 拉丁/符号：`Iosevka Spark Mono`（自建 Iosevka，装在个人字体目录里，改完记得 `fc-cache -f`）
* 中文：`LXGW WenKai Mono Screen`（霞鹜文楷等宽 屏幕阅读版），并用 `Noto Sans Mono CJK HK/TC/JP/KR` 覆盖 zh-HK/zh-TW/ja/ko，和 sans 的处理保持一致
* 兜底仍是 `Symbols Nerd Font`（图标）与 `Twemoji`（emoji）

顺带把两处引用旧字体的地方一起改了，若只想改 `monospace` 这一处，把这两处还原即可：

* `Source Code` 规则：源字体换成 `Iosevka Spark Mono` + `LXGW WenKai Mono Screen`
* wechat 例外规则：显式要求 `Noto Sans Mono CJK` 的程序也换成 `LXGW WenKai Mono Screen`

等宽中文在 Chromium 系（Typora）里要绕一下：Chromium 对每个 CSS 字体族只取替换后的**首个**字体，再自己判断它是否覆盖该字符，不覆盖才试下一个 CSS 族 —— 所以 `fonts.conf` 里 monospace 链的第 2 项（等宽中文）对它不可见。解决办法是让 Typora 等宽字体栈里靠后的族（`Courier`/`Courier New`/`Andale Mono`/`DejaVu Sans Mono`，它们在内置主题的等宽栈里都排在其他等宽族之后）直接解析成 `LXGW WenKai Mono Screen`：拉丁字母仍由前面的族（`Iosevka Spark Mono`）提供，中文则落到这一族。实测（Chrome headless + Typora 自带主题 CSS，用 pdftohtml 逐段核对）：正文中文 = `LXGW WenKai Screen`，代码块拉丁 = `Iosevka Spark Mono`，代码块中文 = `LXGW WenKai Mono Screen`，emoji = `Twemoji`。

例外：whitey 主题的代码栈（`"Consolas","Menlo","Monaco",monospace,serif`）不含这四个族，它的代码块中文仍是比例版；pixyll/whitey 的**源码模式**栈以 `Courier` 打头，那里的拉丁字母会跟着变成等宽中文。要完全掌控（含自定主题），可在 Typora 主题 CSS 里把 `--monospace` 写成 `"Iosevka Spark Mono", "LXGW WenKai Mono Screen", monospace`。终端/Pango/Qt 这类按字符集回退的程序本来就能用上 monospace 链的第 2 项，不受此限制。

# 网页图标字体（PUA）兜底

Firefox 里有些网页图标（尤其是「加载 / 转圈」spinner）会显示成**方框里带十六进制数字**的豆腐块（如 `F1 10`），而不是图标。这个方框是 Firefox 自己的 missing-glyph 占位符，说明该字符没有任何可用字体。

根因（已按 Gecko 159.0.1 源码 + 无头 Firefox 实测确认）：

* 这类图标是 icon webfont 的 Unicode 私用区（PUA，U+E000–U+F8FF）码位，不是普通 Unicode 字符。普通符号（几何图形、盲文、箭头、emoji 等）系统字体都有覆盖，不受影响。
* Firefox 对 PUA（以及 Unicode 未分配码位）**有意不做系统字体回退**：`gfxTextRun.cpp` 的 `gfxFontGroup::FindFontForChar` 里，PUA 字符会命中 `SkipFontFallbackForChar` 直接返回，不再搜索 pref font / system font（`gfxPlatformFontList::InitializeCodepointsWithNoFonts` 启动时就把 U+E000–F8FF 和补充私用区写进“无字体码位”集合）。官方注释的意思很明确：这类码位只支持“显式指定了字体”的用法。
* 所以：往 sans-serif / serif / monospace 链里加 `Symbols Nerd Font`、`Font Awesome` 之类**没有用**；fontconfig 的 `<test name="charset">` 规则对 Firefox 也**不生效**（Linux 没有实现基于 fontconfig 的逐字符回退）。唯一有效的 fontconfig 手段是**按 CSS 里请求的 font-family 名做替换**，把该族解析到本机码位一致的图标字体。

`./conf.d/60-web-icon-fonts.conf` 做的事：

1. 把本机已装应用自带的图标字体目录加进 fontconfig 的字体搜索路径：
   * `ariang` 包 → `/usr/share/ariang/fonts`（Font Awesome 4）
   * `ventoy-bin` 包 → `/opt/ventoy/WebUI/static/fonts`（Font Awesome 4 / Bootstrap Glyphicons / Ionicons 2）
2. 按 font-family 名映射：`Font Awesome 5/6/7 ...`（含 Brands）→ 本机的 `Font Awesome 7 Free Solid` / `Font Awesome 7 Brands`。
3. 页面 `@font-face` 正常加载时网页字体仍然优先，规则不影响正常页面（已实测：用 data URI 的 @font-face 覆盖同名族后，渲染用的是网页字体）。

已实测（无头 Firefox + 截图对照）：`FontAwesome`、`Font Awesome 4.7`、`Font Awesome 5 Free`、`Font Awesome 6 Free`、`Font Awesome 5 Brands`、`Glyphicons Halflings`、`Ionicons` 下的图标 / spinner 都能正常显示；正文、中文、emoji 显示不变。

fontconfig 层面的限制：

* 如果页面用 `@font-face` 定义了同名 webfont 而字体文件加载失败（CDN 被墙 / 404 / CORS / 拦截插件），Firefox 不会回落到同名系统字体，也不会走 fontconfig 的 family 替换 → 这类页面 fontconfig **修不了**；要修只能用 Firefox 侧的 `userContent.css` 强制字体栈，或装 `Font Control` 一类扩展。
* 本机没有同码位字体的图标集（Material Icons / Material Symbols、Element UI、Ant Design、Bootstrap Icons、Octicons 等）没有做映射：映射过去会显示成**错误的图标**，比豆腐块更糟。
* 依赖 `ariang` / `ventoy-bin` 两个包；缺了对应规则静默失效，不影响其它字体。

补充说明（都实测过，供以后折腾时参考）：

* 普通 Unicode 转圈字符（`◐◓◑◒`、`◜◝◞◟`、`⠋⠙⠹⠸`、`◴◷◶◵`、`↻⟳⥁` 等）和普通 Unicode 符号在 Firefox 里**本来就正常**，不需要额外配置；用无头 Firefox 扫过 U+2000–2BFF、U+3000–33FF、U+1F000–1FAFF，已分配字符全部能显示（剩下的 hexbox 都是 Unicode 未分配码位）。
* 还有一个能让“通用族下的 PUA 图标”显示出来的 hack：用 `<edit mode="prepend_first">` 把 `Symbols Nerd Font` 顶成 sans-serif/serif/monospace 替换列表的第一个族（Firefox 会把 font group 的首字体直接用于该字符，绕过 PUA 检查）。但它会让 Firefox 里**所有网页**的符号、盲文、几何图形字形改成 Nerd Font 的一套（实测不止基线偏移，字形明显不同），还有 `Symbols Nerd Font` 覆盖范围有限的问题，所以**没有默认启用**。只建议用 `prgname="firefox"` 限定作用域、且能接受字形变化时再开。
* Gecko 里相关代码：`gfx/thebes/gfxPlatformFontList.cpp` 的 `InitializeCodepointsWithNoFonts()`（启动即把 U+E000–F8FF 和补充私用区写入“无字体码位”）、`gfx/thebes/gfxTextRun.cpp` 的 `gfxFontGroup::FindFontForChar()`（PUA 字符命中 `SkipFontFallbackForChar` 后直接返回，不做 pref/system 回退）。也就是说这是 Firefox 的设计行为，不是本机字体缺失。

验证：`fc-match 'Font Awesome 5 Free'` 应返回 `Font Awesome 7 Free`（Solid），`fc-match FontAwesome` 应返回 ariang 的 FontAwesome，`fc-match 'SF Pro Icons'` 应返回 `SF Pro Text`；改完重启 Firefox。如需强制重建缓存可 `fc-cache -f`。

# Apple 站点（music.apple.com）的 U+F8FF

`./conf.d/61-apple-web-fonts.conf`：把网页请求的 `SF Pro` / `SF Pro Icons` 两个族名 `assign` 到本机真实存在、且含 U+F8FF 的 `SF Pro Text`。

* 现象：music.apple.com 的「经典摇滚代表作品、 Music 经典摇滚」这类标题里，苹果 logo 显示成 `F8 FF` 豆腐块。
* 根因：站点把 `Apple Music` 替换成 `\uF8FF\u202FMusic`（`index~*.js` 里的 `Cp()`）；页面 html 的字体栈是 `-apple-system,BlinkMacSystemFont,Apple Color Emoji,SF Pro,SF Pro Icons,Helvetica Neue,Helvetica,Arial,sans-serif`，而本机装的是 `SF Pro Text` / `SF Pro Display` / `SF Pro Rounded` —— `SF Pro`、`SF Pro Icons` 都不是真实族名，fontconfig 会把它们模糊匹配到 sans-serif 首族（霞鹜文楷 屏幕阅读版），文楷没有 U+F8FF，于是按上面那条规则变成 hexbox。
* 为什么能修：`SF Pro Text` 含 12 个 PUA 码位（U+F6D5–F6D8、F765、F799–F79B、F79E、F860、F861、F8FF）；`assign` 让 CSS 请求的族名解析到它，Firefox 的“显式指定字体”路径就能画出 U+F8FF。用 `assign` 而非 `prepend` 是为了不让原族名留在族列表里被再次模糊匹配回文楷。
* 实测（无头 Firefox + 站点原样字体栈 + 截图对照）：替换前 `经典摇滚代表作品、[F8 FF] Music 经典摇滚`，替换后正常显示苹果 logo；正文、中文（仍是文楷）、其它站点都不变。
* 不处理 `-apple-system` / `BlinkMacSystemFont`：Firefox 在 Linux 上把它们当 `system-ui` 处理，对这两个族名写规则实测**无效**；所以正文中文仍走 `fonts.conf` 的 `system-ui → sans-serif → 霞鹜文楷`。想让 Apple 站点用苹方/Noto 黑体，只能从 Firefox 侧下手（`userContent.css` 或 `font.name.*` 偏好），不是 fontconfig 的活。
* 局限：本机没有 Apple 的 `SF Pro Icons`，只能拿 `SF Pro Text` 顶，除苹果 logo 之外的 SF Pro Icons 私有图标仍然缺字（不会变成错误图标，只是依旧缺）；`@font-face` 同名加载失败的情况依旧救不了。
* 顺带确认：music.apple.com 的播放三角、随机播放、加入/移出资料库按钮（含“已加入”的 ✓）都是内联 SVG path，**不受字体影响**；`从资料库中删除` 只是该按钮在“已在资料库”状态下的 aria-label，不是字体替换画出来的。证据图：`docs/fontconfig-apple-music-checkmark.png`（✓ 形状与站点 path 对照）、`docs/fontconfig-apple-music-apple-logo-hexbox.png`（修之前的 hexbox）、`docs/fontconfig-apple-music-after-fix.png`（修之后的同一条字体栈）。

# 使用须知

你可以选择一个你喜欢的配置文件，然后放到`.config/fontconfig`文件夹中，重命名为`fonts.conf`。如果你想个性化，可以查看下面的参考资料。可以使用`fontpreview`软件来查看字体名称

# 参考资料

[Arch Linux CN Wiki](https://wiki.archlinuxcn.org/wiki/Fontconfig)\
[双猫CC](https://catcat.cc/post/2021-03-07/)
