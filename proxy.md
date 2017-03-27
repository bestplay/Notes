代理与科学上网
===============

捋清概念

从使用工具到编写工具

- http 代理[RFC2616](https://www.ietf.org/rfc/rfc2616.txt)

- socks5 代理[RFC1928](https://www.ietf.org/rfc/rfc1928.txt)

	[维基](https://zh.wikipedia.org/wiki/SOCKS)

- VPN

## Summary

###long long ago…

![enter image description here](http://vc2tea.com/public/upload/whats-shadowsocks-01.png)

### when evil comes

![enter image description here](http://vc2tea.com/public/upload/whats-shadowsocks-02.png)



### VPN
	
	虚拟私人网络，（全局代理）

### GAE GoAgent / XXNET
	
	http proxy

### ssh tunnel
	
	socks5 代理

### ShadowSocks 影梭:

	socks5 代理

## 深入（道高一尺魔高一丈）

### GFW 监管原理： 

- IP 封杀 
- DNS 污染
- 特征干扰(OpenVPN  ssh，特征明显的 VPN)

[XcodeGhost风波](https://zh.wikipedia.org/wiki/XcodeGhost%E9%A3%8E%E6%B3%A2)

[GFW 首要设计师 方滨兴](http://weibo.com/fangbxbupt?is_all=1#1490337194912) 武汉大学被扔鞋

### 为什么不直接切断

	从理论上说，审查部门完全可以用技术手段切断所有代理服务器和VPN连接。

	但因为大量的国内外银行金融交易和企业在跨国通讯时，都必须使用安全和经济的VPN来传输加密数据，

	出于经济的考量，进行网络审查的国家还不可能完全切断所有的代理连接和VPN连接



### 两类梯子比较： Proxy vs VPN (允许你从另外一个地方访问网络)
	
- VPN 更安全更慢，底层协议2,3层，操作系统级，捕获所以底层网络流量。经过 VPN server
	
- Proxy 更快（速度根据加密方式不同），上层协议，应用层，需要每个应用指定代理，且应用支持该代理协议。
	
	关于 客户端/ 服务端
	
	每个应用访问网络。使用软件时仅仅是设置代理。

	事实上，应用对于各种代理协议，**需要实现各种代理协议的客户端**(dirty work)。（与代理服务器的握手，确定认证方式等）

### http 

	请求头改为 全路径

### https
	
	通过 http connect 方法。与服务器建立长连接通道。(GAE 不支持直接 TCP 以及 connect)

	RFC2616 超文本传输协议中定义的 

	curl http://localhost:8124

	curl -x localhost:8124 http://localhost:8080

	curl -x localhost:8124 https://localhost:8080



### GAE GoAgent / XXNET

免费版本仅支持 http 协议，一个邮箱12个 APPID，1G 流量/APPID/天。

自签名证书，(早期安全问题，证书固定)

解包，封包，转发

经过 GFW 时，仅仅是 普通 http 包(body加密)

#### ssl
	tls handshake

	Client Hello

	Server Hello

	确定协议版本，加密压缩算法，交换证书公钥，验证证书

	加密数据交换

	[那些证书相关的玩意儿(SSL,X.509,PEM,DER,CRT,CER,KEY,CSR,P12等)](http://www.cnblogs.com/guogangj/p/4118605.html)

### socks5

	socks5 的 RFC1928 （socks4 不支持 UDP）

	传递数据包，不关心是何种应用协议

### ssh tunnel 

	创建 socks5 代理

	ssh -D 8080 myhomecomputer 

	![enter image description here](http://vc2tea.com/public/upload/whats-shadowsocks-03.png)

#### Windows
- SecureCRT 
- putty
- xshell
- powershell

### ShadowSocks 影梭:
	
简单理解的话，shadowsocks 是将原来 ssh 创建的 Socks5 协议拆开成 server 端和 client 端

对 localhost 开启一个兼容 socks5 的本地端口。

在墙外再设置一个程序。

两个程序之间通过一个 TCP 连接。由本地的程序负责把本地的 proxy 请求都转发到墙外。

ss-local 和 ss-server 两端通过多种可选的加密方法进行通讯，经过 GFW 的时候是常规的TCP包，没有明显的特征码而且 GFW 也无法对通讯数据进行解密

![enter image description here](http://vc2tea.com/public/upload/whats-shadowsocks-04.png)

[ShadowSocks](https://github.com/shadowsocks/shadowsocks)


#### shadowsocks-android

shadowsocks-android

iptables 需要 Root 

[tun2socks （ tun/tap 虚拟网络设备）](https://freevpnssh.info/socks-vpn/)

Android 4.0 开始，开放新的API叫**VpnService**，无需ROOT启动VPN，获取 ip 包。

APP==>IP包==>Android VpnService建立的虚拟网卡==>IP包==>我们的代理程序==>TCP连接（socks代理协议）==>socks代理服务器==TCP连接(http）==>目标服务器

#### shadowsocks-ios

APPLE IOS9 开放了 **VPN API**，需要开发者申请权限。trick 同理 Android

[作者研究了一半被请去喝茶了](https://github.com/shadowsocks/shadowsocks-iOS/issues/124)

由此可以推测，GFW 对SS 翻墙束手无策

	On Aug 22, 2015, at 11:17, clowwindy notifications@github.com wrote:

	Two days ago the police came to me and wanted me to stop working on this. Today they asked me to delete all the code from GitHub. I have no choice but to obey.

	I hope one day I'll live in a country where I have freedom to write any code I like without fearing.

	I believe you guys will make great stuff with Network Extensions.

	Cheers!

于是,出现了一堆收费的 IOS 客户端。


ios Wingy (￥6)

Shadowrocket (￥18)

Potaso (￥45)

### 推荐自搭建 SS

阿里云 国外节点

[搬瓦工](http://bandwagonhost.com/) （用过）

[digitalOcean](https://www.digitalocean.com/pricing) （用过）

[Linode](https://www.linode.com/pricing)

购买 SS 或者自行搭建（安全）



### 小心跨省

2017年1月22日，工业和信息化部发布[《工业和信息化部关于清理规范互联网网络接入服务市场的通知》](https://zh.wikisource.org/wiki/%E5%B7%A5%E4%B8%9A%E5%92%8C%E4%BF%A1%E6%81%AF%E5%8C%96%E9%83%A8%E5%85%B3%E4%BA%8E%E6%B8%85%E7%90%86%E8%A7%84%E8%8C%83%E4%BA%92%E8%81%94%E7%BD%91%E7%BD%91%E7%BB%9C%E6%8E%A5%E5%85%A5%E6%9C%8D%E5%8A%A1%E5%B8%82%E5%9C%BA%E7%9A%84%E9%80%9A%E7%9F%A5)规定未经电信主管部门（各一级行政区通信管理局）批准，不得自行创建或租用VPN等其他信道开展跨境经营活动。这也意味着中国大陆民众如需要创建VPN，必须获取各一级行政区通信管理局的批准

[翻墙违法](https://www.hk01.com/%E5%85%A9%E5%B2%B8/67339/%E5%85%A7%E5%9C%B0%E5%B7%A5%E4%BF%A1%E9%83%A8%E7%A6%81%E8%87%AA%E8%A1%8C%E5%BB%BA%E7%AB%8B%E6%88%96%E7%A7%9F%E7%94%A8VPN-%E4%B8%8A%E7%B6%B2-%E7%BF%BB%E5%A2%BB-%E5%B0%87%E8%A2%AB%E5%9A%B4%E6%8E%A7)

