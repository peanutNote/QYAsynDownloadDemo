//
//  QYCreateUploadData.h
//  QYAsynDownloadDemo
//
//  Created by qianye on 16/7/22.
//  Copyright © 2016年 qianye. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QYCreateUploadRequest : NSObject

/**
 *  上传图片以及其他参数（如果要上传其他文件，需要指定特定的Content-Type，具体文件扩展名对应的值请参考MIME 类型：http://www.w3school.com.cn/media/media_mimeref.asp）
 *  AFNetworking中提供的参考文档http://www.iana.org/assignments/media-types/media-types.xhtml
 *
 *  @param url        上传的地址
 *  @param images 图片的全名，如：image.png
 *  @param parameter  上传图片名需要与接受者规定名一致
 *  @param parameters 要上传的其他参数
 *
 *  @return url请求
 */
+ (NSURLRequest *)createUploadDataWithURL:(NSString *)url
                                   images:(NSArray *)images
                        parameterOfimages:(NSString *)parameter
                               parameters:(NSDictionary *)parameters
                         compressionRatio:(float)ratio;

/**
 *  上传带图片的内容，允许多张图片上传（URL）POST
 *
 *  @param url                 网络请求地址
 *  @param images              要上传的图片数组（注意数组内容需是图片）
 *  @param parameter           图片数组对应的参数
 *  @param parameters          其他参数字典
 *  @param ratio               图片的压缩比例（0.0~1.0之间）
 *  @param succeedBlock        成功的回调
 *  @param failedBlock         失败的回调
 *  @param uploadProgressBlock 上传进度的回调
 */
+ (void)startMultiPartUploadTaskWithURL:(NSString *)url
                           imagesArray:(NSArray *)images
                     parameterOfImages:(NSString *)parameter
                        parametersDict:(NSDictionary *)parameters
                      compressionRatio:(float)ratio
                          succeedBlock:(void(^)(id operation, id responseObject))succeedBlock
                           failedBlock:(void(^)(id operation, NSError *error))failedBlock
                   uploadProgressBlock:(void(^)(float uploadPercent,long long totalBytesWritten,long long totalBytesExpectedToWrite))uploadProgressBlock;

+ (NSMutableURLRequest *)downloadRequest;
+ (NSMutableURLRequest *)uploadRequest;

@end
