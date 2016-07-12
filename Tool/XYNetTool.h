//
//  XYNetTool.h
//  TestImagesZMP
//
//  Created by 强新宇 on 16/7/12.
//  Copyright © 2016年 强新宇. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^GetImageBlock)(UIImage * image);


@interface XYNetTool : NSObject

@property (nonatomic, copy)GetImageBlock getImageBlock;



/**
 *  请求图片
 *
 *  @param block 
 */
+ (void)requestDataWithBlock:(GetImageBlock)block;



/**
 *  请求 分析图片
 *
 *  @param block 返回 列表高度 和耗时
 */
+ (void)requestZMQWithBlock:(void(^)(NSInteger height, NSString * time, NSMutableArray * groupArray))block;
@end
