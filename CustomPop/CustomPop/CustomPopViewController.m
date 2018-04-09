//
//  CustomPopViewController.m
//  GBQ
//
//  Created by kobehjk on 2018/2/2.
//  Copyright © 2018年 XXX Inc. All rights reserved.
//

#import "CustomPopViewController.h"


@interface CustomPopViewController ()<UIScrollViewDelegate,UIGestureRecognizerDelegate>{
@private
    PopupLayout layout;
    PopupAnimation animation;
    CGFloat margin;
    UIScrollView *baseScrollView;
    BOOL isShowingKeyboard;
    BOOL movesAlongWithKeyboard;
    CGPoint defaultContentOffset;
}
@property (nonatomic) CGSize maximumSize;
@property (nonatomic,setter=setBackgroundStyle:) CGFloat backgroundStyle;
@property (nonatomic,setter=setScrollable:) BOOL scrollable;
@property (nonatomic,setter=setDismissWhenTaps:) BOOL dismissWhenTaps;

@end

@implementation CustomPopViewController
//@dynamic dismissWhenTaps;
#pragma mark - I/O
-(CGPoint)getOrigin:(PopupLayout)layout :(UIView *)view :(CGSize)size{
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        size = [UIScreen mainScreen].bounds.size;
    }
    CGPoint point = CGPointZero;
    
    switch (layout) {
        case top:
            point = CGPointMake((size.width - view.frame.size.width)/2, 0);
            break;
        case center:
            point = CGPointMake((size.width - view.frame.size.width)/2, (size.height-view.frame.size.height-80) / 2);
            break;
        case centerlow:
            point = CGPointMake((size.width - view.frame.size.width)/2, (size.height-view.frame.size.height-40) / 2);
            break;
        case bottom:
            point = CGPointMake((size.width - view.frame.size.width)/2, size.height-view.frame.size.height);
            break;
        default:
            break;
    }
    return point;
}

-(CGSize)maximumSize{
    return CGSizeMake([UIScreen mainScreen].bounds.size.width - margin * 2, [UIScreen mainScreen].bounds.size.height - margin * 2);
}

-(void)setBackgroundStyle:(CGFloat)alpha{
    _backgroundStyle = alpha;
    [self updateBackgroundStyle:alpha];
}

-(void)setScrollable:(BOOL)flag{
    _scrollable = flag;
    [self updateScrollable];
}

-(void)setDismissWhenTaps:(BOOL)flag{
    _dismissWhenTaps = flag;
    if (_dismissWhenTaps) {
        [self registerTapGesture];
    }
//    else{
//        [self unregisterTapGesture];
//    }
}

#pragma mark - override
- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:true];
    [self registerNotification];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:true];
    [self unregisterNotification];

}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self updateLayouts];
}

-(void)dealloc{
    [self removeFromParentViewController];
}

#pragma mark - public
+(CustomPopViewController *)create:(UIViewController *)parentViewController{
    CustomPopViewController *controller = [[CustomPopViewController alloc]init];
    [controller defaultConfigure];
//    [parentViewController addChildViewController:controller];
//    [parentViewController.view addSubview:controller.view];
//    [controller didMoveToParentViewController:parentViewController];
    [[[[[UIApplication sharedApplication] delegate] window] rootViewController] addChildViewController:controller];
    [[[[[[UIApplication sharedApplication] delegate] window]rootViewController]view] addSubview:controller.view];
    [controller didMoveToParentViewController:[[[[UIApplication sharedApplication] delegate] window]rootViewController]];
    return controller;
}

-(CustomPopViewController *)customSize:(Options)option{
    [self customOptions:option];
    return self;
}

-(CustomPopViewController *)publicShow:(UIViewController *)childController{
    [self addChildViewController:childController];
    _popupView = childController.view;
    [self configure];
    [childController didMoveToParentViewController:self];
    __weak __typeof__(self) weakself = self;
    [self show:layout :animation :^{
        defaultContentOffset = baseScrollView.contentOffset;
        weakself.showHander(weakself);
    }];
    return self;
}

-(CustomPopViewController*)didShowHandler:(void(^)(CustomPopViewController*))handler{
    self.showHander = handler;
    return self;
}

-(CustomPopViewController*)didCloseHandler:(void(^)(CustomPopViewController*))handler{
    self.closerHander = handler;
    return self;
}

-(void)dismiss:(void(^)(void))completion{
    if (isShowingKeyboard) {
        [_popupView endEditing:true];
    }
    [self closePopup:^{
        
    }];
}


#pragma mark - private
-(void)defaultConfigure{
    if (baseScrollView == nil) {
        baseScrollView = [[UIScrollView alloc]init];
    }
    self.scrollable = true;
    self.dismissWhenTaps = true;
    self.backgroundStyle = 0.4;
}

-(void)configure{
    self.view.hidden = true;
    self.view.frame = [UIScreen mainScreen].bounds;
    
    baseScrollView.frame = self.view.frame;
    [self.view addSubview:baseScrollView];
    
    _popupView.layer.cornerRadius = 8;
    _popupView.layer.masksToBounds = true;
    
    _popupView.frame = [self change:_popupView to:0 type:2];
    
    [baseScrollView addSubview:_popupView];
}

-(void)registerNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popupControllerWillShowKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popupControllerWillHideKeyboard:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popupControllerDidHideKeyboard:) name:UIKeyboardDidHideNotification object:nil];
}

-(void)unregisterNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

-(void)customOptions:(Options)option{
    layout = option.layout;
    animation = option.animation;
    self.backgroundStyle = option.blackFilter;
    self.scrollable = option.scrollable;
    self.dismissWhenTaps = option.dismissWhenTaps;
    movesAlongWithKeyboard = option.movesAlongWithKeyboard;
}

-(void)registerTapGesture{
    UITapGestureRecognizer *gestureRecognize = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapGesture:)];
    gestureRecognize.delegate = self;
    [baseScrollView addGestureRecognizer:gestureRecognize];
}

-(void)unregisterTapGesture{
    for (UIGestureRecognizer *gesture in [baseScrollView gestureRecognizers]) {
        [baseScrollView removeGestureRecognizer:gesture];
    }
}


-(void)updateLayouts{
    UIViewController *childController = self.childViewControllers.lastObject;
    SEL testSelector = @selector(sizeForPopup:withSize:withBool:);
    if ([childController respondsToSelector:testSelector]) {
        NSMethodSignature *signature = [[childController class] instanceMethodSignatureForSelector:testSelector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setTarget:childController];
        [invocation setSelector:testSelector];
        CustomPopViewController *param1 = self;
        CGSize param2 = self.maximumSize;
        BOOL param3 = isShowingKeyboard;
        [invocation retainArguments];
        [invocation invoke];
        [invocation setArgument:&param1 atIndex:2];
        [invocation setArgument:&param2 atIndex:3];
        [invocation setArgument:&param3 atIndex:4];
        
        CGSize returnSize = CGSizeMake(0, 0);
        [invocation getReturnValue:&returnSize];
        CGRect frame = _popupView.frame;
        frame.size.width = returnSize.width;
        frame.size.height = returnSize.height;
        _popupView.frame = frame;
    }else{
        return;
    }
}

-(void)updateBackgroundStyle:(CGFloat)style {
    baseScrollView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:style];
}

-(void)updateScrollable {
    [baseScrollView setScrollEnabled:_scrollable];
    baseScrollView.alwaysBounceVertical = _scrollable;
    if (_scrollable) {
        baseScrollView.delegate = self;
    }
}

-(void)popupControllerWillShowKeyboard:(NSNotification *)notification{
    isShowingKeyboard = true;
    
    if (notification.userInfo != nil) {
        CGRect rect = [[notification.userInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"]CGRectValue];
        if ([self needsToMoveFrom:rect.origin]) {
            [self move:rect.origin];
        }
    }else{
        return;
    }
}

-(void)popupControllerWillHideKeyboard:(NSNotification *)notification {
    [self back];
}

-(void)popupControllerDidHideKeyboard:(NSNotification *)notification {
    isShowingKeyboard = false;
}

// Tap Gesture
-(void)didTapGesture:(UITapGestureRecognizer *)sender {
    if (self.dismissWhenTaps) {
        [self closePopup:^{
            
        }];
    }
}

-(void)closePopup:(Completion)completion{
    __weak __typeof__(self) weakself = self;
    [self hide:animation :^{
        completion();
        [weakself didClosePopup];
    }];
}

-(void)didClosePopup{
    [_popupView endEditing:true];
    [_popupView removeFromSuperview];
    for (UIViewController *child in self.childViewControllers) {
        [child removeFromParentViewController];
    }
    [self.view setHidden:true];
    self.closerHander(self);
    [self removeFromParentViewController];
}

-(void)show:(PopupLayout)popuplay :(PopupAnimation)animation :(PopupAnimateCompletion)completion{
    UIViewController *child = self.childViewControllers.lastObject;
    if ([child conformsToProtocol:@protocol(PopupContentViewController)]) {
        CGRect frame = _popupView.frame;
        CGSize returnSize = [self sizeForPopInvoke];
        frame.size.width = returnSize.width;
        frame.size.height = returnSize.height;
        _popupView.frame = frame;
        frame.origin.x = [self getOrigin:popuplay :_popupView :CGSizeZero].x;
        _popupView.frame = frame;
        
        switch (animation) {
            case fadeIn:{
                [self fadeIn:popuplay :^{
                    completion();
                }];
                break;
            }
            case slideUp:{
                [self slideUp:popuplay :^{
                    completion();
                }];
                break;
            }
            case slideDown:{
                [self slideDown:popuplay :^{
                    completion();
                }];
                break;
            }
            default:{
                break;
            }
        }
        
    }else{
        return;
    }
    
}

-(void)hide:(PopupAnimation)animation :(Completion)completion {
    if ([self.childViewControllers.lastObject conformsToProtocol:@protocol(PopupContentViewController)]) {
        CGRect frame = _popupView.frame;
        CGSize returnSize = [self sizeForPopInvoke];
        frame.size.width = returnSize.width;
        frame.size.height = returnSize.height;
        frame.origin.x = [self getOrigin:layout :_popupView :CGSizeZero].x;
        _popupView.frame = frame;
        
        switch (animation) {
            case fadeIn:{
                [self fadeOut:^{
                    [self clean];
                    completion();
                }];
                break;
                
            }
            case slideUp:{
                [self slideOut:^{
                    [self clean];
                    completion();
                }];
                break;
            }
            case slideDown:{
                [self slideDown:^{
                    [self clean];
                    completion();
                }];
                break;
            }
            default:{
                break;
            }
        }
    }
    
    
}

-(BOOL)needsToMoveFrom:(CGPoint)origin{
    if (movesAlongWithKeyboard) {
        return (CGRectGetMaxY(_popupView.frame) + [self getOrigin:layout :_popupView :CGSizeZero].y) > origin.y;
    }else{
        return false;
    }
}

-(void)move:(CGPoint)origin{
    if ([self.childViewControllers.lastObject conformsToProtocol:@protocol(PopupContentViewController)]) {
        
        CGRect frame = _popupView.frame;
        CGSize returnSize = [self sizeForPopInvoke];
        frame.size.width = returnSize.width;
        frame.size.height = returnSize.height;
        _popupView.frame = frame;
        
        [baseScrollView setContentInset:UIEdgeInsetsMake(origin.y - _popupView.frame.size.height, 0, 0, 0)];
        defaultContentOffset = baseScrollView.contentOffset;
    }else{
        return;
    }
    
}

-(void)back{
    if ([self.childViewControllers.lastObject conformsToProtocol:@protocol(PopupContentViewController)]) {
        
        CGRect frame = _popupView.frame;
        CGSize returnSize = [self sizeForPopInvoke];
        frame.size.width = returnSize.width;
        frame.size.height = returnSize.height;
        _popupView.frame = frame;
        
        [baseScrollView setContentInset:UIEdgeInsetsMake([self getOrigin:layout :_popupView :CGSizeZero].y, 0, 0, 0)];
        defaultContentOffset = baseScrollView.contentOffset;
        
    }else{
        return;
    }
    
}

-(void)clean{
    [_popupView endEditing:true];
    [_popupView removeFromSuperview];
    [baseScrollView removeFromSuperview];
    
}

#pragma mark - animation
-(void)fadeIn:(PopupLayout)locallayout :(Completion)completion{
    [baseScrollView setContentInset:UIEdgeInsetsMake([self getOrigin:locallayout :_popupView :CGSizeZero].y, 0, 0, 0)];
    [self.view setHidden:false];
    _popupView.alpha = 1.0;
    _popupView.transform = CGAffineTransformMakeScale(0.9, 0.9);
    baseScrollView.alpha = 0.0;
    
    [UIView animateWithDuration:0.3 delay:0.1 options:UIViewAnimationOptionTransitionNone animations:^{
        _popupView.alpha = 1.0;
        baseScrollView.alpha = 1.0;
        _popupView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:^(BOOL finished) {
        completion();
    }];
    
}
-(void)slideUp:(PopupLayout)locallayout :(Completion)completion{
    [baseScrollView setContentInset:UIEdgeInsetsMake([self getOrigin:locallayout :_popupView :CGSizeZero].y, 0, 0, 0)];
    [self.view setHidden:false];
    baseScrollView.backgroundColor = [UIColor clearColor];
    [baseScrollView setContentOffset:CGPointMake(0, -[UIScreen mainScreen].bounds.size.height)];
    
    [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self updateBackgroundStyle:_backgroundStyle];
        [baseScrollView setContentOffset:CGPointMake(0, -[self getOrigin:locallayout :_popupView :CGSizeZero].y)];
        defaultContentOffset = baseScrollView.contentOffset;
        
    } completion:^(BOOL finished) {
        completion();
    }];
    
}
-(void)slideDown:(PopupLayout)locallayout :(Completion)completion{
    [baseScrollView setContentInset:UIEdgeInsetsMake([self getOrigin:locallayout :_popupView :CGSizeZero].y, 0, 0, 0)];
    [self.view setHidden:false];
    baseScrollView.backgroundColor = [UIColor clearColor];
    [baseScrollView setContentOffset:CGPointMake(0, _popupView.frame.size.height)];
    
    [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self updateBackgroundStyle:_backgroundStyle];
        [baseScrollView setContentOffset:CGPointMake(0, -[self getOrigin:locallayout :_popupView :CGSizeZero].y)];
        defaultContentOffset = baseScrollView.contentOffset;
        
    } completion:^(BOOL finished) {
        completion();
    }];
    
}
-(void)fadeOut:(Completion)completion{
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionTransitionNone animations:^{
        _popupView.alpha = 0.0;
        baseScrollView.alpha = 0.0;
        _popupView.transform = CGAffineTransformMakeScale(0.9, 0.9);
    } completion:^(BOOL finished) {
        completion();
    }];
    
}
-(void)slideOut:(Completion)completion{
    [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self updateBackgroundStyle:_backgroundStyle];
        _popupView.frame = [self change:_popupView to: [UIScreen mainScreen].bounds.size.height type:2];
        baseScrollView.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        completion();
    }];
    
}

-(void)slideDown:(Completion)completion{
    
    [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        _popupView.frame = [self change:_popupView to: _popupView.frame.size.height-_popupView.frame.origin.y type:2];
        baseScrollView.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        completion();
    }];
    
}

#pragma mark - UIScrollViewDelegate methods
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat delta = defaultContentOffset.y - scrollView.contentOffset.y;
    if (delta > 20 && isShowingKeyboard) {
        [_popupView endEditing:true];
        return;
    }
    
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    CGFloat delta = defaultContentOffset.y - scrollView.contentOffset.y;
    if (delta > 50) {
//        [baseScrollView setContentInset:UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0)];
        animation = slideUp;
//        [self closePopup:^{
//
//        }];
    }
    
}

#pragma mark - UIGestureRecognizerDelegate methods
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    return gestureRecognizer.view == touch.view;
}
#pragma mark - Tools methods
-(CGRect)change:(UIView *)view to:(CGFloat)value type:(NSInteger)type{
    CGRect frame = view.frame;
    if (type == 1) {
        frame.origin.x = value;
    }
    if (type == 2) {
        frame.origin.y = value;
    }
    if (type == 3) {
        frame.size.width = value;
    }
    if (type == 4) {
        frame.size.height = value;
    }
    return frame;
}

-(CGSize)sizeForPopInvoke{
    UIViewController *childController = self.childViewControllers.lastObject;
    SEL testSelector = @selector(sizeForPopup:withSize:withBool:);
    if ([childController respondsToSelector:testSelector]) {
        NSMethodSignature *signature = [[childController class] instanceMethodSignatureForSelector:testSelector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setTarget:childController];
        [invocation setSelector:testSelector];
        CustomPopViewController *param1 = self;
        CGSize param2 = self.maximumSize;
        BOOL param3 = isShowingKeyboard;
        [invocation retainArguments];
        [invocation invoke];
        [invocation setArgument:&param1 atIndex:2];
        [invocation setArgument:&param2 atIndex:3];
        [invocation setArgument:&param3 atIndex:4];
    
        CGSize returnSize = CGSizeMake(0, 0);
        [invocation getReturnValue:&returnSize];
        return returnSize;
    }else{
        return CGSizeZero;
    }
}

@end
