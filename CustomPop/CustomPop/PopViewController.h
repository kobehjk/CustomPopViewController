//
//  PopViewController.h
//  GBQ
//
//  Created by kobehjk on 2018/2/7.
//  Copyright © 2018年 XXX Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^Close)(void);
typedef void (^EventHandler)(NSString *);

@interface PopViewController : UIViewController
@property (nonatomic)Close closeBlock;
@property (nonatomic)EventHandler eventBlock;

-(void)transformLoadingView:(NSInteger )type;
-(void)close;
@end
