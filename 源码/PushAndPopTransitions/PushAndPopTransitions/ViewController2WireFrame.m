//
//  ViewController2WireFrame.m
//  PushAndPopTransitions
//
//  Created by hlj on 15/12/24.
//  Copyright © 2015年 JGDU. All rights reserved.
//


#import "ViewController2WireFrame.h"

#import "ViewController2.h"

#import "J_RightInTransition.h"

#import "J_RightOutTransition.h"

@interface ViewController2WireFrame ()<UIViewControllerTransitioningDelegate>

@property (nonatomic,weak) UIViewController  * presentVC;

@property (nonatomic,strong) J_RightOutTransition  * rightOutTransition ;


@end


@implementation ViewController2WireFrame

+(void)presentViewController2FromViewController:(UIViewController *)viewController
{
    ViewController2 * vc2 = [ViewController2 new];
    ViewController2WireFrame * vc2Wiframe = [ViewController2WireFrame new];
    vc2Wiframe.presentVC = viewController;
    vc2.wireframe = vc2Wiframe;
    
    vc2.transitioningDelegate = vc2Wiframe;
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [viewController presentViewController:vc2 animated:YES completion:^{
            
            __weak ViewController2WireFrame * weakVCWireframe = vc2Wiframe;
            
            [vc2Wiframe.rightOutTransition bindPanGestureWithView:vc2.view WithBeginBlock:^{
                __strong ViewController2WireFrame * strongVCWireframe =  weakVCWireframe;
                [strongVCWireframe dismiss];
            }];
            
        }];
    });
    
    
    
}
-(void)dismiss
{
    if (self.presentVC) {
        [self.presentVC dismissViewControllerAnimated:YES completion:NULL];
    }
}

#pragma mark - Transition delegate

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return [[J_RightInTransition alloc]init];
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return  self.rightOutTransition;
}

- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator
{
    return [self.rightOutTransition getTransition];
}


#pragma mark - setter && getter 

-(J_RightOutTransition *)rightOutTransition{
    
    if (_rightOutTransition) {
        return _rightOutTransition;
    }
    
    _rightOutTransition = [[J_RightOutTransition alloc]init];
    
    return _rightOutTransition;
}



@end
