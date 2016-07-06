---
layout:     post
title:     XMPP之阻止和过滤通讯基础篇
date:       2016-06-12 15:31:19
author:     haolj
summary:    .
categories: React Native
thumbnail: heart
tags:
 - mind
 - think
---

本文内容参考自*《XMPPDefinitiveGuild》*,该书通俗易懂,值得一读.
如果有兴趣可以[联系我](tencent://message/?Menu=yes&uin=295938867&Site=&Service=201&sigT=...)索要.

##一个简单方法

###block状态

{% highlight xml %}
<iq from="suke@skh.whu.edu.cn/Psi" id="yu4er81v"to="suke@skh.whu.edu.cn"type="set"><block xmlns="urn:xmpp:blocking"> //注意`xmpp` 为小写<item jid="gmz@skh.whu.edu.cn"/> </block></iq>
{% endhighlight%}

*注:在此假设你已经有了一定的关于xmpp的基础知识* 

这里只用一个使用一个block的IQ-set 将jid为`gmz@skh.whu.edu.cn`的好友 表示为block状态
此时意味着啥呢?

暂且假设`gmz@skh.whu.edu.cn`是你的那个超级鸡血的微商朋友-F.

+ 首先当你对 F 添加了阻止规则,你的服务器发送出一个不可用的出席包,以便F以为你是离线。从那时起,任何时候 你更新你的出席(例如,恢复在线),相关的出席节不会被发送给 F(似乎你永远不再登陆)。+ 其次,你的服务器需要确认F不能用任何方式找出你在线。这意味着你的服务器对进来的 IQ-get 或 IQ-set 使用<service-unavailable/>错误应答,忽略进来的任何 <message/>消息(或再次返回一个<service-unavailable/>错误),并且放弃任何进来的 <presence/>节。+ 最后,您的服务器需要防止你做一些愚蠢的事情,比如向F发送一个消息或 IQ 请求,这样它会对任何发送给 `gmz@skh.whu.edu.cn`向外的节回复一个<not-acceptable/> 错误。

除此之外你也可以阻拦完整的域名,如某个服务器

```xml
<iq from="suke@skh.whu.edu.cn" id="i3s91xc3"to="skh.whu.edu.cn"//注意这里type="set"><block xmlns="urn:XMPP:blocking"><item jid="spammers.lit"/> </block></iq>
```


###设置为非block状态

```xml
<iq from="suke@skh.whu.edu.cn/Psi" id="ng23h57w"to="suke@skh.whu.edu.cn"type="set"><unblock xmlns="urn:XMPP:blocking"><item jid="gmz@skh.whu.edu.cn"/> </unblock></iq>
```

同理,设置为unblock状态将会把对应items从你的阻拦列表中剔除.

###查看阻拦列表

```xml
<iq from="suke@skh.whu.edu.cn" id="i3s91xc3"to="skh.whu.edu.cn"type="set"><block xmlns="urn:XMPP:blocking"><item jid="spammers.lit"/> </block></iq>
```

获取后如下

```xml
<iq from="suke@skh.whu.edu.cn" id="92h1nv8f"to="suke@skh.whu.edu.cn/Psi"type="result"><blocklist xmlns="urn:XMPP:blocking"><item jid="gmz@skh.whu.edu.cn"/><item jid="spammers.lit"/> </blocklist></iq>
```


##在OC中使用XMPPFrameWork
XMPP尽量减轻客户端复杂度,
而XMPPFrameWork又降低了开发难度,所以这里只是简单介绍使用, blockUser为例.

```objc
-(void)blockUser:(XMPPJID *)user
{
    NSXMLElement *block = [NSXMLElement elementWithName:@"block" xmlns:@"urn:xmpp:blocking"];
    
    NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
    
    [item addAttributeWithName:@"jid" stringValue:user.bare];
    
    [block addChild:item];
    
    XMPPStream * xmppStream = [self xmppStream];
    
    XMPPIQ *iq = [XMPPIQ iqWithType:@"set" ];
    
    [iq addChild:block];
    
    [xmppStream sendElement:iq];

}
```

:) 