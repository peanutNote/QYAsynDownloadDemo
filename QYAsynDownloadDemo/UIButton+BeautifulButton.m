//
//  UIButton+BeautifulButton.m
//  QYAsynDownloadDemo
//
//  Created by qianye on 16/7/21.
//  Copyright © 2016年 qianye. All rights reserved.
//

#import "UIButton+BeautifulButton.h"

@implementation UIButton (BeautifulButton)

- (void)beautifulButton:(UIColor *)tintColor {
    self.tintColor = tintColor ?: [UIColor darkGrayColor];
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 10.0;
    self.layer.borderColor = [UIColor grayColor].CGColor;
    self.layer.borderWidth = 1.0;
}

@end
