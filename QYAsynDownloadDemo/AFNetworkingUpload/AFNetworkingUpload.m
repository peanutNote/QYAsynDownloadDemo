//
//  AFNetworkingUpload.m
//  QYAsynDownloadDemo
//
//  Created by qianye on 16/7/25.
//  Copyright © 2016年 qianye. All rights reserved.
//

#import "AFNetworkingUpload.h"
#import "QYCreateUploadRequest.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"

@interface AFNetworkingUpload ()
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
- (IBAction)uploadFileByConnection:(UIButton *)sender;
- (IBAction)uploadFileBySession:(UIButton *)sender;

@end

@implementation AFNetworkingUpload {
    MBProgressHUD *_hud;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _hud = [[MBProgressHUD alloc] initWithView:self.view];
    _hud.mode = MBProgressHUDModeDeterminate;
    _hud.label.text = @"下载中...";
    [_hud hideAnimated:YES];
    [self.view addSubview:_hud];
}


- (IBAction)uploadFileByConnection:(UIButton *)sender {
    [QYCreateUploadRequest startMultiPartUploadTaskWithURL:kUploadURLStr imagesArray:@[[UIImage imageNamed:@"qrcode1.png"], [UIImage imageNamed:@"qrcode.png"]] parameterOfImages:@"image" parametersDict:@{@"appname":@"cmmapp", @"name" : @"qianye"} compressionRatio:1.0 succeedBlock:^(id operation, id responseObject) {
        _resultLabel.text = @"上传成功";
    } failedBlock:^(id operation, NSError *error) {
        _resultLabel.text = @"上传失败";
    } uploadProgressBlock:^(float uploadPercent, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        dispatch_async(dispatch_get_main_queue(), ^{ //使用主队列异步方式（主线程）执行更新 UI 操作
            _hud.progress = uploadPercent;
            if (totalBytesWritten == totalBytesExpectedToWrite) {
                _resultLabel.text =  totalBytesWritten < 0 ? @"上传失败" : @"上传完成";
                kApplication.networkActivityIndicatorVisible = NO;
                [_hud hideAnimated:YES];
            } else {
                _resultLabel.text = @"上传中...";
                kApplication.networkActivityIndicatorVisible = YES;
                [_hud showAnimated:YES];
            }
        });
    }];
}

- (IBAction)uploadFileBySession:(UIButton *)sender {
    NSData * imagedata = UIImageJPEGRepresentation([UIImage imageNamed:@"qrcode1"], 1.0);
    NSString *requestURL = [kUploadURLStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    // 方法一
    //创建会话配置「进程内会话」
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.timeoutIntervalForRequest = 60.0; //请求超时时间；默认为60秒
    sessionConfiguration.allowsCellularAccess = YES; //是否允许蜂窝网络访问（2G/3G/4G）
    sessionConfiguration.HTTPMaximumConnectionsPerHost = 4; //限制每次最多连接数；在 iOS 中默认值为4
    
    //创建会话管理器
    AFURLSessionManager *sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:sessionConfiguration];
    sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];

    //创建请求
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:requestURL parameters:@{@"appname":@"cmmapp", @"name" : @"qianye"} constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        NSString *fileName =[ NSString stringWithFormat:@"%@.png",str];
        [formData appendPartWithFileData:imagedata name:@"images" fileName:fileName mimeType:@"image/jpg/png/jpeg"];
    } error:nil];
    
    NSProgress *progress = nil;
    NSURLSessionUploadTask *task = [sessionManager uploadTaskWithStreamedRequest:request progress:&progress completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"上传成功");
            _resultLabel.text = @"上传成功";
        } else {
            NSLog(@"上传失败----%@", error.localizedDescription);
            _resultLabel.text = @"上传失败";
        }
    }];
    [task resume];
    
    [sessionManager setTaskDidSendBodyDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionTask * _Nonnull task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        _resultLabel.text = @"上传中...";
        NSLog(@"已经上传%lld字节", totalBytesSent);
    }];
    [sessionManager setTaskDidCompleteBlock:^(NSURLSession * _Nonnull session, NSURLSessionTask * _Nonnull task, NSError * _Nullable error) {
        NSLog(@"上传完成");
    }];

    /*
    // 方法二 AFNetworking 3.x以后POST方法会多出一个progress 实现进度条
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:nil sessionConfiguration:sessionConfiguration];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/plain", nil];
    [manager POST:requestURL parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        NSString *fileName =[ NSString stringWithFormat:@"%@.png",str];
        [formData appendPartWithFileData:imagedata name:@"images" fileName:fileName mimeType:@"image/jpg/png/jpeg"];
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSLog(@"上传成功");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"上传失败");
    }];
    
    [manager setTaskDidSendBodyDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionTask * _Nonnull task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"已经上传%lld字节", totalBytesSent);
    }];
    [manager setTaskDidCompleteBlock:^(NSURLSession * _Nonnull session, NSURLSessionTask * _Nonnull task, NSError * _Nullable error) {
        NSLog(@"上传完成");
    }];
     */
}

@end
