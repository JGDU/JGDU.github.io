---
layout:     post
title:     XMPPFrameWork之XMPPIDTracker
date:       2016-07-06 15:31:19
author:     haolj
summary:    .
categories: XMPPIDTracker
thumbnail: heart
tags:
 - mind
 - think
---


在XMPP常见的操作是发送某种拥有唯一ID的请求，并等待响应回来。

最常见的例子是发送拥有type='get'的IQ，然后等待响应。

为了正确处理响应，该ID必须存储。如果有多个查询和/或不同类型的查询发出，然后对反应的适当处理的信息也必须存储。

这可以通过相应的selector，或者一个block来完成。

另外人们需要设置一个超时时间.
 
该类提供支持以简化与此共同操作相关联的任务。

本质上，它提供了以下内容：

+ 一本字典，其中唯一的ID​​是Key，而所需的跟​​踪信息是Object
+ 一个可选的计时器射击在超时


类被设计成柔性的,您可以提供要调用的 target/selector或block。
此外，还可以使用基本的跟踪信息，或者你可以扩展它来满足您的需求。

用几个实施例来说明

####---- EXAMPLE 1 - SIMPLE TRACKING WITH TARGET / SELECTOR ----


```objc

XMPPIQ *iq = ...
[iqTracker addID:[iq elementID] target:self selector:@selector(processBookQuery:withInfo:) timeout:15.0];
- (void)processBookQueury:(XMPPIQ *)iq withInfo:(id <XMPPTrackingInfo)info {
   ...
}
- (BOOL)xmppStream:(XMPPStream *)stream didReceiveIQ:(XMPPIQ *)iq
{
    NSString *type = [iq type];
    
    if ([type isEqualToString:@"result"] || [type isEqualToString:@"error"])
    {
        return [iqTracker invokeForID:[iq elementID] withObject:iq];
    }
    else
    {
        ...
    }
}

```


 
 ####---- EXAMPLE 2 - SIMPLE TRACKING WITH BLOCK HANDLER ----
 
```objc

 XMPPIQ *iq = ...
 
 void (^blockHandler)(XMPPIQ *, id <XMPPTrackingInfo>) = ^(XMPPIQ *iq, id <XMPPTrackingInfo> info) {
     ...
 };
 [iqTracker addID:[iq elementID] block:blockHandler timeout:15.0];
 
 // Same xmppStream:didReceiveIQ: as example 1
 ```


####---- EXAMPLE 3 - ADVANCED TRACKING ---


```objc
@interface PingTrackingInfo : XMPPBasicTrackingInfo
    ...
@end
XMPPIQ *ping = ...
PingTrackingInfo *pingInfo = ...
[iqTracker addID:[ping elementID] trackingInfo:pingInfo];
- (void)handlePong:(XMPPIQ *)iq withInfo:(PingTrackingInfo *)info {
    ...
}
// Same xmppStream:didReceiveIQ: as example 1
```

####---- Validating Responses ----

XMPPIDTracker还可以用来验证该响应是从来自期望的的JID。
要做到这一点，你需要实例化 XMPPIDTracker与其中请求/响应将被跟踪的request/response的stream。
xmppIDTracker = [[XMPPIDTracker alloc] initWithStream:stream dispatchQueue:queue];
您还需要元素（不仅仅是ID）提供给添加一个调用的方法。
####---- EXAMPLE 1 - SIMPLE TRACKING WITH TARGET / SELECTOR AND VALIDATION ----


```objc
XMPPIQ *iq = ...
[iqTracker addElement:iq target:self selector:@selector(processBookQuery:withInfo:) timeout:15.0];
- (void)processBookQueury:(XMPPIQ *)iq withInfo:(id <XMPPTrackingInfo)info {
   ...
}
- (BOOL)xmppStream:(XMPPStream *)stream didReceiveIQ:(XMPPIQ *)iq
{
    NSString *type = [iq type];
    if ([type isEqualToString:@"result"] || [type isEqualToString:@"error"])
    {
        return [iqTracker invokeForElement:iq withObject:iq];
    }
    else
    {
        ...
    }
}

```

这个类不是线程安全的
它被设计成一个线程安全上下文中使用(e.g. within a single dispatch_queue).