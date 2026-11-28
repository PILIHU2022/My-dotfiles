# mihomo 配置结构：分组分层、profile 机制与部署

> 主机 `host` ｜ mihomo 1.19.34 (Meta, `with_gvisor`) ｜ 生效路径 `/etc/mihomo/config.yaml`
> 仓库文件 `mihomo/etc/mihomo/config.yaml`（未跟踪，含明文凭据）+ 脱敏件 `config.example.yaml`（跟踪）

## 0. 一句话结论

- **mihomo 没有 "profiles" 这个东西。** 只有单数的 `profile:` 配置节（两个字段：
  `store-selected` / `store-fake-ip`）。`/etc/mihomo/profiles/` 是 GUI 客户端
  （Clash Verge、Mihomo Party、FlClash 之类）的目录约定，**这里的 systemd 服务从头到尾不读它**。
- "独角兽" 不是 profile，而是 **HTTP 订阅代理集**（`proxy-providers`），它的节点缓存落在
  **运行时状态目录** 的 `profile/Dujiaoshou.yaml`（单数，来自 `path:`），不在 `/etc` 下。
- `/etc/mihomo/profiles/` 里的任何 yaml 都不会被自动加载；曾经内联进主配置的内置免费节点已于
  2026-11-14 移除（原因见第 2 节）。

## 1. 为什么"独角兽"等不在 `/etc/mihomo/profiles/`

链路（全部有据可查）：

```
/etc/mihomo/config.yaml            ← 打包/手工放置的「源」
        │  systemd LoadCredential=config.yaml:/etc/mihomo/config.yaml
        ▼
$CREDENTIALS_DIRECTORY/config.yaml
        │  ExecStartPre=/usr/lib/mihomo/start  →  install 到 $STATE_DIRECTORY
        ▼
/var/lib/mihomo/config.yaml        ← 真正被加载的那份（/var/lib/mihomo → private/mihomo）
        │  ExecStart=/usr/bin/mihomo -d $STATE_DIRECTORY
        ▼
mihomo 进程
```

- 单元里 `DynamicUser=yes` + `StateDirectory=mihomo` + `StateDirectoryMode=0700`，
  状态目录实际是 `/var/lib/private/mihomo`（`/var/lib/private` 是 `0700 nobody`，普通用户进不去）。
- 配置里的 provider 是（下面只列独角兽；2026-11-07 新增的「良心云」见 2.5 节）：

  ```yaml
  proxy-providers:
    独角兽:
      type: http
      url: 'https://<机场>/api/v1/client/subscribe?token=<token>'
      path: ./profile/Dujiaoshou.yaml      # ← 相对 -d 目录，不是 /etc
  ```

  所以节点缓存是 **`/var/lib/private/mihomo/profile/Dujiaoshou.yaml`**。
  注意是 `profile/`（单数，我们自己配的路径），和 `/etc/mihomo/profiles/`（复数）毫无关系。
- 验证方式：`strings /usr/bin/mihomo | grep -i profiles` 只命中 tailscale/mieru/pprof 的字符串；
  源码里 `config.go` 只有 `type Profile struct { StoreSelected bool; StoreFakeIP bool }`。
- 另一个证据：`/etc/mihomo/cache.db` 的 mtime 停在 10-30，服务 11-01 重启后没再动过它——
  活动 cache 在状态目录里。

**结论**：在 `/etc/mihomo/profiles/` 里放多少 yaml 都不会生效；mihomo 只会读
`-d` 目录下的 `config.yaml`，以及 `path:` 指向的 provider 缓存。

## 2. 已移除的内置免费节点（GCP，2026-11-14）

早期曾把 `GCP-Free.yaml` 的 `proxies:` 段内联进主配置，节点名 `GCP-Reality-443`
（vless + REALITY，xtls-rprx-vision），并单独成组 `GCP`。没有用 `type: file` 的
provider 直接指向它，是因为 mihomo 1.19 起 provider 的 `path` 必须位于 `-d` 目录或
`SAFE_PATHS` 内：

```text
level=fatal msg="Parse config error: parse proxy provider gcp error:
path is not subpath of home directory or SAFE_PATHS: /etc/mihomo/profiles/GCP-Free.yaml
allowed paths: [<state dir>]"
```

该节点延迟虽低，但会间歇性返回 `REALITY authentication failed`；一旦被 `url-test`
选中，就会造成整条出口时通时断。按维护要求，2026-11-14 已整体删除：`proxies` 条目、
`GCP` 分组、`Proxy` 里的入口，以及 `手动选择` / `自动选择` / `验证自动` /
`其他策略` 的 `exclude-filter` 全部移除。删除后 `grep -R GCP mihomo/etc/mihomo`
应为 0 命中（文档中的本条历史说明除外）。

## 2.5 良心云订阅：UA 嗅探有三档，第三档是「假 YAML」

2026-11-07 接入第二个订阅，provider 名 `良心云`（节点前缀 `[良心云] `），
缓存 `/var/lib/private/mihomo/profile/Liangxin.yaml`。它与独角兽最大的不同还是
**服务端按 User-Agent 嗅探返回格式**，而且比一般机场更刁：同一个 URL 有三种返回，
全部 HTTP 200、Content-Type 都是 `text/html`：

| 请求 UA | 返回 | provider 结果 |
| --- | --- | --- |
| 非 Clash 系（`curl` 默认、`mihomo/1.19.33`、未知 UA） | base64 的 vless 链接列表（8816 B） | http provider 解不出，0 节点 |
| 「通用 Clash」UA（裸 `clash`、`ClashX`、`ClashforWindows`，或 URL 加 `&flag=clash`） | **假 YAML**（24700 B）：5 个 `server=127.0.0.1:65535` 的 ss 占位节点 | 3 个占位节点会混进分组 |
| Clash-Meta/Verge 系（`clash-verge/*`、`ClashMeta`、`clash.meta/*`） | 真 YAML（31665 B）：18 个 vless | 18 → 过滤广告后 16 |

所以 provider 必须显式覆盖：

```yaml
    header:
      User-Agent:
        - 'clash-verge/v2.0.0'
```

三个要点：

1. **`&flag=clash` 是假数据的入口，不是格式开关。** 它返回的 5 个占位 ss 名字含
   「客户端」「代理软件」，仓库原有 `exclude-filter` 只能滤掉含「支持」的 2 个，
   剩下 3 个会真的出现在 `手动选择` / `自动选择` / `其他策略` 里。本配置在
   `exclude-filter` 末尾追加了 `|客户端|代理软件` 兜底（实测 5 个全滤掉，不误伤真实节点）。
2. **mihomo 1.19.33 自己的默认 UA 是 `clash.meta/1.19.33`**（mock server 抓包实测），
   目前正好命中真 YAML 分支——所以不写 header 也能用；但这是服务端嗅探规则的实现细节，
   随时可能收紧，header 必须显式写死，不能依赖。
3. 18 个真节点是 10 个 REALITY/TCP + 6 个 WS/TLS（另 2 条广告），
   `剩余流量：1024 GB` / `套餐到期：2026-12-07` 由 `exclude-filter` 的「剩余」「到期」命中；
   订阅头 `Subscription-Userinfo`（**只有 Clash-YAML 分支才带**）给出 1 TiB / 到期 2026-12-07。

分组接入沿用 `include-all`：16 个节点自动进 `手动选择` / `自动选择` / 地区组。实测
`香港策略` 4、`新加坡策略` 4、`日本策略` 4、`美国策略` 2、`其他策略` 2（英国 2 个）；
`台湾策略` 0（订阅无 TW 节点，该组退化为 COMPATIBLE，属既有行为）。

验证（`-t` 只验语法；节点数要起实例看 API）：

```bash
curl -s http://127.0.0.1:9090/providers/proxies/良心云 | python3 -c \
  'import sys,json; print(len(json.load(sys.stdin)["proxies"]))'   # 期望 16
```

> 已移除的 Test（赔钱机场）订阅是同一类 UA 嗅探（mihomo 自带 UA 拿到 base64、
> Clash UA 才拿到 YAML）；2026-11-07 当天接入后又移除，节点前缀 `[Test] `。

## 3. 分组结构

分层思路取自上游 [HenryChiao/MIHOMO_YAMLS](https://github.com/HenryChiao/MIHOMO_YAMLS)
的 HenryChiao/666OS 系模板，但只取"结构"，没有套用其整份 50+ 组文件（原因见第 4 节）。

```
Proxy（总入口，MATCH 目标）
├── 自动选择        url-test, include-all + FilterAL（全量节点）
├── 手动选择        select,    include-all + FilterAL
├── 故障转移        fallback → 香港自动 / 日本自动 / 新加坡自动 / 美国自动 / 其他策略 / 直连
├── 香港策略/台湾策略/日本策略/新加坡策略/美国策略    select，默认选该地区的「自动」组
├── 其他策略        select，不属上面任何地区的节点（韩国、欧洲、南美…）
└── 直连

GLOBAL（全局模式入口；显式覆盖内置组，默认 Proxy，同时是 yacd 的排序键，见 3.3.1）

服务组（默认都指 Proxy，可单独改指某地区）：
  AI · 流媒体 · 电报 · 微软 · 谷歌 · GitHub · Apple_Service

隐藏层（hidden: true，只在策略组里作为默认项出现）：
  香港自动 · 台湾自动 · 日本自动 · 新加坡自动 · 美国自动 · 验证自动
```

### 3.3.1 yacd 面板顺序 = GLOBAL 的 `proxies` 列表（不是 YAML 顺序）

**2026-11-14 排障**：用户反馈「排版未恢复」——明明 YAML 里 `Proxy` 排第一、`手动选择`
排第二，`https://yacd.askk.cc/#/proxies` 里却是 `AI`、`Apple_Service`、`GitHub`…
把 `Proxy` 挤到倒数第二。原因不在 mihomo，而在 yacd：

```js
// yacd（HaishanHn 版 src/store/proxies.tsx，以及 askk 部署的 Nuxt 版压缩产物）
globalAll = [...GLOBAL.all, 'GLOBAL'];
groupNames = groupNames
  .map(name => [globalAll.indexOf(name), name])   // ← 用「在 GLOBAL.all 里的下标」排序
  .sort((a, b) => a[0] - b[0]);
```

即：**分组的显示顺序由 `GLOBAL` 组的 `all` 列表决定**；不在该列表里的组
`indexOf` 返回 `-1`，会被排到最前面（`AI`/`Apple_Service`/`GitHub` 就是这样被顶上去的），
`GLOBAL` 自己永远排最后。YAML 里 `proxy-groups` 的顺序对面板没有任何影响
（mihomo 只把它当作默认值的顺序）。

**修复**：把想要的顺序写进 `GLOBAL` 的 `proxies:` 列表（`include-all: true` 仍然保留，
追加的节点排在这些组之后）。当前值：

```yaml
  - name: "GLOBAL"
    type: select
    include-all: true
    proxies: [Proxy, 手动选择, 自动选择, 故障转移,
              AI, 流媒体, 电报, 微软, 谷歌, GitHub, Apple_Service, 验证服务,
              香港策略, 台湾策略, 日本策略, 新加坡策略, 美国策略, 其他策略,
              香港自动, 台湾自动, 日本自动, 新加坡自动, 美国自动, 验证自动]
```

实测（真实配置起实例后读 `/proxies`，按上面的 yacd 算法复算）：

```text
 1. Proxy        2. 手动选择     3. 自动选择     4. 故障转移
 5. AI           6. 流媒体       7. 电报         8. 微软
 9. 谷歌        10. GitHub      11. Apple_Service 12. 验证服务
13. 香港策略    14. 台湾策略    15. 日本策略    16. 新加坡策略
17. 美国策略    18. 其他策略    19. 香港自动    20. 台湾自动
21. 日本自动    22. 新加坡自动  23. 美国自动    24. 验证自动    25. GLOBAL
不在 GLOBAL.all 的组：[]      # 没有组被打到 -1
```

> 维护提示：以后要调面板顺序，**改 `GLOBAL.proxies` 的列表顺序**，不要改 YAML 里
> `proxy-groups` 的书写位置（没用）。新增组也要同时加进 `GLOBAL.proxies`，
> 否则它会被 yacd 顶到最前面。若换回原版 yacd（haishanh/yacd）或别的客户端
> （Clash Verge / Mihomo Party），前面几项顺序仍按 GLOBAL，后者一般按 YAML 顺序。

关键点：

| 机制 | 作用 |
| --- | --- |
| `include-all: true` + `filter` 正则 | 新增机场/节点零改动接入；节点名里带地区词就自动归组 |
| `filter` 用的是 Perl 兼容正则（regexp2），支持 `(?=)`/`(?!)` | 正向命中地区 + 反向排除"剩余/到期/官网/客服"等广告节点 |
| 叶子组 `hidden: true` | 共 25 组、其中 6 个 hidden（可见 19 个），测速实现细节不外露 |
| `proxies` 列表顺序 = 默认值 | `Proxy` 默认「手动选择」（首个节点是独角兽新加坡）；`Apple_Service` 默认「直连」；服务组默认「Proxy」 |
| `profile.store-selected: true` | 面板里手选的结果写进 cache.db，重启不回默认值 |
| `unified-delay: true` | 延迟口径统一（握手 + 首字节），避免 url-test 选到"握手快但首包慢"的节点 |
| `tolerance: 50` | 延迟差 50ms 以内不切节点，避免抖动导致反复切换 |

> GCP 免费节点已于 2026-11-14 移除（延迟极低但会间歇性 REALITY 认证失败，见第 2 节）。

## 3.5 国内 AI / Agent 域名走直连（2026-11-14 全量覆盖）

### 3.5.1 为什么需要显式规则

sukka 的 `non_ip/domestic.txt`（884 行）、`direct.txt`（232 行）、`ai.txt`（68 行，
只收 OpenAI / Claude 系）、`global.txt`（1289 行）都不含国产 AI 域名；
Loyalsoldier 的 `direct.txt` 也只有 `+.deepseek.com`、`+.deepseeksvc.com` 两条。
没有规则时的实际行为（部署前抓到的日志，426 条）：

```text
[TCP] dial Proxy (match Match/) 198.18.0.1:50376 --> api.deepseek.com:443 error: ...
```

2026-11-07 又复现了同款问题：`qianwenai.com` 一路落到 `MATCH`：

```text
[TCP] ... --> qianwenai.com:443 match Match using Proxy[[良心云] 🇭🇰香港高速01|BGP|CMCU]
```

当时逐表核对，四张表对 `qianwenai.com` 全部 0 命中，于是当天先补了 11 条
`DOMAIN-SUFFIX,...,DIRECT`（git 历史可查）。但国产 AI / Agent 产品迭代很快
（Trae、MarsCode、扣子、Qoder、CodeGeeX、iFlow…），手工列表追不上，所以
2026-11-14 改成「官方规则集 + 显式兜底」。

### 3.5.2 规则结构（两层 + 例外）

| 层 | 内容 | 位置 |
| --- | --- | --- |
| ① 官方规则集 | `RULE-SET,ai_cn`：MetaCubeX geosite 的 `category-ai-cn`，129 条，上游每天自动构建 | `[3] 国内直连` |
| ② 核心兜底 | 13 条 `DOMAIN-SUFFIX`：DeepSeek / 通义 / Kimi / 智谱 / MiniMax / 海螺 / 百川 / 商汤 / 阶跃 / 零一 | 紧接 ① 之后（不依赖远程拉取成功） |
| ③ 补充 | 14 条 `DOMAIN-SUFFIX`：上游 `ai_cn` 尚未收录、但实测解析到国内 IP 的 | 紧接 ② 之后 |
| 例外 | `qwen.ai` / `qwenlm.ai` / `z.ai` → `AI` 组 | **必须在 ① 之前** |

rule-providers 定义：

```yaml
  ai_cn:
    type: http
    behavior: domain
    format: yaml
    url: 'https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/geosite/category-ai-cn.yaml'
    path: ./rule_set/metacubex/category-ai-cn.yaml
    interval: 86400
    proxy: Proxy
```

**坑**：上游 yaml 是 Clash 的 domain payload 格式（`payload:` 列表，`+.` 前缀表示
后缀匹配），所以必须 `behavior: domain` + `format: yaml`；写成 `format: text`
会解析出 0 条（和 `loyalsoldier_reject` 同一个坑，见 3.6.1）。

### 3.5.3 上游覆盖了什么、没覆盖什么

`category-ai-cn` 实测 129 条，覆盖（`+.` 后缀，含全部子域）：DeepSeek、Kimi /
Moonshot、智谱（bigmodel / chatglm / zhipuai / z.ai）、MiniMax、百川、商汤
（sense* 全家桶）、豆包（doubao* / doubao-dev）、扣子（coze* 全套）、Trae
（trae.cn / trae.com.cn）、MarsCode（marscode.cn / marscode.com.cn）、CodeBuddy、
腾讯元宝 / 混元 / 元器、讯飞星火、文心一言、通义千问（qianwenai.com / qianwen.com
/ tongyi.com）、秘塔、天工、纳米 AI（n.cn）、可灵（klingai）、小浣熊、LiblibAI、
MCP 广场（mcpworld.com）等。

上游**没有**、由 ②③ 手工补的：`stepfun.com` / `stepchat.cn` / `yuewen.cn`
（阶跃系）、`lingyiwanwu.com`（零一）、`codegeex.cn`、`qoder.cn`、`iflow.cn`、
`modelscope.cn`（魔搭）、`siliconflow.cn`（硅基流动）、`xfyun.cn`（讯飞开放平台）、
`modelbest.cn`（面壁）、`mobvoi.com`（出门问问）、`unisound.com`（云知声）、
`emotibot.com`（竹间）、`vidu.com`（生数）、`minimax.chat`（MiniMax 旧 API 域名）。

**已由 domestic 表覆盖、不重复加的**：`tongyi.aliyun.com` / 通义灵码
（← `aliyun.com`）、`dashscope.aliyuncs.com`（← `aliyuncs.com`）、`doubao.com`、
`*.tencent.com`、`*.baidu.com`、千帆（← `baidubce.com`）、火山方舟
（← `volces.com`）、`quark.cn`、`youdao.com`。

**有意不加（境外 IP，直连反而绕远）**：`qwen.ai` / `qwenlm.ai`（阿里云新加坡、
香港）、`z.ai`（智谱海外）、`qoder.com`、`codegeex.com`、`siliconflow.com`、
`minimax.io`。

### 3.5.4 国际版例外的原因（顺序很关键）

`ai_cn` 里同时有 `+.qwen.ai`、`+.qwenlm.ai`、`+.z.ai`——上游把阿里 / 智谱的海外
站点也算进了「CN AI」。这三个域名实测解析到境外（`139.95.x` 阿里云新加坡、
`8.212.x` 阿里云香港、`8.216.x` 阿里云国际），而 sukka `global_non_ip` 里有
`DOMAIN-SUFFIX,ai`，所以原来的行为是「所有 `.ai` 都走代理」。不写例外的话，
`ai_cn` 会把它们一并判成直连；三条例外必须放在 `RULE-SET,ai_cn` **之前**，
指向 `AI` 组。

### 3.5.5 验证（2026-11-14，一次性测试实例）

```text
/providers/rules → ai_cn: behavior=Domain, format=YamlRule, ruleCount=129
https://www.trae.cn      → match RuleSet(ai_cn) using DIRECT
https://chatglm.cn       → match RuleSet(ai_cn) using DIRECT
https://doubao.com       → match RuleSet(ai_cn) using DIRECT
https://liblib.tv        → match RuleSet(ai_cn) using DIRECT
https://qwen.ai          → match DomainSuffix(qwen.ai) using AI[...]   # 例外生效
https://z.ai             → match DomainSuffix(z.ai) using AI[...]
https://example.com      → match Match using Proxy                     # 兜底不变
```

DNS 核对（DoH + 本地 `china_ip` 表，逐个查了上游 129 条）：能解析出 A 记录的
条目里，除 `qwen.ai` / `qwenlm.ai` / `z.ai` 外都落在国内段；另有
`rwkv.com`、`zhipucn.com` 走 Cloudflare（anycast，IP 显示非 CN，服务本身可直连）。
另有部分条目没有 A 记录（这类通常只挂在子域上），不影响后缀匹配。

**关于「通用兜底」**：2026-11-14 之前这里不做 IP 兜底，理由是「每条未匹配连接
都要多一次 DNS 解析、且国内 CDN 域名可能被误判直连」。当天按用户要求补上了兜底，
但用三层设计把代价压住：先 `GEOSITE,cn` 做纯域名判定（不触发解析），只有域名层
全没命中的才由 `GEOIP,CN` 触发一次内部 DoH 解析，且解析查询经代理出口发出。
细节、代价和泄露面分析见 3.11。

> 维护提示：再遇到「某国内 AI / Agent 域名走代理」，先看 `ai_cn` 的缓存
> （`$STATE_DIRECTORY/rule_set/metacubex/category-ai-cn.yaml`）是否已收录；
> 确认漏网后按本节格式补 `DOMAIN-SUFFIX,...,DIRECT`，**不要动 MATCH 兜底**
> （防止 DNS / IP 泄露）。国际版一律指向 `AI` 组，不要直连。

## 3.6 去广告规则集：Loyalsoldier/clash-rules（`reject.txt`）

2026-11-07 引入 [Loyalsoldier/clash-rules](https://github.com/Loyalsoldier/clash-rules) 的
`reject.txt` 作为 skk 拦截表的**补充**。该项目每天北京时间 06:30 用 GitHub Actions 构建，
数据主要来自 `Loyalsoldier/v2ray-rules-dat` 与 `v2fly/domain-list-community`。

先盘了一遍它的 13 个规则集，对照本配置已有能力：

| Loyalsoldier 列表 | 大小 | 本配置是否已覆盖 |
| --- | --- | --- |
| `reject.txt`（广告） | 5.8 MB / 199,133 条 | skk `reject_domainset` 149,448 条与它**只重叠 68%** → 净增 63,364 条，值得加 |
| `direct.txt` / `proxy.txt` / `gfw.txt` | 2.3 MB / 0.6 MB / 95 KB | 已由 skk `direct_non_ip` / `global_non_ip` 覆盖，不重复加 |
| `private.txt` / `lancidr.txt` / `cncidr.txt` | 3.5 KB / 0.5 KB / 212 KB | 已由 skk `lan_*` / `china_ip` / `domestic_ip` 覆盖 |
| `apple.txt` / `icloud.txt` / `google.txt` | 5.4 KB / 1.1 KB / 3.4 KB | 已有 apple 规则与 `Apple_Service` 组；`google.txt` 是「Google 国内可直连」列表，与 `谷歌` 组策略相悖，不加 |
| `tld-not-cn.txt` | 12 KB | 未命中任何规则本来就走 `MATCH → Proxy`，等价，不需要 |
| `telegramcidr.txt` / `applications.txt` | 0.3 KB / 2.8 KB | 已有 telegram 规则；应用列表与 domestic/direct 大量重叠 |

所以只引入 `reject.txt` 这一个。

### 3.6.1 两个坑

1. **release 分支的 `reject.txt` 不是纯文本**，而是 Clash YAML payload：

   ```yaml
   payload:
     - '+.0.avmarket.rs'
   ```

   所以 `behavior` 要写 `domain`、`format` 要写 `yaml`；若照 skk 的写法给
   `format: text` 会解析出 0 条。199,133 条全部带 `+.` 前缀（suffix 匹配，含自身与所有子域）。
2. **URL 选 `raw.githubusercontent.com`**：jsdelivr 地址有 12 小时延迟，本机实测还会
   中途 TLS 中断；mihomo 拉取走 `proxy: Proxy`，raw 源没问题。

### 3.6.2 配置

```yaml
  loyalsoldier_reject:
    type: http
    behavior: domain
    format: yaml
    url: 'https://raw.githubusercontent.com/Loyalsoldier/clash-rules/release/reject.txt'
    path: ./rule_set/loyalsoldier/reject.yaml
    interval: 86400
    proxy: Proxy
```

规则放在 `[1] 广告 / 恶意 / 拦截` 段**最后**（skk 五条拦截规则之后）：

```yaml
  - RULE-SET,loyalsoldier_reject,REJECT
```

放最后是为了让与 skk 重叠的域名保持原有判定（尤其 `reject_non_ip_drop` 的
`REJECT-DROP` 语义），新列表只补 skk 没有的那 63,364 条；两者并集 212,812 个域名。

### 3.6.3 实测

```text
/providers/rules: loyalsoldier_reject  behavior=Domain  ruleCount=199133
请求 doubleclick.net                    → match RuleSet(reject_non_ip)        using REJECT  # skk 旧表先命中
请求 successesservicetrips.com（仅 Loy）→ match RuleSet(loyalsoldier_reject)  using REJECT
请求 freebestgames2025.com（仅 Loy）    → match RuleSet(loyalsoldier_reject)  using REJECT
请求 example.com                        → match Match using Proxy                           # 兜底不变
```

代价：缓存 5.8 MB（每 24h 经代理拉一次）；进程 RSS 实测 **115.2 MB vs 103.5 MB**
（+11.7 MB，199k 域名匹配表）；启动解析略慢。

误杀处理：Loyalsoldier 是社区聚合列表，若正常站点被拦，把 `loyalsoldier_reject` 那条
`RULE-SET` 注释掉，或给具体域名加一条 `DOMAIN-SUFFIX,<domain>,DIRECT` 放到规则最前面。

## 3.7 人机验证（Cloudflare Turnstile）：commandcode.ai「验证失败」

> 2026-11-13 排障。现象：注册/登录 commandcode.ai 时提示验证失败，页面本身能打开。

### 3.7.1 根因

站点用 **better-auth + Cloudflare Turnstile** 做验证：

- `/signup`、`/signin` 预载 `use-turnstile-*.js`，从
  `https://challenges.cloudflare.com/turnstile/v0/api.js?render=explicit` 加载脚本，
  `getToken()` 超时 **8 秒**，超时文案
  `Verification didn't finish in time. Try again, or refresh the page.`（注意
  `/login`、`/sign-in` 都是 404，登录页是 `/signin`）；
- token 以 `x-captcha-response` 头发给 `api.commandcode.ai`，服务端再向
  `challenges.cloudflare.com/turnstile/v0/siteverify` 校验，并把客户端 IP 作为
  `remoteip` 一起提交。

实测（与浏览器相同的 TUN 路径）：机场某新加坡出口（AWS，`13.229.143.80`）访问
`challenges.cloudflare.com` 时，ClientHello 之后被 Cloudflare 直接 EOF：

```text
curl: (35) TLS connect error: error:0A000126:SSL routines::unexpected eof while reading
```

同出口访问 `commandcode.ai` 大多 200、`api.commandcode.ai` 约 3/10 成功——于是
"页面打得开，但验证码加载不出来 / 提交失败"。headless Chrome 复现同样是浏览器网络
错误页；换香港/日本/美国出口后 `challenges .../cdn-cgi/trace` = 200、`api.js` = 302，
Chrome 能正常加载 Turnstile。

关键点：**`commandcode.ai`、`api.commandcode.ai`、`challenges.cloudflare.com`
必须走同一个出口**（better-auth 会用 remoteip 校验 token），且该出口不能被 CF 重置。

### 3.7.2 修复

新增两个组（`验证服务` 可见、`验证自动` 隐藏）与 3 条规则：

```yaml
  - {name: "验证服务", type: select, proxies: [验证自动, 美国策略, 日本策略, 香港策略, 台湾策略, 新加坡策略, 其他策略, 直连, Proxy]}
  - {name: "验证自动", type: url-test, url: 'https://challenges.cloudflare.com/cdn-cgi/trace', interval: 600, tolerance: 100, hidden: true, include-all: true, filter: *FilterAL}
```

规则插在 `[6] AI` 段之后、`[7] 流媒体` 之前：

```yaml
  - DOMAIN-SUFFIX,challenges.cloudflare.com,验证服务
  - DOMAIN-SUFFIX,turnstile.cloudflare.com,验证服务
  - DOMAIN-SUFFIX,commandcode.ai,验证服务
```

`验证自动` 直接用**验证端点本身**做健康检查，只选能真正加载验证码的出口，自动绕开
被 CF reset 的 IP；`tolerance: 100` 避免验证过程中切节点导致 token 失配。`验证服务`
默认指向 `验证自动`，面板里可手动改到某地区策略或 `直连`。

### 3.7.3 实测

```text
# 修复前（出口 13.229.143.80）
challenges.cloudflare.com/turnstile/v0/api.js  0/10
commandcode.ai/signup                          3/5

# 修复后（验证自动 → [独角兽] 澳门，出口 163.53.246.174 / colo=HKG）
challenges.cloudflare.com/turnstile/v0/api.js  10/10（302）
commandcode.ai/signup                          5/5（200）
```

### 3.7.4 怎么查看"具体报错"

浏览器侧（最重要）：

1. F12 → Network，勾 **Preserve log** + **Disable cache**，过滤 `commandcode`；
2. 复现一次，找 `api.commandcode.ai` 的 `sign-in/email` / `sign-up/email` POST：
   - **有** 且 4xx → 看 Response 的 `code`：`TURNSTILE_FAILED` / `MISSING_RESPONSE`
     = 服务端拒了 token；`429` = 限流；
   - **没有** 这条请求 → 前端没拿到 token（Turnstile 根本没跑起来）；
3. 过滤 `challenges.cloudflare.com`：`turnstile/v0/api.js` 应为 200；
   `(failed)/(blocked)` 或耗时 > 8000ms 就是它；
4. Console 里 Turnstile 错误码：`300030`/`600010`（bot 判定）、`200500`（iframe
   加载失败）、`110600`（超时）；页面 toast 与根因的对应关系见 3.7.1；
5. 仍无法定位时：Network 右键 → **Save all as HAR with content**（含邮箱，勿外传）。

mihomo 侧：

```bash
# 实时看命中的规则/链路（PATCH 是热更新，不重启；测完恢复 warning）
curl -s -X PATCH http://127.0.0.1:9090/configs -H 'Content-Type: application/json' -d '{"log-level":"info"}'
curl -N -s 'http://127.0.0.1:9090/logs?level=info' | grep -Ei 'commandcode|challenges'
# 看验证组当前出口
curl -s 'http://127.0.0.1:9090/proxies/%E9%AA%8C%E8%AF%81%E8%87%AA%E5%8A%A8' | jq '{now,history}'
# 两个域名是否同一出口（两行 ip= 必须一样）
curl -s https://commandcode.ai/cdn-cgi/trace | grep -E '^(ip|loc|colo)='
curl -s https://challenges.cloudflare.com/cdn-cgi/trace | grep -E '^(ip|loc|colo)='
```

判定：两个 `ip=` 不同 → 规则/出口不一致；相同但验证仍失败 → 该出口 IP 被 CF 判成
bot（换出口，或临时把 `验证服务` 改到 `直连` 用真实家宽 IP 试）。

## 3.8 yacd 面板（yacd.example.com）开代理打不开（2026-11-14）

现象：开代理后 `https://yacd.example.com/` 长时间转圈、最后 TLS 报错
（`curl: (35) ... unexpected eof while reading`）；切到 direct 模式立刻 200、0.03s。

### 3.8.1 根因：域名规则缺失 + fake-ip 让 IP 规则失效

- `yacd.example.com` → 腾讯云国内 IP（文档中以 `119.29.x.x` 代指）；根域与
  `www` 解析到美国 IP，后两者直连和代理都不通。
- `enhanced-mode: fake-ip` 下，这条连接的目标是假 IP `198.18.0.33`，
  `RULE-SET,china_ip` / `RULE-SET,domestic_ip` 这类 **IP 规则拿不到真实地址**；
  域名表（`domestic_non_ip` / `direct_non_ip` / `global_non_ip`）里又没有该面板域名，
  于是落到 `MATCH → Proxy`，从 `手动选择` 当前的新加坡出口出去，握手被对端 reset。
- 反证——同一条链路只要目标带真实 IP，`china_ip` 本就会判直连：

```text
curl --resolve 'yacd.example.com:443:<国内IP>'   https://yacd.example.com/ → 200, 0.03s
/connections: yacd.example.com <国内IP> -> ['DIRECT'] rule=RuleSet china_ip
curl --resolve 'yacd.example.com:443:<美国IP>'   https://yacd.example.com/ → TLS reset, 10s
```

所以不是线路不通，是规则判定把这条本该直连的连接推给了代理。

### 3.8.2 修复

`[3] 国内直连` 段、`RULE-SET,direct_non_ip` 之后（**必须早于 `RULE-SET,domestic_ip`**）：

```yaml
  - DOMAIN,yacd.example.com,DIRECT              # yacd 面板（腾讯云 119.29.x.x）
```

**为什么是 `DOMAIN` 而不是 `DOMAIN-SUFFIX,<面板根域>`**：根域和 `www` 都在美国且不可达，
按后缀直连会把该根域将来的海外子域一起钉成直连；精确匹配只覆盖面板本身。

**为什么不塞进 `dns.fake-ip-filter`**：那样能靠 `china_ip` 间接直连，但等于把
"能不能打开"押在 `china_ip` 是否收录该网段上（今天收了 119.29 段，改版后可能不收），
显式域名规则是确定性的。

### 3.8.3 验证 / 维护提示

```text
mihomo -t ...              → test is successful；部署重启后 /rules 应为 78
/connections → yacd.example.com ... -> ['DIRECT'] rule=Domain(yacd.example.com)
```

> 维护提示：凡是"自建、解析到国内 IP"的域名，在 fake-ip 模式下都必须显式写域名规则，
> 不能指望 `china_ip` / `domestic_ip` 兜底——那两条只在连接目标是真实 IP 时才生效。
> 顺带：仓库缓存的 `rule_set/sukkaw_ruleset/domestic_ip.txt` 是 sukka 给非 Surge UA 的
> 诱饵表（仅 3 条），该 `RULE-SET` 实际接近空规则，不要把它当直连兜底。

## 3.9 全局模式下 AccuWeather 仍走直连（2026-11-14）

> 2026-11-14 配置改动；部署重启后按 3.9.3 验证，未验证前不要当成已生效。

现象：切到 `mode: global`（`GLOBAL` 当前选 `Proxy`）后，AccuWeather 仍然绕过代理，
mihomo 日志只有 IPv4 的 `using GLOBAL`，看不到它的 IPv6 连接。

### 3.9.1 机制一：TUN 没接管 IPv6

`tun.auto-route` 只安装了 IPv4 路由——TUN 网卡只有 `198.18.0.1/30`，没有 IPv6
地址，也没有 `::/0` 路由；系统 IPv6 默认路由走物理网卡。AccuWeather 的
`api.accuweather.com` / `dataservice.accuweather.com` 都有 AAAA 记录，客户端一旦
走 IPv6 就完全绕过 mihomo，规则和 global 模式都管不到：

```text
$ curl -6 --resolve 'dataservice.accuweather.com:443:[2600:1413:...]' https://dataservice.accuweather.com/
code=404 ip=2600:1413:...        # 通，但 mihomo 日志 0 条记录
```

另外，未配 `fake-ip-range6` 时 mihomo DNS 对 AAAA 直接返回空（NOERROR / 0 条），
系统解析器于是永远只拿到 A；真正拿到 AAAA 的是浏览器自带 DoH 或应用内解析——这条路
恰好最容易被 TUN 漏掉。

修复（`tun:` 与 `dns:` 各加一项）：

```yaml
tun:
  inet6-address: [fdfe:dcba:9876::1/126]
dns:
  fake-ip-range6: 'fdfe:dcba:9877::/64'   # 与 tun 地址不同段
```

### 3.9.2 机制二：内置 GLOBAL 默认是 DIRECT

源码路径：`tunnel/tunnel.go` 在 `mode: global` 时直接取 `proxies["GLOBAL"]`，
**完全跳过 rules**——所以加多少条 `DOMAIN-SUFFIX,accuweather.com,Proxy` 都救不了
global 模式。而内置 GLOBAL 的 `selectedProxy()` 在无选择时返回列表首项，实测列表是
`["DIRECT","REJECT","直连",…]`，即**默认 DIRECT**；只有 `cache.db` 里存过
`GLOBAL→Proxy` 时才走代理。cache 丢失、换机或首次启动时，global 模式会变成
「全局直连」（v4 也一样）。

修复：显式定义 GLOBAL，把首项设为 Proxy（`include-all` 仍保留选任意节点的能力）：

```yaml
  - {name: "GLOBAL", type: select, proxies: [Proxy], include-all: true}
```

注意：`profile.store-selected` 会把面板手选结果写进 cache.db；若旧 cache 里
`GLOBAL` 仍是 DIRECT，重启后仍会恢复 DIRECT。到面板重选一次 Proxy（或删除
`cache.db` 后重启）即可，之后本配置的默认值保证不会再回落到 DIRECT。

### 3.9.3 验证与回滚

```bash
ip -6 addr show Mihomo | grep inet6           # 应出现 fdfe:dcba:9876::1/126
ip -6 route show table all | grep -i mihomo   # 应出现 default ... dev Mihomo
dig -t AAAA @127.0.0.1 api.accuweather.com     # 应为 fdfe:dcba:9877::/64 内的假地址
curl -6 ... https://dataservice.accuweather.com/   # mihomo 日志应出现 using GLOBAL/Proxy
curl -s http://127.0.0.1:9090/proxies/GLOBAL | jq -r .now   # 应为 Proxy
```

Tailscale 回归：`ip -6 route get fd7a:115c:a1e0::53` 仍应为 `dev tailscale0`
（它的 `ip rule ... lookup 52` 优先级 5270，早于 mihomo 的 9000 段）。
若某天系统 IPv6 异常，删掉 `inet6-address` 与 `fake-ip-range6` 即可回到纯 IPv4；
GLOBAL 覆盖可以单独保留。

## 3.10 Google Fonts 图标豆腐块：fonts.googleapis.com / fonts.gstatic.com 直连（2026-11-14）

> 2026-11-14 配置改动；部署重启后按 3.10.4 验证。

现象：Google Maps 能打开、地图/图片都正常，但**所有图标都渲染成带十六进制数字的
豆腐块**（Firefox 的 missing-glyph 占位符）；其它网站的图标字体也偶发加载失败。

### 3.10.1 先排除 fontconfig

这类豆腐块的第一嫌疑是本机字体（PUA 码位无回退、icon webfont 缺失等，见
`fontconfig/.config/fontconfig/README.md`「网页图标字体（PUA）兜底」）。但本例中
页面 @font-face 的字体文件**根本没下载下来**，fontconfig 层面无解（README 已记录：
@font-face 加载失败时 Firefox 保留空的同名用户字体，不做同名系统字体回落，也不走
fontconfig family 替换）。真正的链路在网络层。

### 3.10.2 根因：机场出口掐断 fonts 域名的 TLS

Google Maps 图标用的 webfont（`Google Symbols` / `Google Material Icons` 等）由
fonts.googleapis.com（CSS）+ fonts.gstatic.com（字体文件）提供。实测（curl 走
本机 mihomo）：

* `maps.google.com` / `www.google.com` / `www.gstatic.com` → 全部正常；
* `fonts.googleapis.com` / `fonts.gstatic.com` → CONNECT 成功后 **TLS 握手阶段
  被对端掐断**（`unexpected eof while reading`，exit 35）。

这**不是** GFW（直连这两个域名反而通），也不是本机/代理栈的问题——把 `手动选择`
依次切到新加坡/香港/日本/美国等多家节点，两个域名全部同样失败，而同链路的
`www.gstatic.com` 一直正常。即：**机场出口对这两个域名做了针对性阻断**（原因不明，
可能与滥用字体 CDN 做代理中转的流量有关）。

同时这两个域名有 Google 中国本地 CDN：DNSPod DoH（1.12.12.12）解析
`fonts.gstatic.com → 58.63.233.34`、`fonts.googleapis.com → 113.108.239.225`
（广东联通），手工 `--resolve` 指过去带 SNI 直连均 200。**直连即可，不需要代理。**

### 3.10.3 修复：规则序里加 DIRECT

`config.yaml` 的规则区 `[10] 谷歌` 里，在 DOMAIN-SUFFIX,googleapis.com /
gstatic.com **之前**插入两条（后缀规则是先到先得）：

```yaml
  - DOMAIN-SUFFIX,fonts.googleapis.com,DIRECT
  - DOMAIN-SUFFIX,fonts.gstatic.com,DIRECT
```

与 3.8（yacd 直连）是同一类修法；DNS 侧无需任何改动——`dns.respect-rules: true`
下 DIRECT 出站自动改用 `direct-nameserver`（国内 DoH）解析，天然拿到中国 CDN 的 IP。

### 3.10.4 验证与回滚

```bash
curl -s http://127.0.0.1:9090/rules | python3 -c \
  "import json,sys; [print(r['payload'],'->',r['proxy']) for r in json.load(sys.stdin)['rules'] if 'fonts' in r['payload']]"
# 应输出两行 ... -> DIRECT

# 端到端（走本机代理链路，与浏览器一致）
curl -x http://127.0.0.1:7890 -s -o /dev/null -w '%{http_code}\n' \
  'https://fonts.gstatic.com/s/materialicons/v143/flUhRq6tzZclQEJ-Vdg-IuiaDsNc.woff2'   # 200
curl -x http://127.0.0.1:7890 -s -o /dev/null -w '%{http_code}\n' \
  'https://fonts.googleapis.com/icon?family=Material+Icons'                              # 200

# 其它 Google 服务不受影响（仍走「谷歌」组）
curl -x http://127.0.0.1:7890 -s -o /dev/null -w '%{http_code}\n' https://maps.google.com # 302
```

回滚：删除上面两条 DOMAIN-SUFFIX 即可（备份 `config.yaml.bak.20261114-170058` 是
改动前的整份配置）。

## 3.11 国内判定兜底（GeoSite cn + GeoIP CN）与 DNS 泄露防护（2026-11-14）

目标：**域名表漏掉的国内服务也能直连**，同时不让「为了判断而解析」变成新的 DNS 泄露面。

### 3.10.1 两层判断

| 层 | 规则 | 要不要 DNS | 作用 |
| --- | --- | --- | --- |
| 域名层 | `GEOSITE,cn,DIRECT`（`[3]` 段末尾，Apple / AI 例外 / china_ip 之后） | **不要** | GeoSite 的 `cn` 集合实测 **118,302 条记录**，补 skk domestic（884 行）覆盖不到的长尾国内站点 |
| IP 层 | `GEOIP,CN,DIRECT`（`[13.5]`，`MATCH` 之前） | 要（mihomo 内部 DoH） | 域名规则全没命中时，按解析结果判国内；同时覆盖裸 IP 连接 |

**`GEOIP` 不能写 `no-resolve`**：fake-ip 模式下连接目标是 `198.18.x` 假地址，带
`no-resolve` 的 IP 规则会直接跳过（同 3.8 的 yacd 案例）。不写 `no-resolve` 时
mihomo 用自己的 DoH 解析域名再比较，系统解析器（`/etc/resolv.conf`）全程不参与。

顺序上 `GEOSITE,cn` 放在 `[3]` 段**末尾**，是为了让前面的显式规则（AI 国际版例外、
Apple、Steam、china_ip 等）优先；`GEOIP,CN` 放在 `[13]` 全球规则之后、`MATCH` 之前，
所以只有「前面所有规则都没命中」的域名才会走到它。

### 3.10.2 DNS 泄露面逐条处理

本配置的链路是「应用 → 系统解析器 → mihomo DNS（fake-ip）→ mihomo 内部 DoH」，
应用拿到的永远是 `198.18.x` 假地址，不存在「系统解析器把域名明文发给运营商」的
经典泄露。剩下的泄露面：

| 泄露面 | 处理 |
| --- | --- |
| DoH 服务器地址本身是域名（`dns.google` / `doh.pub` / `dns.alidns.com`）→ 必须先明文 UDP 解析一次（`default-nameserver`） | **全部改成 IP 形式 DoH 端点**：国外 `https://1.1.1.1/dns-query`、`https://8.8.8.8/dns-query`；国内 `https://1.12.12.12/dns-query`（DNSPod）、`https://223.5.5.5/dns-query`（AliDNS）。`nameserver` / `direct-nameserver` / `proxy-server-nameserver` / `nameserver-policy` 四处都不出现域名；纯 IP 明文 UDP 只保留在 `default-nameserver`（119.29.29.29 / 223.5.5.5）作引导兜底 |
| 直连模式（`mode: direct`）或 Proxy 选「直连」时，国外 DoH 直连查询不可达 → 解析失败/卡 5s | 连接改由 `direct-nameserver`（国内 DoH）解析（mihomo 源码 `adapter/outbound/direct.go`），机制与实测见 3.11.5 |
| 国外 DoH 查询从本地直连发出，本地网络能看到「谁在查 DNS」 | `respect-rules: true` + `proxy-server-nameserver`：DoH 连接命中 `MATCH → Proxy`，查询从代理出口发出（实测日志见 3.11.3） |
| `GEOIP,CN` 兜底会为未知域名触发一次解析 | 这次解析就是上面那套 DoH；只有域名层全没命中的域名才会触发 |
| IPv6 绕过 TUN 导致解析/连接出境 | `tun.inet6-address` + `fake-ip-range6`（3.9） |
| 明文 UDP 53 出站 | TUN 的 `dns-hijack: any:53` 全部拦进 mihomo；本配置已无域名形式 nameserver，`default-nameserver` 正常不会被用到 |
| 应用自带 DoH（浏览器 Secure DNS） | 流量仍进 TUN、按域名走规则，不会明文出站；若要彻底强制走 mihomo DNS，可在浏览器里关掉 Secure DNS，或在面板里给对应域名单独定策略 |

### 3.10.3 实测（2026-11-14，一次性测试实例）

```text
www.qq.com        → match GeoSite(cn) using DIRECT     # 域名层，零 DNS 查询
www.iflow.cn      → match GeoSite(cn) using DIRECT
www.modelscope.cn → match GeoSite(cn) using DIRECT
1.2.4.8           → match GeoIP(cn) using DIRECT       # IP 层（裸 IP 直连）
example.com       → match Match using Proxy            # 兜底不变
mihomo --> 1.1.1.1:443 match Match using Proxy[...]    # 判断用的 DoH 从代理出口发出
mihomo --> 8.8.8.8:443 match Match using Proxy[...]    # 本地网络只看到到代理节点的连接
```

四条 IP 形式 DoH 端点（`1.1.1.1` / `8.8.8.8` / `223.5.5.5` / `223.6.6.6`）分别起
实例验证过都能解析；`GEOSITE,cn` 加载日志 `records: 118302`。

### 3.10.4 代价与判断口径

- `GEOSITE,cn`：11.8 万条，与已加载的 `GeoSite.dat` 同一份文件，启动与内存增量小。
- `GEOIP,CN`：只对「前面所有规则都没命中」的域名触发一次内部 DoH 查询；命中
  `global_non_ip` / 服务组的域名不受影响。代价是一次往返延迟（DNS 结果有缓存）。
- 判断口径：GEOIP 的解析走 `nameserver`（境外 DoH，经代理出口），拿到的是「境外
  视角」的解析结果。因此「全球 CDN 在国内有节点、但境外解析给海外 IP」的域名会被
  判成非国内而继续走代理——方向是安全的（宁可代理，不误直连）。国内大站基本都在
  `GEOSITE,cn` 或 skk 表里，不会依赖这一步。

> 维护提示：如果发现某国内域名仍走代理，先确认它是否在 `GEOSITE,cn` / skk 表里；
> 都不在且 GEOIP 也判不出（境外视角解析到海外 IP），就按 3.5 的格式补
> `DOMAIN-SUFFIX,...,DIRECT`。**不要把 GEOIP,CN 提到规则前面**——那会让海外域名
> 也先被解析一次，泄露面和白名单行为都会变。

### 3.10.5 直连模式（mode: direct / Proxy 选直连）为什么还能正常解析

需求：**选直连时 DNS 仍要能解析、连接仍要能建立**。这里靠的是 `direct-nameserver`：

- mihomo 的 DIRECT 出站（`adapter/outbound/direct.go`）在解析域名时用的是
  `resolver.DirectHostResolver`，也就是 `direct-nameserver`；
- 只要配置了 `direct-nameserver`，DIRECT 出站就会用它解析 Host（即使规则层已经
  解析过，也会用这套再解析一次）；
- 所以 `mode: direct`、`GLOBAL → 直连`、`Proxy → 直连` 三种情况，域名解析全部落到
  国内 DoH（DNSPod / Ali），不依赖国外 DoH 是否可达。

实测（临时实例，**故意把 `nameserver` 换成不可达的 `https://192.0.2.1/dns-query`**，
`direct-nameserver` 仍是 1.12.12.12 / 223.5.5.5，`mode: direct`）：

```text
curl -x 127.0.0.1:7899 https://example.com/    → 200, 0.29s
curl -x 127.0.0.1:7899 https://www.baidu.com/  → 200, 0.05s
[DNS] resolve example.com   A from https://1.12.12.12:443/dns-query
[DNS] resolve example.com   A from https://223.5.5.5:443/dns-query
[DNS] resolve www.qq.com    A from https://1.12.12.12:443/dns-query
[DNS] resolve www.baidu.com A from https://223.5.5.5:443/dns-query
```

即国外 DoH 直连不可达时，直连出口的解析自动落到国内 DoH，连接照常建立。

规则模式（`mode: rule`）下把 `Proxy` 选到「直连」也是同一机制：命中规则后仍由
DIRECT 出站 + `direct-nameserver` 解析。唯一的额外代价是：**未知域名**（域名表
全没命中）会先被 `GEOIP,CN` 兜底用国外 DoH 解析一次，若那时国外 DoH 直连不可达，
最多等 5 秒再落到 `direct-nameserver` 建连（只影响首次、有缓存）。想彻底避免这段
等待，用 `mode: direct` 或 `GLOBAL → 直连` 即可（这两种模式不跑规则）。

### 3.10.6 国内 / 国外 DNS 分流实测（规则模式）

```text
# DNS API 查询（走 nameserver-policy）
www.qq.com   → [DNS] resolve ... from https://1.12.12.12:443/dns-query
             → [DNS] resolve ... from https://223.5.5.5:443/dns-query      # 国内域名 → 国内 DNS
example.com  → [DNS] resolve ... from https://1.1.1.1:443/dns-query
             → [DNS] resolve ... from https://8.8.8.8:443/dns-query        # 国外域名 → 国外 DNS
```

- 国内条目在 `nameserver-policy` 里显式带 `#DIRECT`，不依赖 `china_ip` 规则也保证
  国内域名查询不经过代理；
- 国外条目沿用 `respect-rules`：规则模式下 DoH 连接命中 `MATCH → Proxy`，
  查询从代理出口发出（日志 `mihomo --> 1.1.1.1:443 match Match using Proxy[...]`）。


## 4. 从上游借鉴了什么、没借什么

借鉴（均已落地）：

1. **分层**：总入口 → 地区策略 → 地区自动 → 节点；服务组与地区组解耦。
2. **`fallback` 故障转移**：整组节点全挂时自动往后切。
3. **`url-test` + `tolerance` + `lazy`**：自动优选，未使用时不做健康检查。
4. **`include-all + filter` 而非 `use: [独角兽]`**：加机场不用改 5 处。
5. **YAML 锚点模板**（`BaseUT`/`BaseFB`/`SelectPY`/`FilterXX`）：20+ 组只写一次模板。
6. **服务组直接暴露"地区策略"选项**：AI 想锁美国、流媒体想锁日本，改一个组即可。

没借（有意为之）：

| 上游特性 | 不采用的原因 |
| --- | --- |
| 整份 51–61 组模板 | 单机场 37 节点撑不起 7 地区 × 3 层；且会覆盖我们已有的 Apple storefront / Tailscale / QUIC 修复 |
| `load-balance`（一致性哈希/轮询） | 单机场节点质量参差，哈希会把坏节点也算进去；桌面场景收益低 |
| `listeners` 分地区端口（50000+） | 单机桌面用不到，徒增暴露面 |
| `type: smart`（uselightgbm） | 需要 smart 魔改内核，本机是 `with_gvisor` 官方 tag，不认这个类型 |
| `format: mrs` 规则集 | 现有 skk.moe `text` 规则已落地缓存，换 mrs 要重下全套并重验规则 |
| `Overwrite/` 三套订阅覆盖机制 | 那是给 subconverter / OpenClash 用的，与 systemd + LoadCredential 的部署链无关 |

> 许可证：上游是 **AGPL-3.0**，README 明确禁止转载到中国大陆公共平台。
> 这里只借鉴思路与正则写法（结构/思想不受版权保护），未复制其文件内容。

## 5. 顺带修掉的问题

| 问题 | 处理 |
| --- | --- |
| `dns.store-fake-ip` 是**无效键**（源码 DNS struct 无此字段，未知键静默通过） | 删除；真键在 `profile.store-fake-ip` |
| `DOMAIN,*.steamcontent.com` / `DOMAIN,*.fastly.steamstatic.com` 用错类型（`DOMAIN` 是精确匹配，通配符永不命中） | 删除（前面的 `DOMAIN-SUFFIX` 已覆盖） |
| `RULE-SET,reject_ip,REJECT` 缺 `no-resolve`，可能触发额外 DNS 解析 | 补 `no-resolve` |
| `log-level: info` 常驻，一天 3 万+ 行日志 | 改 `warning`（排障时临时改回 info） |
| 手选结果重启后丢失 | `profile.store-selected: true` |
| 服务流量只能整体走 `Proxy` | 拆出 AI / 流媒体 / 电报 / 微软 / 谷歌 / GitHub |
| 国产 AI / Agent 域名（`qianwenai.com`、`kimi.com`、`trae.cn` 等）不在 skk 四张规则集里，落到 `MATCH → Proxy` | 引入 MetaCubeX `category-ai-cn` 规则集（129 条，自动更新）+ 27 条显式 `DOMAIN-SUFFIX`，并把 `qwen.ai` / `qwenlm.ai` / `z.ai` 显式指回 `AI` 组（见 3.5） |
| 广告拦截只有 skk `reject_domainset` 一张表（149k 域名） | 补 Loyalsoldier `reject.txt`（199k，净增 63k，并集 212k，见 3.6） |
| yacd.example.com（腾讯云国内 IP）走代理被 reset | 加 `DOMAIN,yacd.example.com,DIRECT`（见 3.8） |
| `mode: global` 下 AccuWeather 仍绕过代理 | TUN 补 `inet6-address`，让 IPv6 也进 mihomo（见 3.9） |
| Google Maps 图标全变豆腐块（icon webfont 在 TLS 握手阶段被机场出口掐断，fontconfig 层无解） | `fonts.googleapis.com` / `fonts.gstatic.com` 加 DIRECT（两域名有 Google 中国 CDN，直连即可，见 3.10） |
| GCP 免费节点间歇性 REALITY 认证失败 | 整体移除（见 2） |
| 域名表没收录的国内服务仍落到 `MATCH → Proxy` | `GEOSITE,cn`（118,302 条）补域名层 + `GEOIP,CN` 兜底 IP 层（见 3.11） |
| DoH 服务器域名要先走 `default-nameserver` 明文 UDP 解析 | 全部换成 IP 形式 DoH 端点，正常不再产生明文 DNS 出站（见 3.11.2） |

## 6. 部署与回滚

```bash
# 1) 校验（不会动线上实例，用一次性 -d 目录）
mihomo -t -f mihomo/etc/mihomo/config.yaml -d /tmp/cfgtest

# 2) 备份 + 部署（root；0600，避免 token/节点凭据被普通用户读取）
doas cp -a /etc/mihomo/config.yaml "/etc/mihomo/config.yaml.bak.$(date +%Y%m%d-%H%M%S)"
doas install -m 0600 -o root -g root \
  /home/Projects/Stow-Dotfile/mihomo/etc/mihomo/config.yaml /etc/mihomo/config.yaml

# 3) 重启（只 reload 不会重新复制 credential）
doas systemctl restart mihomo
systemctl is-active mihomo
curl -s http://127.0.0.1:9090/version          # {"meta":true,"version":"1.19.34"}
curl -s http://127.0.0.1:9090/proxies | python3 -m json.tool | head

# 回滚
doas cp -a /etc/mihomo/config.yaml.bak.<ts> /etc/mihomo/config.yaml && doas systemctl restart mihomo
```

部署后验证要点：`/proxies` 里 `GLOBAL`（now 应为 `Proxy`）、`Proxy`、`手动选择`、5 个地区策略、
5 个 `*自动` 都要出现；
`/providers/proxies/良心云` 有 16 个节点（名字带 `[良心云] ` 前缀）；`/rules` 100 条（含 2026-11-14 新增的国产 AI/Agent 规则集与补充规则、`GEOSITE,cn` 域名兜底、`GEOIP,CN` IP 兜底、yacd 直连、fonts 直连两条）；`/providers/rules/ai_cn` 129 条（见 3.5）；
`/providers/rules/loyalsoldier_reject` 199,133 条（配合 `reject_domainset` 149,448 条，见 3.6）；
启动日志应有 `Finished initial GeoSite rule cn => DIRECT, records: 118302`（见 3.11）；
`curl -s 'http://127.0.0.1:9090/dns/query?name=example.com&type=A'` 应返回真实 IP（不是 198.18.x）；
`mihomo` 日志里查不到任何明文 UDP 53 出站（DNS 全为 DoH）；
直连模式自检：`curl -s -X PATCH http://127.0.0.1:9090/configs -H 'Content-Type: application/json' -d '{"mode":"direct"}'`，
随后 `curl -x http://127.0.0.1:7890 -s -o /dev/null -w '%{http_code}\n' https://example.com/` 应为 `200`（验证 `direct-nameserver` 兜底），测完 PATCH 回 `{"mode":"rule"}`；
面板里 `*自动` 应为隐藏（6 个：5 个地区自动 + 验证自动）；
刷新 yacd 后分组顺序应为 `Proxy → 手动选择 → 自动选择 → 故障转移 → 服务组 → 地区策略 → 地区自动 → GLOBAL`
（顺序来自 `GLOBAL.proxies`，见 3.3.1；改 YAML 位置不会生效）。

## 7. 已知问题与待验证项

1. **订阅源当前不可达**：`<机场订阅地址>` 直连/走代理都超时（`code=000`），
   provider 刷新失败（`pull error: EOF`），节点列表冻结在 10:26 的 37 个（约 27 个存活）。
   `<节点 IP>:<端口> connection refused` 刷屏就是机场侧节点拒连，不是规则问题。
2. ~~**IPv6 可能绕过代理**~~（2026-11-14 配置已改，待部署重启验证）：已加 `tun.inet6-address` 与 `fake-ip-range6`，见 3.9。
3. **`dns.listen: 0.0.0.0:53` + `allow-lan: true`**：对局域网开放递归解析器（放大/污染风险）。
   若不需要 LAN DNS，改成 `127.0.0.1:53`。
4. **`127.0.0.1:7890` 连接超时**，而 `<本机 LAN IP>:7890` 正常——疑似本机残留的
   redirect/nft 规则，需要 root 查 `ss -tlnp 'sport = :7890'` 与 `nft list ruleset`。
5. `rule-providers` 仍带 `proxy: Proxy`：代理全挂时规则集无法刷新（有本地缓存兜底）。
   若想更容易自愈，可去掉 `proxy:` 依赖 `respect-rules`（上游做法）。
6. **Apple Music 无地区前缀 URL**（`music.apple.com/library/...`）会被 Apple 服务端
   按美国店渲染，刷新时出现 `/us` → `/cn/home` 跳转并可能报「请刷新页面」。
   这不是 mihomo 分流问题；书签要写 `/cn/library/...`，详见
   [apple-music-storefront-redirect.md](apple-music-storefront-redirect.md)。
