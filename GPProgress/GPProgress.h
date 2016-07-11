//
//  GPProgress.h
//  GPProgress
//
//  Created by yangguan on 16/1/17.
//  Copyright © 2016年 yangguan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GPProgress : UIView

+ (void)show;
+ (void)showWithStatus:(NSString *)status;

+ (void)showSuccess;
+ (void)showSuccessWithStatus:(NSString *)status;
+ (void)showSuccessWithStatus:(NSString *)status detail:(NSString *)detail;

+ (void)showError;
+ (void)showErrorWithStatus:(NSString *)status;
+ (void)showErrorWithStatus:(NSString *)status detail:(NSString *)detail;
+ (void)dismiss;
+ (void)dismissWithCompletion:(void (^)(void))completion ;
+ (BOOL)isVisible;


@end
