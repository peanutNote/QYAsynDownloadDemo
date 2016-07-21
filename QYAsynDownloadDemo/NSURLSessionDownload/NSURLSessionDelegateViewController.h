//
//  NSURLSessionDelegateViewController.h
//  QYAsynDownloadDemo
//
//  Created by qianye on 16/7/21.
//  Copyright © 2016年 qianye. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSURLSessionDelegateViewController : UIViewController <NSURLSessionDownloadDelegate>
@property (strong, nonatomic) NSURLSessionDownloadTask *downloadTask;

@property (strong, nonatomic) IBOutlet UILabel *lblFileName;
@property (strong, nonatomic) IBOutlet UIProgressView *progVDownloadFile;
@property (strong, nonatomic) IBOutlet UILabel *lblMessage;
@property (strong, nonatomic) IBOutlet UIButton *btnDownloadFile;
@property (strong, nonatomic) IBOutlet UIButton *btnCancel;
@property (strong, nonatomic) IBOutlet UIButton *btnSuspend;
@property (strong, nonatomic) IBOutlet UIButton *btnResume;

@end
