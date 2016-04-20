//
//  ViewController2.m
//  PushAndPopTransitions
//
//  Created by hlj on 15/12/24.
//  Copyright © 2015年 JGDU. All rights reserved.
//

#import "ViewController2.h"

@implementation ViewController2

-(void)loadView
{
   [[NSBundle mainBundle]loadNibNamed:@"ViewController2" owner:self options:nil];
}
//
- (void)viewDidLoad {
    
    [super viewDidLoad];

    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.wireframe dismiss];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
