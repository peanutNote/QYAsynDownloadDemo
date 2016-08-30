//
//  NSURLConnectionUploadViewController.m
//  QYAsynDownloadDemo
//
//  Created by qianye on 16/7/22.
//  Copyright © 2016年 qianye. All rights reserved.
//

#import "NSURLConnectionUpload.h"
#import "QYCreateUploadRequest.h"

@interface NSURLConnectionUpload ()

@property (weak, nonatomic) IBOutlet UILabel *resultLabel;

@end

@implementation NSURLConnectionUpload

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


- (IBAction)uploadAction:(UIButton *)sender {
    _resultLabel.text = @"上传中...";
    [NSURLConnection sendAsynchronousRequest:[QYCreateUploadRequest createUploadDataWithURL:kUploadURLStr images:@[[UIImage imageNamed:@"qrcode1.png"], [UIImage imageNamed:@"qrcode.png"]] parameterOfimages:@"images" parameters:@{@"appname":@"cmmapp", @"name" : @"qianye"} compressionRatio:1.0]
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
                               if (!connectionError) {
                                   NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                   _resultLabel.text = @"上传成功";
                               } else {
                                   NSLog(@"上传失败，错误信息：%@", connectionError.localizedDescription);
                                   _resultLabel.text = @"上传失败";
                               }
                           }];
}

@end
