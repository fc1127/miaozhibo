//
//  XLUserInfoView.m
//  XLMiaoBo
//
//  Created by XuLi on 16/8/31.
//  Copyright © 2016年 XuLi. All rights reserved.
//

#import "XLUserInfoView.h"
#import "XLDealData.h"

@interface XLUserInfoView ()

@property (weak, nonatomic) IBOutlet UIImageView *coverView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *careNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *fansNumLabel;
@property (weak, nonatomic) IBOutlet UIView *userView;
@property (weak, nonatomic) IBOutlet UIButton *care;

@property (nonatomic, strong) XLHotModel *hotModel;
@property (nonatomic, weak) XLUserInfoView *userInfoView;
@property (nonatomic, weak) UIView *myView;
@end
@implementation XLUserInfoView

+ (instancetype)userInfoView
{
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].lastObject;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.careNumLabel.text = [NSString stringWithFormat:@"%d", arc4random_uniform(5000) + 500];
    self.fansNumLabel.text = [NSString stringWithFormat:@"%d", arc4random_uniform(30000) + 500];
    self.userView.layer.cornerRadius = 10;
    self.userView.layer.masksToBounds = YES;
}

- (void)userWithHotModel:(XLHotModel *)hotModel ofView:(UIView *)view
{
    self.hotModel = hotModel;
    self.myView = view;
    
    for (XLHotModel *hotModel1 in [XLDealData shareDealData].allModels) {
        
        if ([hotModel.roomid isEqual:hotModel1.roomid]){
            
            self.care.selected = YES;
        }
        
    }
    
    if ([[XLDealData shareDealData].allModels containsObject:hotModel]){
        
        self.care.selected = YES;
    }
    
    self.nickNameLabel.text = hotModel.myname;
    
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:hotModel.bigpic] options:SDWebImageDownloaderUseNSURLCache progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.coverView.image = [UIImage circleImage:image borderColor:[UIColor whiteColor] borderWidth:1];
        });
    }];

    self.coverView.layer.cornerRadius = self.coverView.width / 2;
    self.coverView.layer.masksToBounds = YES;
 
    
    if (self.userInfoView) return;
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    self.width = view.width;
    self.center = [UIApplication sharedApplication].keyWindow.center;
    
    view.userInteractionEnabled = NO;
    
    self.transform = CGAffineTransformMakeScale(0.01, 0.01);
    
    [UIView animateWithDuration:0.5 animations:^{
        
        self.transform = CGAffineTransformIdentity;
    }];
    
    self.userInfoView = self;
}


- (IBAction)care:(UIButton *)sender {
 
    sender.selected = !sender.selected;
    
    if (sender.selected){
        
        [[XLDealData shareDealData] saveData:_hotModel];
        [MBProgressHUD showSuccess:@"关注成功"];
    }else{
        
        [[XLDealData shareDealData] unsaveData:_hotModel];
        [MBProgressHUD showSuccess:@"取消关注成功"];
    }
}

- (IBAction)tipoffs {
    
    [MBProgressHUD showSuccess:@"举报成功"];
}

- (IBAction)close {
    
    self.myView.userInteractionEnabled = YES;
    [UIView animateWithDuration:0.5 animations:^{
        self.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        self.userInfoView = nil;
    }];

}
- (IBAction)watchLive {
    
    [self close];
    
    if (self.selectedBlock){
        
        self.selectedBlock();
    }
}

@end
