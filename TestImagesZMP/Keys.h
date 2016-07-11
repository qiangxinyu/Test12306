//
//  Keys.h
//  zhaoZhaoBa
//
//  Created by apple on 16/5/1.
//  Copyright © 2016年 apple. All rights reserved.
//

#ifndef Keys_h
#define Keys_h


#pragma mark -----------------------------------------------------------
#pragma mark - 第三方的 Key


static NSString * UM_Key = @"576cecc6e0f55aea4700093b";

static NSString * QQ_APP_ID = @"1105496366";
static NSString * QQ_APP_KEY = @"p9OXpFU7aMjV0WA9";

static NSString * WX_APP_ID = @"";
static NSString * WX_APP_Secret = @"";

static NSString * WB_APP_ID = @"1740299574";
static NSString * WB_APP_Secret = @"60b9a1a9c09e6011dd48956cd65e233d";

#pragma mark -----------------------------------------------------------
#pragma mark - 本地

/**
 *  支付宝
 */
static NSString * action_ali_sign_key = @"ali_sign";

/**
 *  银联
 */
static NSString * action_union_sign_key = @"union_sign";

/**
 *  微信
 */

static NSString * action_weChat_sign_key = @"wx_sign";



static NSString * cell_height_key = @"cell_height_key";
static NSInteger pageSize = 10;

/**
 *  搜索历史  放在 NSUserDefault中
 */
static NSString * k_user_detault_search_history_array_key = @"k_user_detault_search_history_array_key";

/**
 *  用户是否登录
 */
static NSString * k_user_detault_user_is_sign_key = @"ns_user_detault_user_is_sign_key";

/**
 *  用户数据
 */
static NSString * k_user_detault_user_info_key = @"k_user_detault_user_info_key";

#endif /* Keys_h */
