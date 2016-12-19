//
//  XLHotViewController.m
//  XLMiaoBo
//
//  Created by XuLi on 16/8/31.
//  Copyright © 2016年 XuLi. All rights reserved.
//

#import "XLHotViewController.h"
#import "XLHotTableViewCell.h"
#import "XLHotHeaderCell.h"
#import "XLLiveTool.h"
#import "XLHotData.h"
#import "XLHotModel.h"
#import "XLHotHeaderModel.h"
#import "XLCrownRankViewController.h"
#import "XLWatchLiveViewController.h"

@interface XLHotViewController ()
/** 当前页 */
@property(nonatomic, assign) NSUInteger currentPage;
/** 直播 */
@property(nonatomic, strong) NSMutableArray *allModels;
/** 广告 */
@property(nonatomic, strong) NSMutableArray *headerModels;

/** 返回数据 */
@property (nonatomic, strong) XLHotData *hotData;

@property (nonatomic, strong) NSArray *imageArray;
@end

static NSString *reuseIdentifier = @"cell";
static NSString *headerReuseIdentifier = @"headerCell";
@implementation XLHotViewController

- (NSArray *)imageArray
{
    if (_imageArray == nil){
    
        _imageArray = @[[UIImage imageNamed:@"reflesh1_60x55"], [UIImage imageNamed:@"reflesh2_60x55"], [UIImage imageNamed:@"reflesh3_60x55"]];
    }
    return _imageArray;
}

- (NSMutableArray *)headerModels
{
    if (_headerModels == nil){
        
        _headerModels = [NSMutableArray array];
    }
    return _headerModels;
}

- (NSMutableArray *)allModels
{
    if (_allModels == nil) {
        _allModels = [NSMutableArray array];

    }
    return _allModels;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self refresh];
    
    //注册Cell
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([XLHotTableViewCell class]) bundle:nil] forCellReuseIdentifier:
     reuseIdentifier];
    [self.tableView registerClass:[XLHotHeaderCell class] forCellReuseIdentifier:headerReuseIdentifier];
}

- (void)refresh
{
    [self loadHeaderData];
    
    MJRefreshGifHeader *header = [MJRefreshGifHeader headerWithRefreshingBlock:^{
     
        self.currentPage = 1;
        
        
        [self.allModels removeAllObjects];
        
        // 获取顶部的广告
        [self loadHeaderData];
        [self loadNewData];
        
    }];
    
    self.tableView.mj_header = header;
    
    [header setImages:self.imageArray  forState:MJRefreshStateRefreshing];
    [header setImages:self.imageArray  forState:MJRefreshStatePulling];
    [header setImages:self.imageArray  forState:MJRefreshStateIdle];

    
    
    
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        
        self.currentPage++;
        
        [self loadHeaderData];
        [self loadNewData];
        
    }];
    
    
    [self.tableView.mj_header beginRefreshing];

    
}

- (void)loadHeaderData
{
    
    [XLLiveTool GetWithSuccess:^(XLHotHeaderResult *result) {
        
        [self.headerModels addObjectsFromArray:result.data];
    
        [self.allModels insertObject:self.headerModels atIndex:0];
        
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        
        [MBProgressHUD showAlertMessage:@"网络异常"];
    }];
}

- (void)loadNewData
{
    [XLLiveTool GetWithHotURL:self.currentPage success:^(XLNewResult *result) {
        
        XLHotData *hotData = [XLHotData mj_objectWithKeyValues:result.data];
        self.hotData = hotData;
        
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        
        if (hotData.list){
            
            [self.allModels addObjectsFromArray:hotData.list];
            
        }else{
            
            [MBProgressHUD showAlertMessage:@"暂时没有更多的数据"];
            self.currentPage--;
        }
        //重新加载
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        self.currentPage--;
        
        [MBProgressHUD showAlertMessage:@"网络异常"];
    }];

}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.allModels.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        
        XLHotHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:headerReuseIdentifier];
        
        if(!cell){
            
            cell = [[XLHotHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:headerReuseIdentifier];
        }
        
        if (!self.headerModels){
            
            cell.userInteractionEnabled = NO;
            
        }else{
            
            cell.userInteractionEnabled = YES;
            
            cell.headerModels = self.allModels[indexPath.item];
            
            [cell setImageClickBlock:^(XLHotHeaderModel *headerModel) {
                
                if (headerModel.link.length) {
                    
                    XLCrownRankViewController *web = [[XLCrownRankViewController alloc] init];
                    
                    web.urlStr = headerModel.link;
                    web.navigationItem.title = headerModel.title;
                    
                    [self.navigationController pushViewController:web animated:YES];

        }
    }];
            
        }

    return cell;
    }
    
    XLHotTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (self.allModels.count) {
        
        
        XLHotModel *hotModel = self.allModels[indexPath.item];
        
        cell.hotModel = hotModel;
        cell.allModels = self.hotData.list;
        cell.parentVC = self;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XLHotTableViewCell *cell = [XLHotTableViewCell tableViewCell];
    
    if (indexPath.row == 0) {
        
        return 100;
    }else{
        
        cell.hotModel = self.allModels[indexPath.item];
    }
    
    return cell.height;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XLWatchLiveViewController *watch = [[XLWatchLiveViewController alloc] init];
    
    XLHotModel *hotModel = self.allModels[indexPath.item];
    watch.hotModel = hotModel;
    watch.allModels = self.hotData.list;
    
    XLHotTableViewCell *cell = [XLHotTableViewCell tableViewCell];
    cell.hotModel = hotModel;
    watch.image = cell.bigPicView.image;
    
    [self presentViewController:watch animated:YES completion:nil];
}

@end
