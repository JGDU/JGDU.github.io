//
//  J_RightInTransition.m
//  PushAndPopTransitions
//
//  Created by hlj on 15/12/24.
//  Copyright © 2015年 JGDU. All rights reserved.
//

#import "J_RightInTransition.h"


@interface J_RightInTransition ()
{
    __weak id<UIViewControllerContextTransitioning> transitionContext;
    
    __weak UIView* fromView;
    
    __weak UIView * toView;
    
    UIView * blackShadowView;
    
}


@end

@implementation J_RightInTransition

static  NSTimeInterval const  duringTime =0.25;



#pragma mark - UIViewControllerAnimatedTransitioning delegate


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
    
    [containerView addSubview:toView];
    
    
    
    
    
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
    
    toView.frame = CGRectMake(0, 0, containerView.frame.size.width, containerView.frame.size.height);
    
    fromView.frame = CGRectMake(containerView.frame.size.width * (  -1/4.0f), 0, containerView.frame.size.width, containerView.frame.size.height);

    
    blackShadowView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    
    [UIView commitAnimations];
    
}

//动画结束的时候清理现场
-(void)didStopUIAnimation:(id)sender
{
    [blackShadowView removeFromSuperview];
    [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
}


@end
