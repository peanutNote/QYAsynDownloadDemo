//
//  QYCreateUploadData.m
//  QYAsynDownloadDemo
//
//  Created by qianye on 16/7/22.
//  Copyright © 2016年 qianye. All rights reserved.
//

#import "QYCreateUploadRequest.h"
#import <CommonCrypto/CommonDigest.h>
#import "AFNetworking.h"

// 请求体里面的换行，因为有"\"需要转码
#define kHTTPBodyNewLine         [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding] //相当于回车
#define kHTTPPartOfParameter     @"Content-Disposition: form-data; name=\"%@\""

@implementation QYCreateUploadRequest

+ (NSURLRequest *)createUploadDataWithURL:(NSString *)url
                                   images:(NSArray *)images
                        parameterOfimages:(NSString *)parameter
                               parameters:(NSDictionary *)parameters
                         compressionRatio:(float)ratio;
{
    if (images.count == 0) {
        NSLog(@"上传内容没有包含图片");
        return nil;
    }
    for (int i = 0; i < images.count; i++) {
        if (![[images objectAtIndex:i] isKindOfClass:[UIImage class]]) {
            NSLog(@"images中第%d个元素不是UIImage对象",i+1);
            return nil;
        }
    }
    // 首先随机生成分隔符（这里为了避免重复采用AFNeworking的随机数生成方式）
    NSString *boundrary = [NSString stringWithFormat:@"Boundary+%08X%08X", arc4random(), arc4random()];
    
    // 创建请求request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST";
    // multipart/form-data是一种基于POST修改后的请求方式，具体参考rfc1867协议规定：http://www.faqs.org/rfcs/rfc1867.html
    request.allHTTPHeaderFields = @{@"Content-Type" : [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundrary]};
    
    // 创建请求提
    NSMutableData *uploadData = [NSMutableData data];
    /*请求体信息示例：下面将按照此格式进行拼接参数
     --Boundary+8FB2FED1B8ED838D
     Content-Disposition: form-data; name="image"; filename="image.png"
     Content-Type: image/jpeg
     
     "图片数据imageData"
     --Boundary+8FB2FED1B8ED838D
     Content-Disposition: form-data; name="userName"
     
     qianye
     --Boundary+8FB2FED1B8ED838D
     Content-Disposition: form-data; name="age"
     
     23
     ------WebKitFormBoundary3pVJSvbLhiFiCeZC--
     */
    // 拼接图片信息
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    for (int i = 0; i < images.count; i++) {
        UIImage *image = [images objectAtIndex:i];
        NSString *imageName = [NSString stringWithFormat:@"%@%d.png",dateString,i];
        NSData *imageData;
        if (ratio > 0.0f && ratio < 1.0f) {
            imageData = UIImageJPEGRepresentation(image, ratio);
        }else{
            imageData = UIImageJPEGRepresentation(image, 1.0f);
        }
        [uploadData appendData:[[NSString stringWithFormat:@"--%@", boundrary] dataUsingEncoding:NSUTF8StringEncoding]];
        [uploadData appendData:kHTTPBodyNewLine];
        
        [uploadData appendData:[[NSString stringWithFormat:@"%@; filename=\"%@\"", [NSString stringWithFormat:kHTTPPartOfParameter, parameter], imageName] dataUsingEncoding:NSUTF8StringEncoding]];
        [uploadData appendData:kHTTPBodyNewLine];
        
        [uploadData appendData:[@"Content-Type: image/png" dataUsingEncoding:NSUTF8StringEncoding]];
        [uploadData appendData:kHTTPBodyNewLine];
        [uploadData appendData:kHTTPBodyNewLine];
        
        // 图片数据
        [uploadData appendData:imageData];
        [uploadData appendData:kHTTPBodyNewLine];
    }
    
    for (NSString *key in parameters) {
        [uploadData appendData:[[NSString stringWithFormat:@"--%@", boundrary] dataUsingEncoding:NSUTF8StringEncoding]];
        [uploadData appendData:kHTTPBodyNewLine];
        
        [uploadData appendData:[[NSString stringWithFormat:kHTTPPartOfParameter, key] dataUsingEncoding:NSUTF8StringEncoding]];
        [uploadData appendData:kHTTPBodyNewLine];
        [uploadData appendData:kHTTPBodyNewLine];
        // 拼接参数值
        [uploadData appendData:[[parameters objectForKey:key] dataUsingEncoding:NSUTF8StringEncoding]];
        [uploadData appendData:kHTTPBodyNewLine];
    }
    
    [uploadData appendData:[[NSString stringWithFormat:@"--%@--",boundrary]
                            dataUsingEncoding:NSUTF8StringEncoding]];
    
    request.HTTPBody = uploadData;
    return request;
}

+ (void)startMultiPartUploadTaskWithURL:(NSString *)url
                           imagesArray:(NSArray *)images
                     parameterOfImages:(NSString *)parameter
                        parametersDict:(NSDictionary *)parameters
                      compressionRatio:(float)ratio
                          succeedBlock:(void (^)(id, id))succeedBlock
                           failedBlock:(void (^)(id, NSError *))failedBlock
                    uploadProgressBlock:(void (^)(float, long long, long long))uploadProgressBlock {
    
    if (images.count == 0) {
        NSLog(@"上传内容没有包含图片");
        return;
    }
    for (int i = 0; i < images.count; i++) {
        if (![[images objectAtIndex:i] isKindOfClass:[UIImage class]]) {
            NSLog(@"images中第%d个元素不是UIImage对象",i+1);
            return;
        }
    }
    AFHTTPRequestOperationManager * operationManager = [AFHTTPRequestOperationManager manager];
    operationManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    AFHTTPRequestOperation *operation = [operationManager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        int i = 0;
        //根据当前系统时间生成图片名称
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy年MM月dd日"];
        NSString *dateString = [formatter stringFromDate:date];
        
        for (UIImage *image in images) {
            NSString *fileName = [NSString stringWithFormat:@"%@%d.png",dateString,i];
            NSData *imageData;
            if (ratio > 0.0f && ratio < 1.0f) {
                imageData = UIImageJPEGRepresentation(image, ratio);
            }else{
                imageData = UIImageJPEGRepresentation(image, 1.0f);
            }
            
            [formData appendPartWithFileData:imageData name:parameter fileName:fileName mimeType:@"image/jpg/png/jpeg"];
        }
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        succeedBlock(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
        failedBlock(operation,error);
        
    }];
    
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        CGFloat percent = totalBytesWritten * 1.0 / totalBytesExpectedToWrite;
        uploadProgressBlock(percent,totalBytesWritten,totalBytesExpectedToWrite);
    }];
}

+ (NSMutableURLRequest *)downloadRequest {
    NSString *fileURLStr = kFileURLStr;
    //编码操作；对应的解码操作是用 stringByRemovingPercentEncoding 方法
    fileURLStr = [fileURLStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *fileURL = [NSURL URLWithString:fileURLStr];
    
    //创建请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:fileURL];
    return request;
}

+ (NSMutableURLRequest *)uploadRequest {
    NSString *fileURLStr = kUploadURLStr;
    //编码操作；对应的解码操作是用 stringByRemovingPercentEncoding 方法
    fileURLStr = [fileURLStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *fileURL = [NSURL URLWithString:fileURLStr];
    
    //创建请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:fileURL];
    return request;
}

@end
