//
//  J_RightOutTransition.h
//  PushAndPopTransitions
//
//  Created by hlj on 15/12/24.
//  Copyright © 2015年 JGDU. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface J_RightOutTransition : UIPercentDrivenInteractiveTransition<UIViewControllerAnimatedTransitioning>



@property (nonatomic,copy) void(^beginBlock)() ;


///绑定一个手势
-(void)bindPanGestureWithView:(UIView *)view WithBeginBlock:(void(^)())block;


-(id)getTransition;


@end
