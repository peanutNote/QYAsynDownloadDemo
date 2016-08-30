//
//  NSURLConnectionDelegateViewController.m
//  QYAsynDownloadDemo
//
//  Created by qianye on 16/7/21.
//  Copyright © 2016年 qianye. All rights reserved.
//

#import "NSURLConnectionDelegateDownload.h"

@interface NSURLConnectionDelegateDownload ()
- (void)layoutUI;
- (BOOL)isExistCacheInMemory:(NSURLRequest *)request;
- (void)updateProgress;
@end

@implementation NSURLConnectionDelegateDownload

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self layoutUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)layoutUI {
    self.navigationItem.title = kTitleOfNSURLConnectionDelegate;
    self.view.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.000];
}

- (BOOL)isExistCacheInMemory:(NSURLRequest *)request {
    BOOL isExistCache = NO;
    NSURLCache *cache = [NSURLCache sharedURLCache];
    [cache setMemoryCapacity:1024 * 1024]; //1M
    
    NSCachedURLResponse *response = [cache cachedResponseForRequest:request];
    if (response != nil) {
        NSLog(@"内存中存在对应请求的响应缓存");
        isExistCache = YES;
    }
    return isExistCache;
}

- (void)updateProgress {
    NSUInteger receiveDataLength = _mDataReceive.length;
    if (receiveDataLength == _totalDataLength) {
        _lblMessage.text = @"下载完成";
        kApplication.networkActivityIndicatorVisible = NO;
    } else {
        _lblMessage.text = @"下载中...";
        kApplication.networkActivityIndicatorVisible = YES;
        _progVDownloadFile.progress = (float)receiveDataLength / _totalDataLength;
    }
}

- (IBAction)downloadFile:(id)sender {
    /*
     此例子更多的是希望大家了解代理方法接收响应数据的过程，实际开发中也不可能使用这种方法进行文件下载。这种下载有个致命的问题：无法进行大文件下载。因为代理方法在接收数据时虽然表面看起来是每次读取一部分响应数据，事实上它只有一次请求并且也只接收了一次服务器响应，只是当响应数据较大时系统会重复调用数据接收方法，每次将已读取的数据拿出一部分交给数据接收方法而已。在这个过程中其实早已经将响应数据全部拿到，只是分批交给开发者而已。这样一来对于几个G的文件如果进行下载，那么不用说是真机下载了，就算是模拟器恐怕也是不现实的。
     实际开发文件下载的时候不管是通过代理方法还是静态方法执行请求和响应，我们都会分批请求数据，而不是一次性请求数据。假设一个文件有1G，那么只要每次请求1M的数据，请求1024次也就下载完了。那么如何让服务器每次只返回1M的数据呢？
     在网络开发中可以在请求的头文件中设置一个Range信息，它代表请求数据的大小。通过这个字段配合服务器端可以精确的控制每次服务器响应的数据范围。例如指定bytes=0-1023，然后在服务器端解析Range信息，返回该文件的0到1023之间的数据的数据即可（共1024Byte）。这样，只要在每次发送请求控制这个头文件信息就可以做到分批请求。
     当然，为了让整个数据保持完整，每次请求的数据都需要逐步追加直到整个文件请求完成。但是如何知道整个文件的大小？其实在此例子通过头文件信息获取整个文件大小，他请求整个数据，这样做对分段下载就没有任何意义了。所幸在WEB开发中我们还有另一种请求方法“HEAD”，通过这种请求服务器只会响应头信息，其他数据不会返回给客户端，这样一来整个数据的大小也就可以得到了。
     */
    
    
    NSString *fileURLStr = kFileURLStr;
    //编码操作；对应的解码操作是用 stringByRemovingPercentEncoding 方法
    fileURLStr = [fileURLStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *fileURL = [NSURL URLWithString:fileURLStr];
    
    /*创建请求
     cachePolicy:缓存策略
     1、NSURLRequestUseProtocolCachePolicy 协议缓存，根据 response 中的 Cache-Control 字段判断缓存是否有效，如果缓存有效则使用缓存数据否则重新从服务器请求
     2、NSURLRequestReloadIgnoringLocalCacheData 不使用缓存，直接请求新数据
     3、NSURLRequestReloadIgnoringCacheData 等同于 NSURLRequestReloadIgnoringLocalCacheData
     4、NSURLRequestReturnCacheDataElseLoad 直接使用缓存数据不管是否有效，没有缓存则重新请求
     5、NSURLRequestReturnCacheDataDontLoad 直接使用缓存数据不管是否有效，没有缓存数据则失败
     
     timeoutInterval:超时时间设置（默认60s）
     */
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:fileURL
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:60.0];
    if ([self isExistCacheInMemory:request]) {
        request = [[NSURLRequest alloc] initWithURL:fileURL
                                        cachePolicy:NSURLRequestReturnCacheDataDontLoad
                                    timeoutInterval:60.0];
    }
    
    //创建连接，异步操作
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request
                                                                  delegate:self];
    [connection start]; //启动连接
}

#pragma mark - NSURLConnectionDataDelegate
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    NSLog(@"即将发送请求");
    
    return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"已经接收到响应");
    
    _mDataReceive = [NSMutableData new];
    _progVDownloadFile.progress = 0.0;
    
    //通过响应头中的 Content-Length 获取到整个响应的总长度
    /*
     {
     "Accept-Ranges" = bytes;
     "Cache-Control" = "max-age=7776000";
     "Content-Length" = 592441;
     "Content-Type" = "application/x-zip-compressed";
     Date = "Wed, 02 Sep 2015 13:17:01 GMT";
     Etag = "\"d8f617371f9cd01:0\"";
     "Last-Modified" = "Mon, 01 Jun 2015 03:58:27 GMT";
     Server = "Microsoft-IIS/7.5";
     "X-Powered-By" = "ASP.NET";
     }
     */
    NSDictionary *dicHeaderField = [(NSHTTPURLResponse *)response allHeaderFields];
    _totalDataLength = [[dicHeaderField objectForKey:@"Content-Length"] integerValue];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"已经接收到响应数据，数据长度为%lu字节...", (unsigned long)[data length]);
    
    [_mDataReceive appendData:data]; //连续接收数据
    [self updateProgress]; //连续更新进度条
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"已经接收完所有响应数据");
    
    NSString *savePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    savePath = [savePath stringByAppendingPathComponent:_lblFileName.text];
    [_mDataReceive writeToFile:savePath atomically:YES];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    //如果连接超时或者连接地址错误可能就会报错
    NSLog(@"连接错误，错误信息：%@", error.localizedDescription);
    
    _lblMessage.text = @"连接错误";
}

@end
