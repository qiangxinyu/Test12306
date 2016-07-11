//
//  MYRootViewController.m
//  MeiYa
//
//  Created by Xinyu Qiang on 16/6/22.
//  Copyright © 2016年 Xinyu Qiang. All rights reserved.
//

#import "MYRootViewController.h"

@interface MYRootViewController ()
@property (nonatomic, assign)NSInteger moveHight;

@end

@implementation MYRootViewController
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {return 0;};
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {return 0;};

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {return nil;};
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {return nil;};


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}
- (void)dealloc
{
    [kNotificationCenter removeObserver:self];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBarHidden = YES;

    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setBackBtn];
    
    
    [self.view addSubview:self.naviBar];
    
    [self setTitleLabelText:self.title];
}

#pragma mark -------------------------------------------------------
#pragma mark Method
////////////////////////////////// 网络请求相关 ////////////////////////////////////////

- (void)endRefresh
{
    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];
    [self.collectionView.mj_header endRefreshing];
    [self.collectionView.mj_footer endRefreshing];
    
    [self.collectionView reloadData];
    [self.tableView reloadData];
}

- (void)hiddenFooter
{
    self.collectionView.mj_footer.hidden = YES;
    self.tableView.mj_footer.hidden = YES;
}
- (void)showFooter
{
    self.collectionView.mj_footer.hidden = NO;
    self.tableView.mj_footer.hidden = NO;
}

- (void)handleFooterWithCount:(NSInteger)count
{
    NSInteger is__ = count >= pageSize;
    self.page += is__;
    self.tableView.mj_footer.hidden = !is__;
    self.collectionView.mj_footer.hidden = !is__;
    
}
////////////////////////////////// 界面 相关 ////////////////////////////////////////

- (void)addTableViewIsGroup:(BOOL)isGroup
{
    UITableViewStyle style = UITableViewStylePlain;
    if (isGroup) {
        style = UITableViewStyleGrouped;
    }
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavigationBar_Height , kScreenWidth, kScreenHeight - kNavigationBar_Height) style:style];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = kDefaultBackgroudColor;
    _tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    [self.view addSubview:self.tableView];
}

- (void)addMJHeader
{
    
    WeakSelf(weakSelf);
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^(UIView *view){
        weakSelf.page = 1;
        [weakSelf.groupArray removeAllObjects];
        [weakSelf requestData];
    }];
    
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^(UIView *view){
        weakSelf.page = 1;
        [weakSelf.groupArray removeAllObjects];
        [weakSelf requestData];
    }];
    
}
- (void)addMJFooter
{
    
    WeakSelf(weakSelf);
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^(UIView *view){
        [weakSelf requestData];
    }];
    
    self.collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^(UIView *view){
        [weakSelf requestData];
    }];
}

- (void)requestData
{
    
}

- (void)addCollectionView
{
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 1;
    layout.minimumLineSpacing = 1;
    
    self.layout = layout;
    
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, kNavigationBar_Height, kScreenWidth,kScreenHeight - kNavigationBar_Height) collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = kDefaultBackgroudColor;
    [self.view addSubview:self.collectionView];
}

- (void)setBackBtn
{
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(15, 30, 40, 25);
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [btn setImage:kImage(@"back") forState:UIControlStateNormal];
    [btn setTitleColor:kNavigationBarTextColor forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(clickLeftBtn) forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.naviBar addSubview:btn];
    self.leftBtn = btn;
}

- (void)removeBackBtn
{
    [self removeView:self.leftBtn];
    
}

- (void)removeTitleLabel
{
    [self removeView:self.titleLabel];
}
- (void)removeLineView
{
    [self removeView:self.lineView];
}

- (void)setRightBtnWithText:(NSString *)text
{
    [self.rightBtn setTitle:text forState:UIControlStateNormal];
}
- (void)setRightBtnWithImageName:(NSString *)imageName
{
    _rightBtn.frame = CGRectMake(0, 0, 30, 30);
    _rightBtn.center = CGPointMake(kScreenWidth - 26, 20 + 22);
    [_rightBtn setImage:kImage(imageName) forState:UIControlStateNormal];
    
    
}
- (void)removeRightBtn
{
    [self removeView:self.rightBtn];
    
}

- (void)setTitleLabelText:(NSString *)text
{
    self.titleLabel.text = text;
}



#pragma mark -------------------------------------------------------
#pragma mark inner Method

- (void)removeView:(UIView *)view
{
    [view removeFromSuperview];
}


- (void)clickLeftBtn
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)clickRightBtn
{
    
}
#pragma mark -------------------------------------------------------
#pragma mark Text Delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self animateTextView:textView up:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self animateTextView:textView up:NO];
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextView:textField up:YES];
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextView:textField up:NO];
    
}


- (void)animateTextView:(UIView *)view up:(BOOL) up
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSInteger x = self.moveHight;
        
        if (up) {
            //键盘高度
            NSInteger keyBoard_height = 253;
            
            if ([(UITextField *)view keyboardType] == UIKeyboardTypeNumberPad) {
                keyBoard_height = 216;
            }
            
            
            CGRect frame = [view.superview convertRect:view.frame toView:kWindow];
            
            //如果 text 的视图被键盘挡住 就往上
            x = CGRectGetMaxY(frame) > kScreenHeight - keyBoard_height ? CGRectGetMaxY(frame) - kScreenHeight + keyBoard_height + 5 : 0;
            
            
            self.moveHight = x;
        }
        
        
        if (!x) {
            return ;
        }
        NSLog(@" move vc.view x = %ld",(long)x);

        NSInteger movementDistance = x; // tweak as needed
        
        const CGFloat movementDuration = 0.3f; // tweak as needed
        
        NSInteger movement = (up ? -movementDistance : movementDistance);
        
        [UIView beginAnimations: @"anim" context: nil];
        [UIView setAnimationBeginsFromCurrentState: YES];
        [UIView setAnimationDuration: movementDuration];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.view.frame = CGRectOffset(self.view.frame, 0, movement);
            
            [UIView commitAnimations];
        });
        
        
    });
}
#pragma mark -------------------------------------------------------
#pragma mark Lazy Loading
- (UIView *)naviBar
{
    if (!_naviBar) {
        _naviBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 64)];
        _naviBar.backgroundColor = kWhiteColor;
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth - 100, 20)];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = kNavigationBarTextColor;
        _titleLabel.center = CGPointMake(kScreenWidth / 2, 42);
        [_naviBar addSubview:_titleLabel];
        
        
        self.rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightBtn setTitleColor:kNavigationBarTextColor forState:UIControlStateNormal];
        _rightBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        _rightBtn.frame = CGRectMake(0, 0, 50, 25);
        _rightBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        _rightBtn.center = CGPointMake(kScreenWidth - 40, 20 + 12 + 10);
        [_rightBtn addTarget:self action:@selector(clickRightBtn) forControlEvents:UIControlEventTouchUpInside];
        [_naviBar addSubview:_rightBtn];
        
        
        UIView * lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 63, kScreenWidth, 1)];
        lineView.backgroundColor = kDefaultBackgroudColor;
        [_naviBar addSubview:lineView];
        self.lineView = lineView;
    }
    return _naviBar;
}

- (NSMutableArray *)groupArray
{
    if (!_groupArray) {
        _groupArray = @[].mutableCopy;
    }
    return _groupArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
