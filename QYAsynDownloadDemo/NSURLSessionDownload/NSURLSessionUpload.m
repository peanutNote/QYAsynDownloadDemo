//
//  NSURLSessionUpload.m
//  QYAsynDownloadDemo
//
//  Created by qianye on 16/8/30.
//  Copyright © 2016年 qianye. All rights reserved.
//

#import "NSURLSessionUpload.h"
#import "QYCreateUploadRequest.h"

@interface NSURLSessionUpload () <NSURLSessionDelegate>
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
- (IBAction)uploadFileBySession:(id)sender;

@end

@implementation NSURLSessionUpload

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)uploadFileBySession:(id)sender {
    // 方法一
    //创建会话配置「进程内会话」
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.timeoutIntervalForRequest = 60.0; //请求超时时间；默认为60秒
    sessionConfiguration.allowsCellularAccess = YES; //是否允许蜂窝网络访问（2G/3G/4G）
    sessionConfiguration.HTTPMaximumConnectionsPerHost = 4; //限制每次最多连接数；在 iOS 中默认值为4
    
    //创建会话管理器
    // 对于这里的delegateQueue一点说明：If nil, the session creates a serial operation queue for performing all delegate method calls and completion handler calls.
    // 所以其代理方法中如果有对UI的修改需要放到主线程中执行
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    
    //创建请求
    NSURLSessionUploadTask *task = [session uploadTaskWithStreamedRequest:[QYCreateUploadRequest createUploadDataWithURL:kUploadURLStr images:@[[UIImage imageNamed:@"qrcode.png"]] parameterOfimages:@"images" parameters:@{@"appname":@"cmmapp", @"name" : @"qianye"} compressionRatio:1.0]];
    [task resume];
}

- (void)updateUIOnMainThreadWithText:(NSString *)text {
    dispatch_async(dispatch_get_main_queue(), ^{
        _resultLabel.text = text;
    });
}

#pragma mark - NSURLSessionDelegate

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend{
    NSLog(@"已经上传%lld字节", totalBytesExpectedToSend);
    [self updateUIOnMainThreadWithText:@"上传中..."];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    if (!error) {
        NSLog(@"上传成功");
        [self updateUIOnMainThreadWithText:@"上传成功"];
    } else {
        NSLog(@"上传失败");
        [self updateUIOnMainThreadWithText:@"上传成功"];
    }
}

@end
