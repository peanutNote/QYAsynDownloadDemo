//
//  NSURLSessionDelegateViewController.m
//  QYAsynDownloadDemo
//
//  Created by qianye on 16/7/21.
//  Copyright © 2016年 qianye. All rights reserved.
//

#import "NSURLSessionDelegateDownload.h"

@interface NSURLSessionDelegateDownload ()
- (void)layoutUI;
- (NSURLSession *)defaultSession;
- (NSURLSession *)backgroundSession;
- (void)updateProgress:(int64_t)receiveDataLength totalDataLength:(int64_t)totalDataLength;
@end

@implementation NSURLSessionDelegateDownload

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self layoutUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)layoutUI {
    self.navigationItem.title = kTitleOfNSURLSessionDelegate;
    self.view.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.000];
}

- (NSURLSession *)defaultSession {
    /*
     NSURLSession 支持进程三种会话：
     1、defaultSessionConfiguration：进程内会话（默认会话），用硬盘来缓存数据。
     2、ephemeralSessionConfiguration：临时的进程内会话（内存），不会将 cookie、缓存储存到本地，只会放到内存中，当应用程序退出后数据也会消失。
     3、backgroundSessionConfiguration：后台会话，相比默认会话，该会话会在后台开启一个线程进行网络数据处理。
     */
    
    //创建会话配置「进程内会话」
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.timeoutIntervalForRequest = 60.0; //请求超时时间；默认为60秒
    sessionConfiguration.allowsCellularAccess = YES; //是否允许蜂窝网络访问（2G/3G/4G）
    sessionConfiguration.HTTPMaximumConnectionsPerHost = 4; //限制每次最多连接数；在 iOS 中默认值为4
    
    //创建会话
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                          delegate:self
                                                     delegateQueue:nil];
    return session;
}

- (NSURLSession *)backgroundSession {
    static NSURLSession *session;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ //应用程序生命周期内，只执行一次；保证只有一个「后台会话」
        //创建会话配置「后台会话」
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"KMDownloadFile.NSURLSessionDelegateViewController"];
        sessionConfiguration.timeoutIntervalForRequest = 60.0; //请求超时时间；默认为60秒
        sessionConfiguration.allowsCellularAccess = YES; //是否允许蜂窝网络访问（2G/3G/4G）
        sessionConfiguration.HTTPMaximumConnectionsPerHost = 4; //限制每次最多连接数；在 iOS 中默认值为4
        sessionConfiguration.discretionary = YES; //是否自动选择最佳网络访问，仅对「后台会话」有效
        
        //创建会话
        session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                delegate:self
                                           delegateQueue:nil];
    });
    return session;
}

- (void)updateProgress:(int64_t)receiveDataLength totalDataLength:(int64_t)totalDataLength; {
    dispatch_async(dispatch_get_main_queue(), ^{ //使用主队列异步方式（主线程）执行更新 UI 操作
        if (receiveDataLength == totalDataLength) {
            _lblMessage.text = @"下载完成";
            kApplication.networkActivityIndicatorVisible = NO;
        } else {
            _lblMessage.text = @"下载中...";
            kApplication.networkActivityIndicatorVisible = YES;
            _progVDownloadFile.progress = (float)receiveDataLength / totalDataLength;
        }
    });
}

- (IBAction)downloadFile:(id)sender {
    NSString *fileURLStr = kFileURLStr;
    //编码操作；对应的解码操作是用 stringByRemovingPercentEncoding 方法
    fileURLStr = [fileURLStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *fileURL = [NSURL URLWithString:fileURLStr];
    
    //创建请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:fileURL];
    
    //创建会话「进程内会话」；如要用「后台会话」就使用自定义的[self backgroundSession] 方法
    NSURLSession *session = [self defaultSession];
    
    //创建下载任务，并且启动他；在非主线程中执行
    _downloadTask = [session downloadTaskWithRequest:request];
    [_downloadTask resume];
    
    /*
     会话任务状态
     typedef NS_ENUM(NSInteger, NSURLSessionTaskState) {
     NSURLSessionTaskStateRunning = 0, //正在执行
     NSURLSessionTaskStateSuspended = 1, //已挂起
     NSURLSessionTaskStateCanceling = 2, //正在取消
     NSURLSessionTaskStateCompleted = 3, //已完成
     } NS_ENUM_AVAILABLE(NSURLSESSION_AVAILABLE, 7_0);
     */
}

- (IBAction)cancel:(id)sender {
    [_downloadTask cancel];
}

- (IBAction)suspend:(id)sender {
    [_downloadTask suspend];
    kApplication.networkActivityIndicatorVisible = NO;
}

- (IBAction)resume:(id)sender {
    [_downloadTask resume];
}

#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    NSLog(@"已经接收到响应数据，数据长度为%lld字节...", totalBytesWritten);
    
    [self updateProgress:totalBytesWritten totalDataLength:totalBytesExpectedToWrite];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    //下载文件会临时保存，正常流程下系统最终会自动清除此临时文件；保存路径目录根据会话类型而有所不同：
    //「进程内会话（默认会话）」和「临时的进程内会话（内存）」，路径目录为：/tmp，可以通过 NSTemporaryDirectory() 方法获取
    //「后台会话」，路径目录为：/Library/Caches/com.apple.nsurlsessiond/Downloads/com.kenmu.KMDownloadFile
    NSLog(@"已经接收完所有响应数据，下载后的临时保存路径：%@", location);
    
    __block void (^updateUI)(); //声明用于主线程更新 UI 的代码块
    
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
    
    dispatch_async(dispatch_get_main_queue(), updateUI); //使用主队列异步方式（主线程）执行更新 UI 的代码块
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    NSLog(@"无论下载成功还是失败，最终都会执行一次");
    
    if (error) {
        NSString *desc = error.localizedDescription;
        NSLog(@"下载失败，错误信息：%@", desc);
        
        dispatch_async(dispatch_get_main_queue(), ^{ //使用主队列异步方式（主线程）执行更新 UI 操作
            _lblMessage.text = [desc isEqualToString:@"cancelled"] ? @"下载已取消" : @"下载失败";
            kApplication.networkActivityIndicatorVisible = NO;
            _progVDownloadFile.progress = 0.0;
        });
    }
}

@end
