//
//  NSURLConnectionDelegateViewController.h
//  QYAsynDownloadDemo
//
//  Created by qianye on 16/7/21.
//  Copyright © 2016年 qianye. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSURLConnectionDelegateViewController : UIViewController
@property (strong, nonatomic) NSMutableData *mDataReceive;
@property (assign, nonatomic) NSUInteger totalDataLength;

@property (strong, nonatomic) IBOutlet UILabel *lblFileName;
@property (strong, nonatomic) IBOutlet UIProgressView *progVDownloadFile;
@property (strong, nonatomic) IBOutlet UILabel *lblMessage;
@property (strong, nonatomic) IBOutlet UIButton *btnDownloadFile;

@end
