//
//  AFNetworkingViewController.m
//  QYAsynDownloadDemo
//
//  Created by qianye on 16/7/21.
//  Copyright © 2016年 qianye. All rights reserved.
//

#import "AFNetworkingViewController.h"
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "UIButton+BeautifulButton.h"

@interface AFNetworkingViewController ()
- (void)showAlert:(NSString *)msg;
- (void)checkNetwork;
- (void)layoutUI;
- (NSMutableURLRequest *)downloadRequest;
- (NSURL *)saveURL:(NSURLResponse *)response deleteExistFile:(BOOL)deleteExistFile;
- (void)updateProgress:(int64_t)receiveDataLength totalDataLength:(int64_t)totalDataLength;
@end

@implementation AFNetworkingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self layoutUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showAlert:(NSString *)msg {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"网络情况"
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"确定", nil];
    [alert show];
}

- (void)checkNetwork {
    NSURL *baseURL = [NSURL URLWithString:@"http://www.baidu.com/"];
    /* 
     * AFNetwroking 2.x使用，3.0已经弃用：https://github.com/AFNetworking/AFNetworking/wiki/AFNetworking-3.0-Migration-Guide#new-requirements-ios-7-mac-os-x-109-watchos-2-tvos-9--xcode-7
     *
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
    NSOperationQueue *operationQueue = manager.operationQueue;
    [manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWiFi:
                [self showAlert:@"Wi-Fi 网络下"];
                [operationQueue setSuspended:NO];
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                [self showAlert:@"2G/3G/4G 蜂窝移动网络下"];
                [operationQueue setSuspended:YES];
                break;
            case AFNetworkReachabilityStatusNotReachable:
            default:
                [self showAlert:@"未连接网络"];
                [operationQueue setSuspended:YES];
                break;
        }
    }];
    
    [manager.reachabilityManager startMonitoring];
     */
    
    // AFNetworking 3.0x中使用
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    NSOperationQueue *operationQueue = manager.operationQueue;
    [manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWiFi:
                [self showAlert:@"Wi-Fi 网络下"];
                [operationQueue setSuspended:NO];
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                [self showAlert:@"2G/3G/4G 蜂窝移动网络下"];
                [operationQueue setSuspended:YES];
                break;
            case AFNetworkReachabilityStatusNotReachable:
            default:
                [self showAlert:@"未连接网络"];
                [operationQueue setSuspended:YES];
                break;
        }
    }];
    [manager.reachabilityManager startMonitoring];
}

- (void)layoutUI {
    self.navigationItem.title = kTitleOfAFNetworking;
    self.view.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.000];
    
    //条件表达式中，「?:」可以表示在条件不成立的情况，才使用后者赋值，否则使用用于条件判断的前者赋值
    //以下语句等同于：UIButton *btn = _btnDownloadFileByConnection ? _btnDownloadFileByConnection : [UIButton new];
    //在 .NET 中，相当于使用「??」；在 JavaScript 中，相当于使用「||」来实现这种类似的判断
    UIButton *btn = _btnDownloadFileByConnection ?: [UIButton new];
    [btn beautifulButton:nil];
    [_btnDownloadFileBySession beautifulButton:[UIColor orangeColor]];
    
    //进度效果
    _hud = [[MBProgressHUD alloc] initWithView:self.view];
    _hud.mode = MBProgressHUDModeDeterminate;
    _hud.label.text = @"下载中...";
    [_hud hideAnimated:YES];
    [self.view addSubview:_hud];
    
    //检查网络情况
    [self checkNetwork];
    
    //启动网络活动指示器；会根据网络交互情况，实时显示或隐藏网络活动指示器；他通过「通知与消息机制」来实现 [UIApplication sharedApplication].networkActivityIndicatorVisible 的控制
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
}

- (NSMutableURLRequest *)downloadRequest {
    NSString *fileURLStr = kFileURLStr;
    //编码操作；对应的解码操作是用 stringByRemovingPercentEncoding 方法
    fileURLStr = [fileURLStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *fileURL = [NSURL URLWithString:fileURLStr];
    
    //创建请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:fileURL];
    return request;
}

- (NSURL *)saveURL:(NSURLResponse *)response deleteExistFile:(BOOL)deleteExistFile {
    NSString *fileName = response ? [response suggestedFilename] : _lblFileName.text;
    
    //方法一
    //    NSString *savePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    //    savePath = [savePath stringByAppendingPathComponent:fileName];
    //    NSURL *saveURL = [NSURL fileURLWithPath:savePath];
    
    //方法二
    NSURL *saveURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    saveURL = [saveURL URLByAppendingPathComponent:fileName];
    NSString *savePath = [saveURL path];
    
    if (deleteExistFile) {
        NSError *saveError;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        //判断是否存在旧的目标文件，如果存在就先移除；避免无法复制问题
        if ([fileManager fileExistsAtPath:savePath]) {
            [fileManager removeItemAtPath:savePath error:&saveError];
            if (saveError) {
                NSLog(@"移除旧的目标文件失败，错误信息：%@", saveError.localizedDescription);
            }
        }
    }
    
    return saveURL;
}

- (void)updateProgress:(int64_t)receiveDataLength totalDataLength:(int64_t)totalDataLength; {
    dispatch_async(dispatch_get_main_queue(), ^{ //使用主队列异步方式（主线程）执行更新 UI 操作
        _hud.progress = (float)receiveDataLength / totalDataLength;
        
        if (receiveDataLength == totalDataLength) {
            _lblMessage.text =  receiveDataLength < 0 ? @"下载失败" : @"下载完成";
            //kApplication.networkActivityIndicatorVisible = NO;
            [_hud hideAnimated:YES];
        } else {
            _lblMessage.text = @"下载中...";
            //kApplication.networkActivityIndicatorVisible = YES;
            [_hud showAnimated:YES];
        }
    });
}

- (IBAction)downloadFileByConnection:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"AFNetworking在3.0版本中删除了基于 NSURLConnection API的所有支持" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
    /*
     * AFNetworking 2.x使用，3.0弃用
     *
    //创建请求
    NSMutableURLRequest *request = [self downloadRequest];
    //创建请求操作
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    NSString *savePath = [[self saveURL:nil deleteExistFile:NO] path];
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        NSLog(@"已经接收到响应数据，数据长度为%lld字节...", totalBytesRead);
        
        [self updateProgress:totalBytesRead totalDataLength:totalBytesExpectedToRead];
    }];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"已经接收完所有响应数据");
        
        NSData *data = (NSData *)responseObject;
        [data writeToFile:savePath atomically:YES]; //responseObject 的对象类型是 NSData
        
        [self updateProgress:100 totalDataLength:100];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"下载失败，错误信息：%@", error.localizedDescription);
        
        [self updateProgress:-1 totalDataLength:-1];
    }];
    
    //启动请求操作
    [operation start];
     */
}

- (IBAction)downloadFileBySession:(id)sender {
    //创建请求
    NSMutableURLRequest *request = [self downloadRequest];
    
    //创建会话配置「进程内会话」
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.timeoutIntervalForRequest = 60.0; //请求超时时间；默认为60秒
    sessionConfiguration.allowsCellularAccess = YES; //是否允许蜂窝网络访问（2G/3G/4G）
    sessionConfiguration.HTTPMaximumConnectionsPerHost = 4; //限制每次最多连接数；在 iOS 中默认值为4
    
    //创建会话管理器
    AFURLSessionManager *sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:sessionConfiguration];
    
    //创建会话下载任务，并且启动他；在非主线程中执行
    NSURLSessionDownloadTask *task = [sessionManager
                                      downloadTaskWithRequest:request
                                      progress:nil
                                      destination:^ NSURL*(NSURL *targetPath, NSURLResponse *response) {
                                          //当 sessionManager 调用 setDownloadTaskDidFinishDownloadingBlock: 方法，并且方法代码块返回值不为 nil 时（优先级高），下面的两句代码是不执行的（优先级低）
                                          NSLog(@"下载后的临时保存路径：%@", targetPath);
                                          return [self saveURL:response deleteExistFile:YES];
                                      } completionHandler:^ (NSURLResponse *response, NSURL *filePath, NSError *error) {
                                          if (!error) {
                                              NSLog(@"下载后的保存路径：%@", filePath); //为上面代码块返回的路径
                                              
                                              [self updateProgress:100 totalDataLength:100];
                                          } else {
                                              NSLog(@"下载失败，错误信息：%@", error.localizedDescription);
                                              
                                              [self updateProgress:-1 totalDataLength:-1];
                                          }
                                          
                                          [_hud hideAnimated:YES];
                                      }];
    
    //类似 NSURLSessionDownloadDelegate 的方法操作
    //- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite;
    [sessionManager setDownloadTaskDidWriteDataBlock:^ (NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        NSLog(@"已经接收到响应数据，数据长度为%lld字节...", totalBytesWritten);
        
        [self updateProgress:totalBytesWritten totalDataLength:totalBytesExpectedToWrite];
    }];
    
    //- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location;
    [sessionManager setDownloadTaskDidFinishDownloadingBlock:^ NSURL*(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, NSURL *location) {
        NSLog(@"已经接收完所有响应数据，下载后的临时保存路径：%@", location);
        return [self saveURL:nil deleteExistFile:YES];
    }];
    
    [task resume];
}

@end
