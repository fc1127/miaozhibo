//
//  XLLoginViewController.m
//  XLMiaoBo
//
//  Created by XuLi on 16/8/30.
//  Copyright © 2016年 XuLi. All rights reserved.
//

#import "XLLoginViewController.h"
#import "XLThirdLoginView.h"
#import "XLTabBarViewController.h"
#import "UMSocial.h"
//#import "UMSocialShakeService.h"
//#import "UMSocialScreenShoter.h"



@interface XLLoginViewController ()

@property (nonatomic, strong) IJKFFMoviePlayerController *player;
/** 封面图片 */
@property (nonatomic, weak) UIImageView *coverView;
/** 第三方登录 */
@property (nonatomic, weak) XLThirdLoginView *thirdView;
/** 快速登录 */
@property (nonatomic, weak) UIButton *loginBtn;

@end

@implementation XLLoginViewController


- (UIButton *)loginBtn
{
    if (_loginBtn == nil){
    
        UIButton *loginBtn = [[UIButton alloc] init];
        
        loginBtn.backgroundColor = [UIColor clearColor];
        loginBtn.titleColor = XLBasicColor;
        loginBtn.title = @"快速登录";
        loginBtn.layer.borderWidth = 1;
        loginBtn.layer.borderColor = XLBasicColor.CGColor;
        loginBtn.highlightedTitleColor = [UIColor redColor];
        
        
        [loginBtn addTarget:self action:@selector(loginClick)];
        
        [self.view addSubview:loginBtn];
        
        [loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@40);
            make.right.equalTo(@-40);
            make.bottom.equalTo(@-60);
            make.height.equalTo(@40);
        }];
        
        _loginBtn = loginBtn;
    }
    return _loginBtn;
}

- (XLThirdLoginView *)thirdView
{
    if (_thirdView == nil){
    
        XLThirdLoginView *thirdView = [[XLThirdLoginView alloc] init];
        
         __weak typeof(self) weakSelf = self;
        [thirdView setSelectedBlock:^(XLType type) {
           
            weakSelf.coverView.hidden = YES;
            
            [self.coverView removeFromSuperview];
            weakSelf.coverView = nil;
            
            switch (type) {
                case sina:
                    
                    [weakSelf sina];
                    break;
                
                case qq:
                    
                    [weakSelf qq];
                    break;
                    
                case weixin:
                    
                    [weakSelf weixin];
                    break;
                default:
                    break;
            }
            
        }];
        
        [self.view addSubview:thirdView];
        
        [thirdView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(@0);
            make.height.equalTo(@60);
            make.bottom.equalTo(self.loginBtn.mas_top).offset(-40);
        }];
        
        _thirdView = thirdView;
    }
    return _thirdView;
}

- (IJKFFMoviePlayerController *)player
{
    if (_player == nil){
        
        NSString *path = arc4random_uniform(2) ? @"login_video" : @"loginmovie";
        
        _player = [[IJKFFMoviePlayerController alloc] initWithContentURLString:[[NSBundle mainBundle] pathForResource:path ofType:@"mp4"] withOptions:[IJKFFOptions optionsByDefault]];
     
        _player.view.frame = self.view.bounds;
        _player.scalingMode = IJKMPMovieScalingModeAspectFill;
        _player.shouldAutoplay = NO;
        [_player prepareToPlay];
        
        [self.view addSubview:_player.view];
        
    }
    
    return _player;
}

- (UIImageView *)coverView
{
    if (_coverView == nil) {
        UIImageView *cover = [[UIImageView alloc] initWithFrame:self.view.bounds];
        cover.image = [UIImage imageNamed:@"LaunchImage"];
        [self.player.view addSubview:cover];
        _coverView = cover;
    }
    return _coverView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self notificationOfPlayer];
    [self coverView];
}

- (void)notificationOfPlayer
{
    // 监听视频是否播放完成
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinish) name:IJKMPMoviePlayerPlaybackDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stateDidChange) name:IJKMPMoviePlayerLoadStateDidChangeNotification object:nil];
}

- (void)stateDidChange
{
     __weak typeof(self) weakSelf = self;
    if ((self.player.loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
        if (!self.player.isPlaying) {
            
            [self.view insertSubview:self.coverView atIndex:0];
            [self.player play];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                weakSelf.thirdView.hidden = NO;
                weakSelf.loginBtn.hidden = NO;
            });
        }
    }
}

- (void)didFinish
{
    // 播放完之后, 继续重播
    [self.player play];
}

- (void)loginClick
{
    [MBProgressHUD showMessage:@"登录中..."];
    
    
    [self jump];
    
}

- (void)dealloc
{
    
    NSLog(@"weewew");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.player  play];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.player pause];
}





/** 新浪 */
- (void)sina
{
     __weak typeof(self) weakSelf = self;
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina];
    
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        
        //   获取用户名、uid、token
        if (response.responseCode == UMSResponseCodeSuccess) {
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToSina];
            NSLog(@"username is %@, uid is %@, token is %@ url is %@",snsAccount.userName,snsAccount.usid,snsAccount.accessToken,snsAccount.iconURL);
            //获取accestoken以及QQ用户信息，得到的数据在回调Block对象形参respone的data属性
            [[UMSocialDataService defaultDataService] requestSnsInformation:UMShareToSina  completion:^(UMSocialResponseEntity *response){

                
                [MBProgressHUD showSuccess:@"登陆成功"];
               
                [weakSelf jump];
            }];
        }});

}

/** 微信 */
- (void)weixin
{
     __weak typeof(self) weakSelf = self;
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToWechatSession];
    
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        
        //   获取用户名、uid、token
        if (response.responseCode == UMSResponseCodeSuccess) {
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToWechatTimeline];
            NSLog(@"username is %@, uid is %@, token is %@ url is %@",snsAccount.userName,snsAccount.usid,snsAccount.accessToken,snsAccount.iconURL);
            //获取accestoken以及QQ用户信息，得到的数据在回调Block对象形参respone的data属性
            [[UMSocialDataService defaultDataService] requestSnsInformation:UMShareToSina  completion:^(UMSocialResponseEntity *response){
                
                [MBProgressHUD showSuccess:@"登陆成功"];
                
                [weakSelf jump];
            }];
        }});

}

/** qq */
- (void)qq
{
    UMSocialSnsPlatform * snsPlatform= [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToQQ];
    
     __weak typeof(self) weakSelf = self;
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        
        //   获取微博用户名、uid、token
        if (response.responseCode == UMSResponseCodeSuccess) {
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToQQ];
            NSLog(@"username is %@, uid is %@, token is %@ url is %@",snsAccount.userName,snsAccount.usid,snsAccount.accessToken,snsAccount.iconURL);
            //获取accestoken以及QQ用户信息，得到的数据在回调Block对象形参respone的data属性
            [[UMSocialDataService defaultDataService] requestSnsInformation:UMShareToQQ  completion:^(UMSocialResponseEntity *response){
                
                [MBProgressHUD showSuccess:@"登陆成功"];
                
                [weakSelf jump];
                
                }];
        }});

}

/** 登陆成功之后跳转 */
- (void)jump
{
    XLTabBarViewController *tab = [[XLTabBarViewController alloc] init];
    
     __weak typeof(self) weakSelf = self;
    //一秒之后跳转
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [MBProgressHUD hideHUD];
        [MBProgressHUD showSuccess:@"登陆成功"];
        
        [self presentViewController:tab animated:NO completion:^{
            
            [weakSelf.player stop];
            
            [weakSelf.player shutdown];
            
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            
            [weakSelf.player.view removeFromSuperview];
                self.player = nil;
            
            [weakSelf.thirdView removeFromSuperview];
            weakSelf.thirdView = nil;
        }];
    });
    
}

@end
