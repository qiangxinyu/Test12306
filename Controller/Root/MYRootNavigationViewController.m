//
//  MYRootNavigationViewController.m
//  MeiYa
//
//  Created by Xinyu Qiang on 16/6/22.
//  Copyright © 2016年 Xinyu Qiang. All rights reserved.
//

#import "MYRootNavigationViewController.h"

@interface MYRootNavigationViewController () <UINavigationControllerDelegate,UIGestureRecognizerDelegate>

@end

@implementation MYRootNavigationViewController

-(id)initWithRootViewController:(UIViewController *)rootViewController
{
    MYRootNavigationViewController* nvc = [super initWithRootViewController:rootViewController];
    self.interactivePopGestureRecognizer.delegate = self;
    nvc.delegate = self;
    return nvc;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.interactivePopGestureRecognizer.enabled = YES;
    
    //    [[UINavigationBar appearance] setTintColor:kDefaultColor];
    
    self.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:kNavigationBarTextColor forKey:NSForegroundColorAttributeName];
    [self.navigationBar setBackgroundImage:kImage(@"navigationBar_backgroudImage") forBarMetrics:UIBarMetricsDefault];
    
}
-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
}

-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (navigationController.viewControllers.count == 1)
        self.currentShowVC = Nil;
    else
        self.currentShowVC = viewController;
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        return (self.currentShowVC == self.topViewController); //the most important
    }
    return YES;
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
