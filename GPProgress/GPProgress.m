//
//  GPProgress.m
//  GPProgress
//
//  Created by yangguan on 16/1/17.
//  Copyright © 2016年 yangguan. All rights reserved.
//
#import "GPProgress.h"

#define MAS_SHORTHAND
#define MAS_SHORTHAND_GLOBALS

#import "Masonry.h"



#define kDismissTimeInterval 0.5
#define kLoadingDuration 0.8  //秒每圈
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

typedef enum : NSUInteger {
    GPProgressLoading,
    GPProgressFail,
    GPProgressSuccess,
} GPProgressStyle;

@interface GPProgress ()
{
    BOOL _isLoadingAnimation;
   __block BOOL _isDismissing;
}
@property (strong, nonatomic) CALayer *backgroundLayer;
@property (strong, nonatomic) UIImageView *contentView;
@property (strong, nonatomic) UIImageView *imageView;

@property (strong, nonatomic) UILabel *labelStatus;
@property (strong, nonatomic) UILabel *labelDeatil;
@property (assign, nonatomic) BOOL isVisible;



@end

@implementation GPProgress

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubviews];
//        self.windowLevel = UIWindowLevelAlert;
        self.alpha = 0;
    }
    return self;
}

+(GPProgress *)shareProgress{
    static GPProgress *progress;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        progress = [[GPProgress alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    });
    return progress;
}

#pragma mark - Public Method

//  loading
+ (void)show{
    [[self shareProgress] showWithStyle:GPProgressLoading status:nil detail:nil];
}
+ (void)showWithStatus:(NSString *)status{
    [[self shareProgress] showWithStyle:GPProgressLoading status:status detail:nil];

}

// success

+ (void)showSuccess{
    [[self shareProgress] showWithStyle:GPProgressSuccess status:nil detail:nil];
}
+ (void)showSuccessWithStatus:(NSString *)status{
    [[self shareProgress] showWithStyle:GPProgressSuccess status:status detail:nil];
}
+ (void)showSuccessWithStatus:(NSString *)status detail:(NSString *)detail{
    [[self shareProgress] showWithStyle:GPProgressSuccess status:status detail:detail];

}

//fail
+ (void)showError{
    [[self shareProgress] showWithStyle:GPProgressFail status:nil detail:nil];

}
+ (void)showErrorWithStatus:(NSString *)status{
    [[self shareProgress] showWithStyle:GPProgressFail status:status detail:nil];

}
+ (void)showErrorWithStatus:(NSString *)status detail:(NSString *)detail{
    [[self shareProgress] showWithStyle:GPProgressFail status:status detail:detail];

}

// remove
+ (void)dismiss{
    [[self shareProgress] dismissWithCompletion:nil];
}
+ (void)dismissWithCompletion:(void (^)(void))completion{
    [[self shareProgress] dismissWithCompletion:completion];
}
- (void)dismissWithCompletion:(void (^)(void))completion{
    if (!_isVisible) {
        return;
    }
    
    _isDismissing = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // If the view has changed or will change, the dismissing property is set back to NO so we don't dismiss
        // the (scheduled) new one
        if (_isDismissing) {
            [self dismissAnimatedWithCompletion:completion];
        }
    });

}
-(void)dismissAnimatedWithCompletion:(void (^)(void))completion{
    
    WS(ws);
    
    [UIView animateWithDuration:0.5 animations:^{
        ws.alpha = 0;
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
        _isVisible = NO;
        _isDismissing = NO;
        [ws removeFromSuperview];
        [ws reset];
    }];

}



-(void)reset{
    self.contentView.image = nil;
    [self.imageView.layer removeAllAnimations];
    [self.labelStatus removeFromSuperview];
    self.labelStatus = nil;
    [self.labelDeatil removeFromSuperview];
    self.labelDeatil = nil;
}

+ (BOOL)isVisible{
    return [self shareProgress].isVisible;
}

#pragma mark - Private Method
-(void)addSubviews{
    [self.layer addSublayer:self.backgroundLayer];
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.imageView];
}

-(void)showWithStyle:(GPProgressStyle)style
              status:(NSString *)status
              detail:(NSString *)detail{
    [self reset];
    _isDismissing = NO;
    [self.imageView.layer removeAllAnimations];
    [self setStyleImageWith:(GPProgressStyle) style];
    [self setContentImageWithstatus:status detail:detail];

    WS(ws);
    if (_isVisible) {
        
    }else{
        UIWindow *keywindow = [UIApplication sharedApplication].keyWindow;
        [keywindow addSubview:self];
        _isVisible = YES;
        [UIView animateWithDuration:0.5 animations:^{
            ws.alpha = 1;
        } completion:^(BOOL finished) {
            
        }];
    }
   
    if (style == GPProgressFail || style == GPProgressSuccess) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDismissTimeInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [ws dismissWithCompletion:nil];
        });
    }
}

-(void)setContentImageWithstatus:(NSString *)status
                    detail:(NSString *)detail{
    UIImage *image;
    if (status || detail) {
         image = [[UIImage imageNamed:@"backgroundBroad"] resizableImageWithCapInsets:UIEdgeInsetsMake(35, 100, 35, 100) resizingMode:UIImageResizingModeTile];
    }else{
         image = [UIImage imageNamed:@"background"];
    }
    self.contentView.image = image;
    [self.contentView remakeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(image.size);
        make.center.equalTo(0);
    }];
    [self setStatus:status detail:detail];

}
-(void)setStatus:(NSString *)status
          detail:(NSString *)detail{
    if (status) {
        self.labelStatus.text = status;
        [self.contentView addSubview:self.labelStatus];
        [self.labelStatus remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(42);
            make.centerX.equalTo(21);
            make.right.lessThanOrEqualTo(-25);
        }];
        WeakSelf(weakSelf);
        [self.imageView remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(34);
            make.right.equalTo(_labelStatus.mas_left).offset(-10);
            make.left.greaterThanOrEqualTo(25);
        }];
    }
    if (detail) {
        self.labelDeatil.text = detail;
        [self.contentView addSubview:self.labelDeatil];
        [self.labelDeatil remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.imageView.mas_bottom).offset(10);
            make.right.equalTo(-25);
            make.left.equalTo(25);
            make.height.greaterThanOrEqualTo(0);
        }];
        [self.contentView remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(0);
            make.width.equalTo(270);
            make.bottom.equalTo(_labelDeatil.mas_bottom).offset(42);
        }];
    }
}

-(void)setStyleImageWith:(GPProgressStyle) style{
    UIImage *image;
    if (style == GPProgressFail) {
        image = [UIImage imageNamed:@"fail"];
    }else if (style == GPProgressLoading){
        [self addAnmationToLoading];
        image = [UIImage imageNamed:@"loading"];
    }else if (style == GPProgressSuccess){
        image = [UIImage imageNamed:@"success"];
    }
    self.imageView.image = image;
    [self.imageView updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(34);
        make.centerX.equalTo(0);
        make.size.equalTo(image.size);
    }];

}

//-(void)showWithStyle
#pragma mark - Event Response


-(void)addAnmationToLoading{
    [self.imageView.layer removeAllAnimations];
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.keyPath = @"transform";
    
    animation.values = @[
                         [NSValue valueWithCATransform3D:CATransform3DRotate(self.imageView.layer.transform, 0, 0, 0, 0)],
                         [NSValue valueWithCATransform3D:CATransform3DRotate(self.imageView.layer.transform,M_PI/2.0, 0, 0, 1)],
                         [NSValue valueWithCATransform3D:CATransform3DRotate(self.imageView.layer.transform,M_PI, 0, 0, 1)],
                         [NSValue valueWithCATransform3D:CATransform3DRotate(self.imageView.layer.transform,M_PI*3/2.0, 0, 0, 1)],
                          [NSValue valueWithCATransform3D:CATransform3DRotate(self.imageView.layer.transform,2*M_PI, 0, 0, 1)],
                         ];
    animation.duration = kLoadingDuration;
    animation.repeatCount = FLT_MAX;
    [self.imageView.layer addAnimation:animation forKey:nil];

}


#pragma mark -Getter & Setter

-(CALayer *)backgroundLayer{
    if (!_backgroundLayer) {
        _backgroundLayer = [[CALayer alloc] init];
        _backgroundLayer.frame = self.bounds;
        _backgroundLayer.backgroundColor = [UIColor blackColor].CGColor;
        _backgroundLayer.opacity = 0.64;
    }
    return _backgroundLayer;
}
-(UIView *)contentView{
    if (!_contentView) {
        _contentView = [[UIImageView alloc] init];
    }
    return _contentView;
}
-(UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    }
    return _imageView;
}
-(UILabel *)labelStatus{
    if (!_labelStatus) {
        _labelStatus = [[UILabel alloc] init];
        _labelStatus.textColor = [UIColor blackColor];
        _labelStatus.font = [UIFont systemFontOfSize:16];
    }
    return _labelStatus;
}
-(UILabel *)labelDeatil{
    if (!_labelDeatil) {
        _labelDeatil = [[UILabel alloc] init];
        _labelDeatil.font = [UIFont systemFontOfSize:13];
        _labelDeatil.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
        _labelDeatil.numberOfLines = 0;
        _labelDeatil.textAlignment = NSTextAlignmentCenter;
    }
    return _labelDeatil;
}

@end
