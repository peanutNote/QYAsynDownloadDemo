//
//  NSURLConnectionViewController.m
//  QYAsynDownloadDemo
//
//  Created by qianye on 16/7/21.
//  Copyright © 2016年 qianye. All rights reserved.
//

#import "NSURLConnectionViewController.h"
#import "UIButton+BeautifulButton.h"

@interface NSURLConnectionViewController ()
- (void)layoutUI;
- (void)saveDataToDisk:(NSData *)data;
@end

@implementation NSURLConnectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self layoutUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)layoutUI {
    self.navigationItem.title = kTitleOfNSURLConnection;
    self.view.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.000];
    
    [_btnDownloadFile beautifulButton:nil];
}

- (void)saveDataToDisk:(NSData *)data {
    //数据接收完保存文件；注意苹果官方要求：下载数据只能保存在缓存目录（/Library/Caches）
    NSString *savePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    savePath = [savePath stringByAppendingPathComponent:_lblFileName.text];
    [data writeToFile:savePath atomically:YES]; //writeToFile: 方法：如果 savePath 文件存在，他会执行覆盖
}

- (IBAction)downloadFile:(id)sender {
    _lblMessage.text = @"下载中...";
    
    NSString *fileURLStr = kFileURLStr;
    //编码操作；对应的解码操作是用 stringByRemovingPercentEncoding 方法
    fileURLStr = [fileURLStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *fileURL = [NSURL URLWithString:fileURLStr];
    
    //创建请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:fileURL];
    
    //创建连接；Apple 提供的处理一般请求的两种方法，他们不需要进行一系列的 NSURLConnectionDataDelegate 委托协议方法操作，简洁直观
    //方法一：发送一个同步请求；不建议使用，因为当前线程是主线程的话，会造成线程阻塞，一般比较少用
    //    NSURLResponse *response;
    //    NSError *connectionError;
    //    NSData *data = [NSURLConnection sendSynchronousRequest:request
    //                                         returningResponse:&response
    //                                                     error:&connectionError];
    //    if (!connectionError) {
    //        [self saveDataToDisk:data];
    //        NSLog(@"保存成功");
    //
    //        _lblMessage.text = @"下载完成";
    //    } else {
    //        NSLog(@"下载失败，错误信息：%@", connectionError.localizedDescription);
    //
    //        _lblMessage.text = @"下载失败";
    //    }
    
    //方法二：发送一个异步请求
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (!connectionError) {
                                   [self saveDataToDisk:data];
                                   NSLog(@"保存成功");
                                   
                                   _lblMessage.text = @"下载完成";
                                   
                               } else {
                                   NSLog(@"下载失败，错误信息：%@", connectionError.localizedDescription);
                                   
                                   _lblMessage.text = @"下载失败";
                               }
                           }];
}

@end
