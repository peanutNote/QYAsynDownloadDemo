//
//  ViewController.h
//  QYAsynDownloadDemo
//
//  Created by qianye on 16/7/19.
//  Copyright © 2016年 qianye. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UITableViewController
@property (copy, nonatomic) NSArray *arrSampleName;

- (instancetype)initWithSampleNameArray:(NSArray *)arrSampleName;

@end

