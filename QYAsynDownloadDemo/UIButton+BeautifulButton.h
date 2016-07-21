//
//  UIButton+BeautifulButton.h
//  QYAsynDownloadDemo
//
//  Created by qianye on 16/7/21.
//  Copyright © 2016年 qianye. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (BeautifulButton)
/**
 *  设置按钮文字颜色、圆角按钮、边框颜色
 *
 *  @param tintColor 按钮文字颜色；nil 的话就为深灰色
 */
- (void)beautifulButton:(UIColor *)tintColor;

@end
