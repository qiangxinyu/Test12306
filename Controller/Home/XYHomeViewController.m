//
//  XYHomeViewController.m
//  TestImagesZMP
//
//  Created by 强新宇 on 16/7/11.
//  Copyright © 2016年 强新宇. All rights reserved.
//



#import "XYHomeViewController.h"
#import "ZMQObjC.h"
#import "XYHomeCollectionViewCell.h"
#import "UIView+MJExtension.h"

@interface XYHomeViewController () <NSURLConnectionDataDelegate>
@property (nonatomic, strong)NSMutableData * data;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewHeight;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *resultView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *resultViewHeight;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;


@property (nonatomic, strong)NSDate * date;

@property (weak, nonatomic) IBOutlet UIImageView *saoImageView;
@property (strong, nonatomic) UIView *backgroudView1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saoImageViewTop;

@property (nonatomic, assign)BOOL  isSao;


@end

static NSString * ZMQ_TCP = @"tcp://123.57.1.120:8163";
static NSString * Image_URL = @"http://kyfw.12306.cn/otn/passcodeNew/getPassCodeNew?module=login&rand=sjrand&0.905792899211612";

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

- (IBAction)clickSendBtn:(id)sender {
    [self requestZMQ];
}
- (IBAction)clickRefreshBtn:(id)sender {
    [self requestData];
}

- (void)requestData
{
    [GPProgress show];
    self.data = nil;
    
    self.groupArray = nil;
    [self.collectionView reloadData];
    self.imageView.image = nil;
    self.timeLabel.text = @"";

    
    NSURL * url = [NSURL URLWithString:Image_URL];
    
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection connectionWithRequest:request delegate:self];

}


- (NSURL *)getImageURL
{
    
    NSURL * documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:@"image.png"];
   
    return documentsDirectoryURL;
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

- (void)requestZMQ
{
    
    
    self.groupArray = nil;
    [self.collectionView reloadData];

    self.isSao = NO;
    self.saoImageView.mj_x = -200;
    self.saoImageView.hidden = NO;
    
    self.backgroudView1.hidden = NO;

    [self sao];
    
    //为了体现高科技 延时1秒 ，没其他任何 作用 不要疑惑
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        self.date = [NSDate date];

        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            // Do any additional setup after loading the view, typically from a nib.
            //  Socket to talk to clients
            ZMQContext *ctx = [[ZMQContext alloc] initWithIOThreads:1];
            ZMQSocket *requester = [ctx socketWithType:ZMQ_REQ];
            
            BOOL didConnect = [requester connectToEndpoint:ZMQ_TCP];
            if (!didConnect) {
                NSLog(@"*** Failed to connect to endpoint [%@].", ZMQ_TCP);
            }
            int kMaxRequest = 10;
            
            
            NSString * imageStr = [self.data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
            
            imageStr =  [imageStr stringByReplacingOccurrencesOfString:@"\\s*" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, imageStr.length)];
            
            NSData *request = [imageStr dataUsingEncoding:NSUTF8StringEncoding];
            
            for (int request_nbr = 0; request_nbr < kMaxRequest; ++request_nbr) {
                
                [requester sendData:request withFlags:0];
                
                NSLog(@"Sending request %d.", request_nbr);
                
                NSData *reply = [requester receiveDataWithFlags:0];
                NSString *text = [[NSString alloc] initWithData:reply encoding:NSUTF8StringEncoding];
                NSLog(@"Received reply %d: %@", request_nbr, text);
                
                if (text) {
                    
                    NSArray * array = [text componentsSeparatedByString:@","];
                    
                    for (NSString * string in array) {
                        NSArray * array1 = [string componentsSeparatedByString:@"|"];
                        NSLog(@" -- %@",array1);
                        
                        NSString * newStr = @"";
                        
                        for (NSString * string1 in array1) {
                            
                            NSString * result = [string1 componentsSeparatedByString:@"_"].firstObject;
                            
                            NSNumberFormatter *nFormat = [[NSNumberFormatter alloc] init];
                            [nFormat setNumberStyle:NSNumberFormatterDecimalStyle];
                            [nFormat setMaximumFractionDigits:2];
                            result = [NSString stringWithFormat:@"%@%%",[nFormat stringFromNumber:@(result.doubleValue * 100)]];
                            
                            newStr = [newStr stringByAppendingFormat:@"\n%@",[NSString stringWithFormat:@"%@:%@",[string1 componentsSeparatedByString:@"_"].lastObject,result]];
                            
                        }
                        
                        newStr = [newStr stringByReplacingOccurrencesOfString:@"^\n" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, newStr.length)];
                        
                        [self.groupArray addObject:newStr];
                    }
                    
                    NSInteger height = (self.groupArray.count / 4 + (self.groupArray.count % 4 ? 1 : 0)) ;
                    
                    height = height * kScreenWidth / 4;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        self.resultViewHeight.constant = height;
                        
                        CGRect frame = self.collectionView.frame;
                        frame.size.height = height;
                        self.collectionView.frame = frame;
                        
                        [self.collectionView reloadData];
                        
                        
                        double deltaTime = [[NSDate date] timeIntervalSinceDate:self.date];
                        NSLog(@"cost time = %f", deltaTime);
                        self.timeLabel.text = [NSString stringWithFormat:@"%.fms",deltaTime * 1000];
                        
                        self.isSao = YES;
                        self.saoImageView.hidden = YES;
                        self.backgroudView1.hidden = YES;
                        
                    });
                    
                    return ;
                }
            }
            
            
        });
        

    });
    
    
}

-(void) subZMQ
{
//    ZMQContext *ctx = [[ZMQContext alloc] initWithIOThreads:1];
//    ZMQSocket *requester = [ctx socketWithType:ZMQ_SUB];
//    BOOL didConnect = [requester connectToEndpoint:ZMQ_TCP];
//    BOOL didSub =  [requester subscribeAll];
//    
//    if (!didConnect) {
//        NSLog(@"*** Failed to connect to endpoint [%@].", ZMQ_TCP);
//    }
//    if (!didSub) {
//        NSLog(@"*** Failed to subing");
//    }
//    
//    while (1) {
//        NSData *reply = [requester receiveDataWithFlags:0];
//        NSString *text = [[NSString alloc] initWithData:reply encoding:NSUTF8StringEncoding];
//        NSLog(@"Received reply %@", text);
//        
//    }
    
}

#pragma mark -------------------------------------------------------------
#pragma mark Connection Delegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [GPProgress showErrorWithStatus:@"连接错误"];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    
    [self.data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [GPProgress showSuccess];
    
    self.imageView.image = [UIImage imageWithData:self.data];
    
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge previousFailureCount] ==0){
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
    }else{
        [[challenge sender]cancelAuthenticationChallenge:challenge];
    }
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

- (NSMutableData *)data
{
    if (!_data) {
        _data = [NSMutableData data];
    }
    return _data;
}

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
