//
//  NSURLSessionViewController.m
//  QYAsynDownloadDemo
//
//  Created by qianye on 16/7/21.
//  Copyright © 2016年 qianye. All rights reserved.
//

#import "NSURLSessionViewController.h"
#import "UIButton+BeautifulButton.h"

@interface NSURLSessionViewController ()
- (void)layoutUI;
@end

@implementation NSURLSessionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self layoutUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)layoutUI {
    self.navigationItem.title = kTitleOfNSURLSession;
    self.view.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.000];
    
    [_btnDownloadFile beautifulButton:nil];
}

- (IBAction)downloadFile:(id)sender {
    _lblMessage.text = @"下载中...";
    
    NSString *fileURLStr = kFileURLStr;
    //编码操作；对应的解码操作是用 stringByRemovingPercentEncoding 方法
    fileURLStr = [fileURLStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *fileURL = [NSURL URLWithString:fileURLStr];
    
    //创建请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:fileURL];
    
    //创建会话（这里使用了一个全局会话）
    NSURLSession *session = [NSURLSession sharedSession];
    
    //创建下载任务，并且启动他；在非主线程中执行
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        __block void (^updateUI)(); //声明用于主线程更新 UI 的代码块
        
        if (!error) {
            NSLog(@"下载后的临时保存路径：%@", location);
            
            NSString *savePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
            savePath = [savePath stringByAppendingPathComponent:_lblFileName.text];
            NSURL *saveURL = [NSURL fileURLWithPath:savePath];
            NSError *saveError;
            NSFileManager *fileManager = [NSFileManager defaultManager];
            //判断是否存在旧的目标文件，如果存在就先移除；避免无法复制问题
            if ([fileManager fileExistsAtPath:savePath]) {
                [fileManager removeItemAtPath:savePath error:&saveError];
                if (saveError) {
                    NSLog(@"移除旧的目标文件失败，错误信息：%@", saveError.localizedDescription);
                    
                    updateUI = ^ {
                        _lblMessage.text = @"下载失败";
                    };
                }
            }
            if (!saveError) {
                //把源文件复制到目标文件，当目标文件存在时，会抛出一个错误到 error 参数指向的对象实例
                //方法一（path 不能有 file:// 前缀）
                //                [fileManager copyItemAtPath:[location path]
                //                                     toPath:savePath
                //                                      error:&saveError];
                
                //方法二
                [fileManager copyItemAtURL:location
                                     toURL:saveURL
                                     error:&saveError];
                
                if (!saveError) {
                    NSLog(@"保存成功");
                    
                    updateUI = ^ {
                        _lblMessage.text = @"下载完成";
                    };
                } else {
                    NSLog(@"保存失败，错误信息：%@", saveError.localizedDescription);
                    
                    updateUI = ^ {
                        _lblMessage.text = @"下载失败";
                    };
                }
            }
            
        } else {
            NSLog(@"下载失败，错误信息：%@", error.localizedDescription);
            
            updateUI = ^ {
                _lblMessage.text = @"下载失败";
            };
        }
        
        dispatch_async(dispatch_get_main_queue(), updateUI); //使用主队列异步方式（主线程）执行更新 UI 的代码块
    }];
    [downloadTask resume]; //恢复线程，启动任务
}

@end
