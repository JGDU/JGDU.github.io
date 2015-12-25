---
layout:     post
title:      张进福教你实现控制器转场动画
date:       2015-03-23 15:31:19
author:     Jacob Tomlinson
summary:    Carte Noire is a dark blog theme for Jekyll focusing on a clear reading experience.
categories: jekyll
thumbnail:  heart
tags:
 - welcome
 - to
 - carte
 - noire
---



UIKit框架为我们提供了强大的页面切换的功能,无论是导航控制器的push和pop,还是控制器的模态.在带给我们方便的同时,也允许我们定制这些转场动画.

_`<UIViewControllerAnimatedTransitioning>`_  该协议是自定义这个动画对象所必须实现的:


{% highlight  objc %}
-(NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return duringTime;
}
{% endhighlight %}

实现上面的方法返回一个转场时间.

{% highlight objc %}
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext_
{
///
}
{% endhighlight %}

上面的方法就是自定义转场动画的地方. 方法中提供提供了一个 transitionContext_ 对象.该对象提供另一些对象比如源控制器,目的控制器,等等.

就像你经常去吃羊肉泡馍,但是老板总是把馍泡得太久,变得不好吃,终于有一天你对老板说,我要自己泡,于是服务员端给你一些羊肉汤,和炸好的馍. ``transitionContext_`` 就是那个服务员了.

值得注意的是,在自定义动画执行完成后,服务员不会自动清理,你要让他去要清理现场,如下:

{% highlight objc %}
    [transitionContext completeTransition:YES];

{% endhighlight %}

{% highlight objc %}
- (void)animationEnded:(BOOL) transitionCompleted
{
}
{% endhighlight %}

这个是动画完成后回调的一样方法.


###一个小例子:

从前有个帅气的程序猿和一只产品狗生活在一起;

突然有一天,产品狗对可爱帅气的程序猿说:

你的程序有个bug,页面切换的时候有的时候从下面出来,有的时候从右边出来,我的狗眼都快被恍瞎了.

一番激烈的讨论后,程序猿也觉得,可能的确是个问题,不过他了解过上面的知识,并且有自信在产品狗出院前解决这个问题.

果然我们可爱帅气机智完美的程序猿很快解决了这个问题,这里是他的代码

动画部分主要分为三部分,原页面移动,新页面移动,原页面变暗

下面的代码可以再这里下载 [源码][1]

{% highlight objc %}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return duringTime;
}


- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext_
{
    transitionContext = transitionContext_;
    
    UIView * containerView =   transitionContext.containerView;
    
    UIViewController * fromViewContoller = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIViewController * toViewController =[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    toView =[toViewController view];
    
    fromView = [fromViewContoller view];
    /// containerView  默认已经添加了fromView
	/// 只需要添加 toView
    [containerView addSubview:toView];
    
    
    
    ///添加阴影
    blackShadowView = [[UIView alloc]init];
    blackShadowView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
    blackShadowView.frame = containerView.bounds;
    [fromView addSubview:blackShadowView];
    
    
    toView.frame = CGRectMake(containerView.frame.size.width, 0, containerView.frame.size.width, containerView.frame.size.height);

    
    [UIView beginAnimations:nil context:nil];
    //执行动画
    [UIView setAnimationDuration:duringTime];
    //设置代理
    [UIView setAnimationDelegate:self];
    
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    [UIView setAnimationDidStopSelector:@selector(didStopUIAnimation:)];
    ///---动画1 目的视图位移
    toView.frame = CGRectMake(0, 0, containerView.frame.size.width, containerView.frame.size.height);
    ///---动画2 源视图位移
    fromView.frame = CGRectMake(containerView.frame.size.width * (  -1/4.0f), 0, containerView.frame.size.width, containerView.frame.size.height);

    //---动画3 变暗
    blackShadowView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    
    [UIView commitAnimations];
    
}

//动画结束的时候清理现场
-(void)didStopUIAnimation:(id)sender
{
	//移除遮罩层
    [blackShadowView removeFromSuperview];
    //通知转场完成 -- 清理现场
    [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
}


{% endhighlight %}


效果大概是这样子的


  ![presentWithPushPop1]({{site.url}}/source/presentWithPushPop1.gif)






[1]: 