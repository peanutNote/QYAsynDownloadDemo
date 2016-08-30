//
//  AFNetworkingViewController.h
//  QYAsynDownloadDemo
//
//  Created by qianye on 16/7/21.
//  Copyright © 2016年 qianye. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface AFNetworkingDownload : UIViewController
@property (strong, nonatomic) MBProgressHUD *hud;

@property (strong, nonatomic) IBOutlet UILabel *lblFileName;
@property (strong, nonatomic) IBOutlet UILabel *lblMessage;
@property (strong, nonatomic) IBOutlet UIButton *btnDownloadFileByConnection;
@property (strong, nonatomic) IBOutlet UIButton *btnDownloadFileBySession;

@end
