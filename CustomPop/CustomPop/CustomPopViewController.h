//
//  CustomPopViewController.h
//  GBQ
//
//  Created by kobehjk on 2018/2/2.
//  Copyright © 2018年 XXX Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CustomPopViewController;

@protocol PopupContentViewController

-(CGSize)sizeForPopup:(CustomPopViewController*)popupController withSize:(CGSize)size withBool:(BOOL)showingKeyboard;

@end

typedef void (^PopupAnimateCompletion)(void);
typedef void (^ClosedHandler)(CustomPopViewController *);
typedef void (^ShowedHandler)(CustomPopViewController *);
typedef void (^Completion)(void);
typedef void (^PopupAnimateCompletion)(void);
///view position
typedef enum : NSUInteger {
    top = 0,
    center,
    centerlow,
    bottom
} PopupLayout;

///view animation
typedef enum : NSUInteger {
    fadeIn = 0,
    slideUp,
    slideDown
} PopupAnimation;

///view backgroundStyle

typedef struct PopupCustomOption {
    PopupLayout layout;
    PopupAnimation animation;
    CGFloat blackFilter;
    BOOL scrollable;
    BOOL dismissWhenTaps;
    BOOL movesAlongWithKeyboard;
}Options;

@interface CustomPopViewController : UIViewController

@property(strong,nonatomic)UIView *popupView;
@property(strong,nonatomic)ClosedHandler closerHander;
@property(strong,nonatomic)ShowedHandler showHander;
@property (nonatomic) Options options;

+(CustomPopViewController *)create:(UIViewController *)parentViewController;
-(CustomPopViewController *)customSize:(Options)option;
-(CustomPopViewController *)publicShow:(UIViewController *)childController;
-(CustomPopViewController*)didShowHandler:(void(^)(CustomPopViewController*))handler;
-(CustomPopViewController*)didCloseHandler:(void(^)(CustomPopViewController*))handler;
-(void)dismiss:(void(^)(void))completion;



@end
