//
//  XYHomeViewController.m
//  TestImagesZMP
//
//  Created by 强新宇 on 16/7/11.
//  Copyright © 2016年 强新宇. All rights reserved.
//



#import "XYHomeViewController.h"
#import "XYHomeCollectionViewCell.h"
#import "UIView+MJExtension.h"
#import "XYNetTool.h"

@interface XYHomeViewController () 

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewHeight;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *resultView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *resultViewHeight;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;



@property (weak, nonatomic) IBOutlet UIImageView *saoImageView;
@property (strong, nonatomic) UIView *backgroudView1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saoImageViewTop;

@property (nonatomic, assign)BOOL  isSao;


@end


static NSString * home_cell_key = @"home_cell_key";

@implementation XYHomeViewController

+ (XYHomeViewController *)shareXYHomeViewController
{
    static XYHomeViewController * homeVC = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        homeVC = [[XYHomeViewController alloc] init];
    });
    return homeVC;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    [self addCollectionView];
    [self.collectionView removeFromSuperview];
    [self.resultView addSubview:self.collectionView];
    [self.collectionView registerNib:[UINib nibWithNibName:@"XYHomeCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:home_cell_key];
    self.collectionView.backgroundColor = kWhiteColor;
    
    
    self.imageViewHeight.constant = 190.0 / 293 * kScreenWidth;
    self.sendBtn.layer.cornerRadius = 5;
    self.sendBtn.layer.masksToBounds = YES;
    
    [self.naviBar removeFromSuperview];
    
    [self requestData];
}

#pragma mark -------------------------------------------------------------
#pragma mark Click Method

- (IBAction)clickSendBtn:(id)sender {
    [self requestStart];
    WeakSelf(weakSelf);
    [XYNetTool requestZMQWithBlock:^(NSInteger height, NSString *time, NSMutableArray *groupArray) {
        [weakSelf requestEndWith:height time:time groupArray:groupArray];
    }];
}
- (IBAction)clickRefreshBtn:(id)sender {
    self.groupArray = nil;
    [self.collectionView reloadData];
    self.imageView.image = nil;
    self.timeLabel.text = @"";

    [self requestData];
}


#pragma mark -------------------------------------------------------------
#pragma mark Inner Method

- (void)requestData
{
    WeakSelf(weakSelf);
    [XYNetTool requestDataWithBlock:^(UIImage *image) {
        weakSelf.imageView.image = image;
    }];
}



- (void)requestStart
{
    self.groupArray = nil;
    [self.collectionView reloadData];
    
    self.isSao = NO;
    self.saoImageView.mj_x = -200;
    self.saoImageView.hidden = NO;
    
    self.backgroudView1.hidden = NO;
    
    [self sao];
}

- (void)requestEndWith:(NSInteger)height time:(NSString *)time groupArray:(NSMutableArray *)groupArray
{
    
    CGRect frame = self.collectionView.frame;
    frame.size.height = height;
    self.collectionView.frame = frame;
    
    self.groupArray = groupArray;
    [self.collectionView reloadData];

    
    self.timeLabel.text = time;
    
    self.isSao = YES;
    self.saoImageView.hidden = YES;
    self.backgroudView1.hidden = YES;
}


- (void)sao
{
    if (self.isSao) {
        return;
    }
    
    WeakSelf(weakSelf);
    [UIView animateWithDuration:1 animations:^{
        weakSelf.saoImageView.mj_x = kScreenWidth - 200;
    } completion:^(BOOL finished) {
        weakSelf.saoImageView.mj_x = -200;
        [weakSelf sao];
    }];
}


#pragma mark -------------------------------------------------------------
#pragma mark Collection Data & Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.groupArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    XYHomeCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:home_cell_key forIndexPath:indexPath];
    cell.label.text = self.groupArray[indexPath.row];
    
    NSString * string = [cell.label.text componentsSeparatedByString:@":"].lastObject;
    
    cell.isSuccess = [string isEqualToString:@"66.6%"];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(kScreenWidth / 4 - 1, kScreenWidth / 4 - 1);
}


#pragma mark -------------------------------------------------------------
#pragma mark Lazy Loading

- (UIView *)backgroudView1
{
    if (!_backgroudView1) {
        _backgroudView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        _backgroudView1.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_backgroudView1];
    }
    return _backgroudView1;
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
