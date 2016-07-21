//
//  ViewController.m
//  QYAsynDownloadDemo
//
//  Created by qianye on 16/7/19.
//  Copyright © 2016年 qianye. All rights reserved.
//

#import "ViewController.h"
#import "NSURLConnectionViewController.h"
#import "NSURLConnectionDelegateViewController.h"
#import "NSURLSessionViewController.h"
#import "NSURLSessionDelegateViewController.h"
#import "AFNetworkingViewController.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.navigationItem.title = @"多种方式实现文件下载功能";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    _arrSampleName = @[kTitleOfNSURLConnection,
                       kTitleOfNSURLConnectionDelegate,
                       kTitleOfNSURLSession,
                       kTitleOfNSURLSessionDelegate,
                       kTitleOfAFNetworking];
}

- (instancetype)initWithSampleNameArray:(NSArray *)arrSampleName {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        
    }
    return self;
}


#pragma mark - UITableViewController相关方法重写
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_arrSampleName count];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: {
            NSURLConnectionViewController *connectionVC = [NSURLConnectionViewController new];
            [self.navigationController pushViewController:connectionVC animated:YES];
            break;
        }
        case 1: {
            NSURLConnectionDelegateViewController *connectionDelegateVC = [NSURLConnectionDelegateViewController new];
            [self.navigationController pushViewController:connectionDelegateVC animated:YES];
            break;
        }
        case 2: {
            NSURLSessionViewController *sessionVC = [NSURLSessionViewController new];
            [self.navigationController pushViewController:sessionVC animated:YES];
            break;
        }
        case 3: {
            NSURLSessionDelegateViewController *sessionDelegateVC = [NSURLSessionDelegateViewController new];
            [self.navigationController pushViewController:sessionDelegateVC animated:YES];
            break;
        }
        case 4: {
            AFNetworkingViewController *networkingVC = [AFNetworkingViewController new];
            [self.navigationController pushViewController:networkingVC animated:YES];
            break;
        }
        default:
            break;
    }
}

@end
