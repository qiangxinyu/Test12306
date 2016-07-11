//
//  Color.h
//  zhaoZhaoBa
//
//  Created by apple on 16/4/24.
//  Copyright © 2016年 apple. All rights reserved.
//

#ifndef Color_h
#define Color_h

#define kRGBA(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define kRGB(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(1)]

#define kNavigationBarTextColor kRGB(0,0,0)

#define kDefaultBackgroudColor kRGB(238,238,238)

#define kWhiteColor [UIColor whiteColor]
#define kBlackColor [UIColor blackColor]

#define k999999BackgroudColor [UIColor colorWithHexString:@"999999"]
#define k666666BackgroudColor [UIColor colorWithHexString:@"666666"]
#define k333333BackgroudColor [UIColor colorWithHexString:@"333333"]
#define kCCCCCCBackgroudColor [UIColor colorWithHexString:@"CCCCCC"]



#define kDefaultImage [UIImage imageNamed:@"占位图"]


#define kFontPingFangSC_Light                 @"PingFangSC-Light"
#define kFontPingFangSC_Regular               @"PingFangSC-Regular"

#define kFontPingFangSC_Light_13              [UIFont fontWithName:@"PingFangSC-Light" size:13]
#define kFontPingFangSC_Regular_13            [UIFont fontWithName:@"PingFangSC-Light" size:13]

#define kFontPingFangSC_Light_16              [UIFont fontWithName:@"PingFangSC-Light" size:16]
#define kFontPingFangSC_Regular_16            [UIFont fontWithName:@"PingFangSC-Light" size:16]


#define kFontPingFangSC_Light_17              [UIFont fontWithName:@"PingFangSC-Light" size:17]
#define kFontPingFangSC_Regular_17            [UIFont fontWithName:@"PingFangSC-Light" size:17]

#define kFontPingFangSC_Light_20              [UIFont fontWithName:@"PingFangSC-Light" size:20]
#define kFontPingFangSC_Regular_20            [UIFont fontWithName:@"PingFangSC-Light" size:20]




#endif /* Color_h */
