//
//  ViewController.m
//  QYAsynDownloadDemo
//
//  Created by qianye on 16/7/19.
//  Copyright © 2016年 qianye. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation ViewController {
    NSArray *_arrSampleName;
    NSArray *_arrSampleClass;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)awakeFromNib {
    [super awakeFromNib];
    self.navigationItem.title = @"多种方式实现文件下载功能";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    _arrSampleName = @[kTitleOfNSURLConnection,
                       kTitleOfNSURLConnectionDelegate,
                       kTitleOfNSURLSession,
                       kTitleOfNSURLSessionDelegate,
                       kTitleOfAFNetworking,
                       kTitleOfNSURLConnectionUpload,
                       kTitleOfNSURLSessionUpload,
                       kTitleOfAFNetworkingUpload];
    
    _arrSampleClass = @[@"NSURLConnectionDownload",
                        @"NSURLConnectionDelegateDownload",
                        @"NSURLSessionDownload",
                        @"NSURLSessionDelegateDownload",
                        @"AFNetworkingDownload",
                        @"NSURLConnectionUpload",
                        @"NSURLSessionUpload",
                        @"AFNetworkingUpload"];
}

#pragma mark - UITableViewController

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _arrSampleName.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = _arrSampleName[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *vc = [[NSClassFromString([_arrSampleClass objectAtIndex:indexPath.row]) alloc] init];
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
