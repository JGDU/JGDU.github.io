//
//  J_RightOutTransition.m
//  PushAndPopTransitions
//
//  Created by hlj on 15/12/24.
//  Copyright © 2015年 JGDU. All rights reserved.
//

#import "J_RightOutTransition.h"


@interface J_RightOutTransition() <UIGestureRecognizerDelegate>
{
    __weak id<UIViewControllerContextTransitioning> transitionContext;
    
    __weak UIView* fromView;
    
    __weak UIView * toView;
    
    __weak UIViewController * navContoller;
    
    BOOL panBegin;
    
    UIView * blackShadowView;
    
}

@end

@implementation J_RightOutTransition

static  NSTimeInterval const  duringTime =0.25;
//static  NSTimeInterval const  duringTime =2.5;



#pragma mark - UIViewControllerAnimatedTransitioning delegate


- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return duringTime;
}

- (void)animationEnded:(BOOL) transitionCompleted
{
    if (transitionCompleted) {
        
    }
}
// This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext_
{
    transitionContext = transitionContext_;
    
    UIView * containerView =   transitionContext.containerView;
    
    UIViewController * fromViewContoller = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIViewController * toViewController =[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    toView =[toViewController view];
    
    fromView = [fromViewContoller view];
    
    [containerView insertSubview:toView atIndex:0];
    
    
    
    
    
    toView.frame = CGRectMake(- toView.frame.size.width /4.0f, 0, toView.frame.size.width, toView.frame.size.height);
    
    blackShadowView = [[UIView alloc]init];
    
    blackShadowView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    blackShadowView.frame = toView.bounds;
    
    [toView addSubview:blackShadowView];
    //首尾式动画
    [UIView beginAnimations:nil context:nil];
    //执行动画
    //设置动画执行时间
    [UIView setAnimationDuration:duringTime];
    //设置代理
    [UIView setAnimationDelegate:self];
    
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    //设置动画执行完毕调用的事件
    [UIView setAnimationDidStopSelector:@selector(didStopUIAnimation:)];
    
    fromView.frame = CGRectMake(fromView.frame.size.width, 0, fromView.frame.size.width, fromView.frame.size.height);
    
    toView.frame = CGRectMake(0, 0, toView.frame.size.width, toView.frame.size.height);
    
    blackShadowView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
    
    [UIView commitAnimations];
    
}


#pragma mark - UI动画delegate

-(void)didStopUIAnimation:(id)sender
{
    [blackShadowView removeFromSuperview];
    [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
}





#pragma mark - ------------手势相关------
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

-(id)getTransition
{
    return  panBegin?self:nil;
}


#pragma mark -  gestureRecognizer delegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([navContoller isKindOfClass:[UINavigationController class]]&&((UINavigationController *)navContoller).viewControllers.count>1) {
        return NO;
    }
    
    return YES;
}




@end
