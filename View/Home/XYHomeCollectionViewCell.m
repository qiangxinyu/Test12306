//
//  XYHomeCollectionViewCell.m
//  TestImagesZMP
//
//  Created by 强新宇 on 16/7/11.
//  Copyright © 2016年 强新宇. All rights reserved.
//

#import "XYHomeCollectionViewCell.h"

@implementation XYHomeCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setIsSuccess:(BOOL)isSuccess
{
    _isSuccess = isSuccess;
    
    
    if (isSuccess) {
        self.backgroundColor = kRGB(117, 235, 127);
    } else {
        self.backgroundColor = kRGB(238, 238, 238);
    }
}

@end
