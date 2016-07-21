//
//  NSURLConnectionViewController.h
//  QYAsynDownloadDemo
//
//  Created by qianye on 16/7/21.
//  Copyright © 2016年 qianye. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSURLConnectionViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *lblFileName;
@property (strong, nonatomic) IBOutlet UILabel *lblMessage;
@property (strong, nonatomic) IBOutlet UIButton *btnDownloadFile;

@end
