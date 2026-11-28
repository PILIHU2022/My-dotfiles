# Apple Music 网页版「播放一段时间报错，刷新跳 /us 再跳 /cn」根因与修复

> 2026-11-22 排查。现象与 mihomo 的代理分流**无因果关系**；根因是 Apple Music
> 前端（或旧书签）使用了无地区前缀的 `/library/...` URL。mihomo 侧另有一个
> HTTPS RR 别名漏直连的真实问题，一并修掉（见 §5），但它不是本现象的成因。

## 0. 一句话结论

`https://music.apple.com/library/playlist/...` 这种**没有 `/cn` 前缀**的旧链接，
Apple 服务端会固定渲染成美国店（`"storefront":"us"`、`lang="en-US"`），即使请求
来自中国大陆 IP、`itua=CN` Cookie、`Accept-Language: zh-CN` 也一样。前端随后跳到
`/us/library/...`，Apple 再按大陆出口 302 回 `/cn`、`/cn/home`。页面店（us）与
账号店（cn）不一致，MusicKit 就会在播放时抛「出现错误，请刷新页面」。

**修复：把书签改为 `https://music.apple.com/cn/library/playlist/...`。**
mihomo 只能保证出口 IP 一致，不能改写 URL 路径，也无法改变 Apple 对无地区前缀
URL 的服务端渲染结果。

## 1. 现象

用户打开 mihomo 后访问：

```text
https://music.apple.com/library/playlist/p
  ↓ 刷新
https://music.apple.com/us/library/playlist/p
  ↓ 再次刷新
https://music.apple.com/cn/home
```

途中没有返回/前进操作，语言从中文变成英语。播放一段时间后出现
「出现错误，请刷新页面」。

## 2. 复现与证据（全部走中国大陆直连出口）

### 2.1 本机真实出口

```text
$ curl --noproxy '*' https://myip.ipip.net/
当前 IP：113.99.161.177 来自于：中国 广东 东莞 电信
```

### 2.2 无地区前缀页面：Apple 固定给美国店

```text
$ curl --noproxy '*' -sS \
    -H 'Cookie: itua=CN' -H 'Accept-Language: zh-CN,zh;q=0.9' \
    'https://music.apple.com/library/playlist/p.WmzV8EOidxLDBxg' \
  | grep -oE '<html[^>]*lang="[^"]*"|"storefront":"[^"]*"'
<html dir="ltr" lang="en-US"
"storefront":"us"
```

同时响应头是 **KS-CLOUD（中国大陆 CDN）**、`HTTP 200`，并非走了境外代理。

### 2.3 带 `/cn` 前缀页面：正确给中国店

```text
$ curl --noproxy '*' -sS \
    'https://music.apple.com/cn/library/playlist/p.WmzV8EOidxLDBxg' \
  | grep -oE '<html[^>]*lang="[^"]*"|"storefront":"[^"]*"'
<html dir="ltr" lang="zh-Hans-CN"
"storefront":"cn"
```

### 2.4 `/us` 被 Apple 按大陆出口 302 回 `/cn`

```text
$ curl --noproxy '*' -sSI \
    'https://music.apple.com/us/library/playlist/p.WmzV8EOidxLDBxg' \
  | grep -Ei '^(HTTP|location)'
HTTP/2 302
location: /cn
```

### 2.5 浏览器缓存与账号状态

Firefox `cache2` 中 2026-11-22 10:09:22 的页面响应（`peer-ip-address` 为
mihomo fake-ip `198.18.0.45`）：

```text
https://music.apple.com/library/playlist/p.WmzV8EOidxLDBxg
HTTP/3 200
server: Tengine/2.3.2
x-cache: MISS KS-CLOUD
content-type: text/html
```

解压后的 HTML 中：

```json
{"intent":{"id":"p.WmzV8EOidxLDBxg","storefront":"us","language":null,
 "$kind":"LibraryPlaylistPageIntent"}}
```

同一时间的 `/us/library/...` 响应：

```text
https://music.apple.com/us/library/playlist/p.WmzV8EOidxLDBxg
HTTP/3 302
location: /cn
```

而账号接口返回的是中国店：

```text
GET https://amp-api.music.apple.com/v1/me/account
{"meta":{"subscription":{"active":true,"storefront":"cn"}}}
```

`itua=CN` Cookie 自 2026-02-05 起就存在，说明不是 Cookie 丢了，也不是账号在美区。

## 3. 为什么「播放一段时间」才报错

Apple Music 前端 bundle 里生成「资料库播放列表」链接的代码本身就是：

```js
url: `/library/playlist/${n}`,
segue: { intent: { id: n, storefront: null, language: null } }
```

也就是说，用户在 `/cn/home` 点击资料库里的播放列表时，**Apple 前端自己会跳到
没有 `/cn` 的 `/library/playlist/...`**（不是用户手改 URL，也不一定是书签旧）。
服务端对该路径按 `storefront:null` 回退成 `us`，于是：

首屏 HTML 的 `serialized-server-data` 写死 `"storefront":"us"`，前端路由据此
把地址改成 `/us/library/...`；同时 `v1/me/account` 返回账号店 `cn`。MusicKit 按
**页面地址里的地区**播放，页面店（us）与账号店（cn）不一致时：

- 能进入播放器，但部分请求按 us 目录发起；
- 播放/切歌/令牌刷新到某个阶段时，Apple 返回地区不匹配；
- 网页弹出「出现错误，请刷新页面」；
- 刷新后 `/us` 被 302 回 `/cn`，最终落到 `/cn/home`，所以看起来像「自己跳回去」。

这与代理节点质量、Apple 服务故障都无关，换节点也不会消失。

## 4. 正确修复（用户侧）

把旧书签/旧标签页：

```text
https://music.apple.com/library/playlist/p.WmzV8EOidxLDBxg
```

改为：

```text
https://music.apple.com/cn/library/playlist/p.WmzV8EOidxLDBxg
```

要点：

1. 路径里**必须有 `/cn/`**，且 `/cn` 要紧跟在域名后；
2. **不要直接点 Apple 页面里「资料库 → 播放列表」的链接**：当前网页版 bundle 会
   自己生成无 `/cn` 的 `/library/playlist/...`（见 §3），点一次就会再次踩中。
   请改用上面的 `/cn/library/playlist/...` 书签，或打开 `https://music.apple.com/cn/home`
   后从地址栏核对 URL 再收藏；
3. 如果希望自动纠正，可在 Firefox 的 Redirector 扩展里加一条重写（该扩展本机已装，
   但当前是禁用状态）：
   - Include pattern: `^https://music\.apple\.com/(?!cn/)(.*)$`
   - Redirect to: `https://music.apple.com/cn/$1`
4. Firefox 的「Simple Tab Groups」里保存的 `beta.music.apple.com/library/...` 旧标签
   也建议一起改掉（这些记录同样是地区前缀缺失的旧 URL）；
5. 不需要清 Cookie（`itua=CN` 是正确的），也不需要换 mihomo 节点。

## 5. mihomo 侧的真实问题：Apple HTTPS RR 别名走了代理

排查时确认另一个独立问题，和上面的 URL 现象无关，但会在支持 HTTPS RR 的浏览器上
造成「Apple 页面/API 走代理、音频/图片走直连」的地区撕裂：

```text
$ dig @127.0.0.1 music.apple.com HTTPS
music.apple.com. CNAME music-cdn.itunes-apple.com.akadns.net.
...
h3.apis.apple.map.fastly.net. HTTPS 1 . alpn="h3,h2" \
  ipv4hint="151.101.3.6,151.101.67.6,151.101.131.6,151.101.195.6"
```

`h3.apis.apple.map.fastly.net` 会被以下规则命中：

```text
global_non_ip: DOMAIN-SUFFIX,fastly.net
rules: RULE-SET,global_non_ip,Proxy
```

实测连接链路：

```text
h3.apis.apple.map.fastly.net
  -> ['[独角兽] 🇸🇬新加坡丨DRTˣ²', '手动选择', 'Proxy']
  rule = RuleSet/global_non_ip
```

而 `music.apple.com` / `amp-api.music.apple.com` 本身是 `DIRECT`。浏览器若使用
HTTPS RR（Firefox `network.dns.use_https_rr_as_altsvc`、Chrome Secure DNS 等），
就会把页面/API 的 TCP 目标换成这个 Fastly 别名，出现地区不一致。

修复：在 `[3] 国内直连` 的 Apple Music 片段加一条 **Apple 专用**别名直连：

```yaml
  - DOMAIN-SUFFIX,apple.map.fastly.net,DIRECT
```

不要写成 `DOMAIN-SUFFIX,fastly.net,DIRECT`：GitHub、GOG 等大量正常代理流量也走
Fastly，整域直连会误伤。

## 6. 验证

```bash
# 1) 无 /cn 的旧 URL：应为 us（Apple 的默认行为，证明不是 mihomo）
curl --noproxy '*' -sS 'https://music.apple.com/library/playlist/p.WmzV8EOidxLDBxg' \
  | grep -o '"storefront":"[^"]*"'

# 2) 正确 URL：应为 cn
curl --noproxy '*' -sS 'https://music.apple.com/cn/library/playlist/p.WmzV8EOidxLDBxg' \
  | grep -o '"storefront":"[^"]*"'

# 3) /us 应 302 到 /cn
curl --noproxy '*' -sSI 'https://music.apple.com/us/library/playlist/p.WmzV8EOidxLDBxg' \
  | grep -Ei '^(HTTP|location)'

# 4) mihomo 侧：Apple 主域与别名都应为 DIRECT
curl -s http://127.0.0.1:9090/connections \
  | jq -r '.connections[] | select(.metadata.host|test("music.apple.com|apple.map.fastly.net")) | [.metadata.host, (.chains|join(">")), .rule, .rulePayload] | @tsv'
```

预期第 4 步所有行 `chains` 均为 `DIRECT`；`apple.map.fastly.net` 不再是
`RuleSet/global_non_ip`。

## 7. 回滚

本次 mihomo 只新增一条规则，删除以下行并重载即可回到原状：

```yaml
  - DOMAIN-SUFFIX,apple.map.fastly.net,DIRECT
```
