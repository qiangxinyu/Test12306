//
//  XYNetTool.m
//  TestImagesZMP
//
//  Created by 强新宇 on 16/7/12.
//  Copyright © 2016年 强新宇. All rights reserved.
//

#import "XYNetTool.h"
#import "ZMQObjC.h"

static NSString * ZMQ_TCP = @"tcp://123.57.1.120:8163";
static NSString * Image_URL = @"http://kyfw.12306.cn/otn/passcodeNew/getPassCodeNew?module=login&rand=sjrand&0.905792899211612";


@interface XYNetTool () <NSURLConnectionDataDelegate>
@property (nonatomic, strong)NSDate * date;
@property (nonatomic, strong)NSMutableData * data;

@end

@implementation XYNetTool

+ (XYNetTool *)shareXYNetTool
{
    static XYNetTool * netTool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        netTool = [[XYNetTool alloc] init];
    });
    return netTool;
}


+ (void)requestDataWithBlock:(GetImageBlock)block
{
    [GPProgress show];
    
    [[self class] shareXYNetTool].getImageBlock = block;
    
    [[self class] shareXYNetTool].data = [NSMutableData data];
    
    NSURL * url = [NSURL URLWithString:Image_URL];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    [NSURLConnection connectionWithRequest:request delegate:[[self class] shareXYNetTool]];
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
    dispatch_async(dispatch_get_main_queue(), ^{
        [GPProgress showSuccess];
        
        self.getImageBlock ? self.getImageBlock([UIImage imageWithData:self.data]) : 0;
    });
    
    [self deleteCookies];
    
}

//删除全部cookies
-(void)deleteCookies{
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage]cookies]) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
    NSLog(@"删除完成");
}
//根据url和name删除cookie
-(void)deleteCookie:(NSString *)cookieName url:(NSURL *)url{
    //根据url找到所属的cookie集合
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage]cookiesForURL:url];
    for (NSHTTPCookie *cookie in cookies) {
        if([cookie.name isEqualToString:cookieName]){
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
            NSLog(@"删除cookie:%@",cookieName);
        }
    }
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
#pragma mark ZMQ

+ (void)requestZMQWithBlock:(void(^)(NSInteger height, NSString * time, NSMutableArray * groupArray))block
{
    
    //为了体现高科技 延时1秒 ，没其他任何 作用 不要疑惑
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [[self class] shareXYNetTool].date = [NSDate date];
        
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
            
            
            NSString * imageStr = [[[self class] shareXYNetTool].data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
            
            imageStr =  [imageStr stringByReplacingOccurrencesOfString:@"\\s*" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, imageStr.length)];
            
            NSData *request = [imageStr dataUsingEncoding:NSUTF8StringEncoding];
            
            for (int request_nbr = 0; request_nbr < kMaxRequest; ++request_nbr) {
                
                [requester sendData:request withFlags:0];
                
                NSData *reply = [requester receiveDataWithFlags:0];
                NSString *text = [[NSString alloc] initWithData:reply encoding:NSUTF8StringEncoding];
                
                if (text) {
                    
                    NSArray * array = [text componentsSeparatedByString:@","];
                    
                    NSMutableArray * groupArray = @[].mutableCopy;
                    
                    for (NSString * string in array) {
                        NSArray * array1 = [string componentsSeparatedByString:@"|"];
                        
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
                        
                        [groupArray addObject:newStr];
                    }
                    
                    NSInteger height = (groupArray.count / 4 + (groupArray.count % 4 ? 1 : 0)) * kScreenWidth / 4 ;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        double deltaTime = [[NSDate date] timeIntervalSinceDate:[[self class] shareXYNetTool].date];

                        block ? block(height,[NSString stringWithFormat:@"%.fms",deltaTime * 1000], groupArray) : 0;
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
@end
