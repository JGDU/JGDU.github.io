//
//  ViewController.m
//  PushAndPopTransitions
//
//  Created by hlj on 15/12/24.
//  Copyright © 2015年 JGDU. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:255/255.0f green:105/255.0f blue:109/255.0f alpha:1];
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [ViewController2WireFrame presentViewController2FromViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
