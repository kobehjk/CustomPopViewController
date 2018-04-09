//
//  PopViewController.m
//  GBQ
//
//  Created by kobehjk on 2018/2/7.
//  Copyright © 2018年 XXX Inc. All rights reserved.
//

#import "PopViewController.h"
#import "CustomPopViewController.h"

@interface PopViewController ()<PopupContentViewController,UITextFieldDelegate>
{
    UIImageView *gifView1;
    UIView *contentView;
    CGFloat Width;
    CGFloat Height;
    UIView *inputView;
    UILabel *errorInfo;
    UITextField *passwordField;
    UIButton *confirmBtn;
    NSMutableArray *images1;
}
@property (strong,nonatomic)UIView *loadingView;
@end



@implementation PopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:true];
    Width = self.view.frame.size.width;
    Height = self.view.frame.size.height;
    [self initCommonView];
    [self initInputView];

}

#pragma mark - UI Init

-(UIView *)loadingView{
    if (_loadingView == nil) {
        _loadingView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, contentView.frame.size.width, contentView.frame.size.height)];
        UILabel *info = [[UILabel alloc]initWithFrame:CGRectMake(0, _loadingView.frame.size.height/2+15, _loadingView.frame.size.width, _loadingView.frame.size.height/4)];
        info.text = @"密码校验中";
        info.textAlignment = NSTextAlignmentCenter;
        [_loadingView addSubview:info];
        [contentView addSubview:_loadingView];
    }
    return _loadingView;
}

//-(IndicatorTool *)indicator{
//    if (_indicator == nil) {
//        _indicator = [[IndicatorTool alloc]init];
//        [_indicator initViewWithView:self.loadingView center:self.loadingView.center];
//    }
//    return _indicator;
//}

-(void)initCommonView{
    gifView1 = [[UIImageView alloc]initWithFrame:CGRectMake(15, 0, Width*0.4, Width*0.4-10)];
    [gifView1 setImage:[UIImage imageNamed:@"right"]];
    [self.view addSubview:gifView1];
    
    contentView = [[UIView alloc]initWithFrame:CGRectMake(20, gifView1.frame.size.height, Width-40, Height - gifView1.frame.size.height)];
    contentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:contentView];
    contentView.layer.cornerRadius = [UIScreen mainScreen].bounds.size.height*0.006;
    contentView.layer.masksToBounds = true;
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat btnsize = contentView.frame.size.width*0.11;
    closeBtn.frame = CGRectMake(contentView.frame.origin.x+contentView.frame.size.width-btnsize/2, contentView.frame.origin.y-btnsize/2, btnsize, btnsize);
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"passwordclose"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
}

-(void)initInputView{
    inputView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, contentView.frame.size.width, contentView.frame.size.height)];
    [contentView addSubview:inputView];
    CGFloat btnSize = (contentView.frame.size.height-20)/4;
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(0, 15, inputView.frame.size.width, btnSize)];
    title.text = @"请输入工程密码";
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor blackColor];
    [inputView addSubview:title];
    
    confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmBtn.frame = CGRectMake(0, contentView.frame.size.height - btnSize, contentView.frame.size.width, btnSize);
    [confirmBtn setTitle:@"确 认" forState:UIControlStateNormal];
    [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [confirmBtn setBackgroundImage:[UIHelper createImageWithColor:[UIHelper KJColorHX:0xc7c7c7 :1]] forState:UIControlStateDisabled];
//    [confirmBtn setBackgroundImage:[UIHelper createImageWithColor:CDColor(nil,NAVIBAR_COLOR)] forState:UIControlStateNormal];
    [confirmBtn addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
    [inputView addSubview:confirmBtn];
    [confirmBtn setEnabled:false];
    
    passwordField = [[UITextField alloc]initWithFrame:CGRectMake(inputView.frame.size.width/8, title.frame.origin.y+title.frame.size.height+5, inputView.frame.size.width/8*6, btnSize)];
    if (@available(iOS 11.0, *)) {
        passwordField.textContentType = UITextContentTypePassword;
        passwordField.secureTextEntry = true;
    } else {
        passwordField.secureTextEntry = true;
    }
    passwordField.textAlignment = NSTextAlignmentCenter;
    passwordField.layer.borderWidth = 2.0;
    passwordField.layer.cornerRadius = passwordField.frame.size.height/2;
    passwordField.delegate = self;
    [inputView addSubview:passwordField];
    
    errorInfo = [[UILabel alloc]initWithFrame:CGRectMake(0, passwordField.frame.origin.y+passwordField.frame.size.height, inputView.frame.size.width, btnSize)];
    errorInfo.text = @"密码错误";
    errorInfo.textAlignment = NSTextAlignmentCenter;
    errorInfo.textColor = [UIColor redColor];
    [inputView addSubview:errorInfo];
    errorInfo.hidden = true;
}

-(void)transformLoadingView:(NSInteger )type{
    if(inputView.isHidden){
        [UIView animateWithDuration:0.2 animations:^{
            inputView.alpha = 1;
            self.loadingView.alpha = 0;
            
        } completion:^(BOOL finished) {
            inputView.hidden = false;
            self.loadingView.hidden = true;
//            [self.indicator stopShow];
            [confirmBtn setEnabled:false];
            errorInfo.hidden = false;
            if (type == 0) {
                errorInfo.text = @"密码错误";
            }else if(type == 3){
                errorInfo.text = @"连接错误，请重试";
            }
            passwordField.text = @"";
            [self initFailedImageView];
        }];
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            inputView.alpha = 0;
            self.loadingView.alpha = 1;
            
        } completion:^(BOOL finished) {
            inputView.hidden = true;
            self.loadingView.hidden = false;
//            [self.indicator startShowWithMessage:@"" moreMessage:@""];
        }];
    }
}

-(void)initFailedImageView{
    if (images1 == nil) {
        images1 = [[NSMutableArray alloc]init];
        for (int i = 0; i<4; i++) {
            [images1 addObject:[UIImage imageNamed:[NSString stringWithFormat:@"wrong%d",i+1]]];
        }
        gifView1.animationImages = images1;
        gifView1.animationDuration = 0.15f;
        gifView1.animationRepeatCount = 1;
    }
    [gifView1 setImage:[UIImage imageNamed:@"wrong5"]];
    [gifView1 startAnimating];
}

#pragma mark - Action

-(void)close{
    self.closeBlock();
}

-(void)confirm{
    self.eventBlock(passwordField.text);
}

#pragma mark - TextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (string.length > 0) {
        [confirmBtn setEnabled:true];
    }else{
        if ([string isEqualToString:@""] && textField.text.length - 1 <= 0) {
            [confirmBtn setEnabled:false];
        }
        
    }
    
    if (errorInfo.isHidden == false) {
        errorInfo.hidden = true;
    }
    [gifView1 setImage:[UIImage imageNamed:@"wrong1"]];
    return true;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    //验证
    [self confirm];
    return true;
}

#pragma mark - popDelegate
-(CGSize)sizeForPopup:(CustomPopViewController *)popupController withSize:(CGSize)size withBool:(BOOL)showingKeyboard{
    return CGSizeMake([UIScreen mainScreen].bounds.size.width*0.8, [UIScreen mainScreen].bounds.size.height/7*3);
}

@end
