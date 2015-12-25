---
layout:     post
title:      手把手教你实现控制器转场动画
date:       2015-03-23 15:31:19
author:     haolj
summary:   
categories: 交互动画
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


##第二天

上午,产品经理出院了,他看了效果后觉得可以加一个类似边缘侧滑的手势用于返回,帅气的程序猿觉得很有道理,并且又将产品经理送回了医院.然后着手开发.

控制转场动画的进度 需要一个实现  _` <UIPercentDrivenInteractiveTransition>`_ 协议,来控制进度, 苹果官方建议: 可以使用实现 _`<UIViewControllerAnimatedTransitioning>`_ 协议的那个类.并且提供了一个名为 `UIPercentDrivenInteractiveTransition `  的类 , 它已经实现了该协议. 

`UIPercentDrivenInteractiveTransition` 对UI动画支持的很好, 当你想要使用CA动画的话,你可能需要使用 [SCPercentDrivenInteractiveTransition][2],

ok  将刚才实现的类的父类改为 `:UIPercentDrivenInteractiveTransition` 

接下来大概是下面这些步骤:

* 1 在上面的视图上添加一个手势.

{% highlight objc %}

///绑定一个手势
-(void)bindPanGestureWithView:(UIView *)view WithBeginBlock:(void(^)())block;
{
    navContoller = (UIViewController *)[view nextResponder];
    UIScreenEdgePanGestureRecognizer * screenEdgepanGesture = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(panBack:)];
    
    screenEdgepanGesture.edges = UIRectEdgeLeft;
    
    
    screenEdgepanGesture.delegate = self;
    
    self.beginBlock = block;
    
    [view addGestureRecognizer:screenEdgepanGesture];
    
}


{% endhighlight %}


* 2 手势开始的时候,执行开始转场动画.

* 3 通过手势的进度控制动画的进度.

* 4 手势结束的时候,根据加速度开判断要取消交互动画,还是完成它.

{% highlight objc %}

-(void)panBack:(UIScreenEdgePanGestureRecognizer *)pan
{
    
    UIView * view = pan.view;
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        {
            panBegin = YES;
            
            if (!self.beginBlock) {
                [NSException exceptionWithName:@"missing Block" reason:@"Block is require here" userInfo:nil];
            }
            
            self.beginBlock();
            
            return;
        }

        case UIGestureRecognizerStateChanged:
        {
            CGFloat translation = [pan translationInView:view].x;
            
            CGFloat presenter = translation/CGRectGetWidth(view.bounds);
            
            [self updateInteractiveTransition:presenter];
            return;
        }
        case UIGestureRecognizerStateEnded:
        {
            panBegin = NO;
            
            if ([pan velocityInView:view].x>0 ) {
                [self finishInteractiveTransition];
            }else{
                [self cancelInteractiveTransition];
            }
            return;
        }
            break;
            
        default:
            break;
    }
}


{% endhighlight %}



此外我们要在使用的时候也要添加一个代理方法

{% highlight objc %}

- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator
{
    return [self.rightOutTransition getTransition];
}

{% endhighlight %}


上面的代码很容易理解,添加完交互的源码可以在 [这里][3] 下载

##注意:

导航控制器默认被添加了屏幕侧滑手势,当模态出一个导航控制器,有可能就直接执行我们添加的手势,一下全部返回,所以应当做一些处理:

{% highlight objc %}

#pragma mark -  gestureRecognizer delegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([navContoller isKindOfClass:[UINavigationController class]]&&((UINavigationController *)navContoller).viewControllers.count>1) {
        return NO;
    }
    
    return YES;
}

{% endhighlight %}

这样问题就被解决了.


  ![presentWithPushPop2]({{site.url}}/source/presentWithPushPop2.gif)




[1]: https://github.com/jianAjian/PushAndPopTransitions/tree/master

[2]: https://github.com/stringcode86/UIPercentDrivenInteractiveTransitionWithCABasicAnimation/blob/master/InteractiveTransition/SCPercentDrivenInteractiveTransition.h

[3]:https://github.com/jianAjian/PushAndPopTransitions/tree/InteractionAdded
