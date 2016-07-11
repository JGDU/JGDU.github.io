---
layout:     post
title:     XMPPFrameWork之GCDMulticastDelegate
date:       2016-07-06 15:31:19
author:     haolj
summary:    .
categories: XMPPFrameWork
thumbnail: heart
tags:
 - mind
 - think
---

GCDMulticastDelegate 顾名思义就是 广播代理;

通常情况下我们在指定代理的时候只能指定一个,而一对多的情况下,通常使用通知,而GCDMulticastDelegate是xmppFramework作者提供的另一种解决方案.

`GCDMulticastDelegate `维护这一个数组,用来盛放添加的代理以及被设置的`delegateQueue ` (一个`GCDMulticastDelegateNode `对象) 

并通过下面两个方法将方法转发出去.

```objc

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
	for (GCDMulticastDelegateNode *node in delegateNodes)
	{
		id nodeDelegate = node.delegate;
		#if __has_feature(objc_arc_weak) && !TARGET_OS_IPHONE
		if (nodeDelegate == [NSNull null])
			nodeDelegate = node.unsafeDelegate;
		#endif
		
		NSMethodSignature *result = [nodeDelegate methodSignatureForSelector:aSelector];
		
		if (result != nil)
		{
			return result;
		}
	}
	
	// This causes a crash...
	// return [super methodSignatureForSelector:aSelector];
	
	// This also causes a crash...
	// return nil;
	
	return [[self class] instanceMethodSignatureForSelector:@selector(doNothing)];
}

- (void)forwardInvocation:(NSInvocation *)origInvocation
{
	SEL selector = [origInvocation selector];
	BOOL foundNilDelegate = NO;
	
	for (GCDMulticastDelegateNode *node in delegateNodes)
	{
		id nodeDelegate = node.delegate;
		#if __has_feature(objc_arc_weak) && !TARGET_OS_IPHONE
		if (nodeDelegate == [NSNull null])
			nodeDelegate = node.unsafeDelegate;
		#endif
		
		if ([nodeDelegate respondsToSelector:selector])
		{
			// All delegates MUST be invoked ASYNCHRONOUSLY.
			
			NSInvocation *dupInvocation = [self duplicateInvocation:origInvocation];
			
			dispatch_async(node.delegateQueue, ^{ @autoreleasepool {
				
				[dupInvocation invokeWithTarget:nodeDelegate];
				
			}});
		}
		else if (nodeDelegate == nil)
		{
			foundNilDelegate = YES;
		}
	}
	
	if (foundNilDelegate)
	{
		// At lease one weak delegate reference disappeared.
		// Remove nil delegate nodes from the list.
		// 
		// This is expected to happen very infrequently.
		// This is why we handle it separately (as it requires allocating an indexSet).
		
		NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
		
		NSUInteger i = 0;
		for (GCDMulticastDelegateNode *node in delegateNodes)
		{
			id nodeDelegate = node.delegate;
			#if __has_feature(objc_arc_weak) && !TARGET_OS_IPHONE
			if (nodeDelegate == [NSNull null])
				nodeDelegate = node.unsafeDelegate;
			#endif
			
			if (nodeDelegate == nil)
			{
				[indexSet addIndex:i];
			}
			i++;
		}
		
		[delegateNodes removeObjectsAtIndexes:indexSet];
	}
}

```


###使用

XMPPStream为例:

```objc

@interface XMPPStream ()
{
	dispatch_queue_t xmppQueue;
	void *xmppQueueTag;
	
	dispatch_queue_t willSendIqQueue;
	dispatch_queue_t willSendMessageQueue;
	dispatch_queue_t willSendPresenceQueue;
	
	dispatch_queue_t willReceiveStanzaQueue;
	
	dispatch_queue_t didReceiveIqQueue;
    
	dispatch_source_t connectTimer;
	
	GCDMulticastDelegate <XMPPStreamDelegate> *multicastDelegate;
	
......



- (void)addDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue
{
	// Asynchronous operation (if outside xmppQueue)
	
	dispatch_block_t block = ^{
		[multicastDelegate addDelegate:delegate delegateQueue:delegateQueue];
	};
	
	if (dispatch_get_specific(xmppQueueTag))
		block();
	else
		dispatch_async(xmppQueue, block);
}

```



XMPPStream 持有一个GCDMulticastDelegate 对象,设置它为代理.并通过他来广播代理方法.