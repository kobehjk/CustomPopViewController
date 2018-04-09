//
//  ViewController.m
//  CustomPop
//
//  Created by kobehjk on 2018/4/9.
//  Copyright © 2018年 kobehjk. All rights reserved.
//

#import "ViewController.h"
#import "CustomPopViewController.h"
#import "PopViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark kobehjk 2018/02/10
-(void)popPasswordInput:(NSString *)projectId :(void (^)(bool))complete{
    __block BOOL isSuccess = false;
    CustomPopViewController *custom = [[CustomPopViewController alloc]init];
    
    PopViewController *pop = [[PopViewController alloc]init];
    Options option = {center, slideUp, 0.5, true,false,true};
    custom = [[[[[CustomPopViewController create:self] customSize:option] didShowHandler:^(CustomPopViewController *controller) {
        NSLog(@"come");
    }]didCloseHandler:^(CustomPopViewController *controller) {
        complete(isSuccess);
        NSLog(@"go");
    }]publicShow:pop];
    pop.closeBlock = ^{
        isSuccess = false;
        [custom dismiss:^{
            
        }];
    };
    __weak __typeof__(PopViewController *) weakpop = pop;
    pop.eventBlock = ^(NSString *password) {
        [weakpop transformLoadingView:0];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
        });
        
    };
}


@end
