QYAsynDownloadDemo
====
>最近在做项目的时候接触到下载相关需要，于是在多番查找资料之后有了一些发现，现在在这里总结一下，同时希望能帮到有需要的同学。  
本项目demo使用了[CocoaPods](http://guides.cocoapods.org/using/getting-started.html#toc_3)管理第三方，其中使用到了：[AFNetworking](https://github.com/AFNetworking/AFNetworking) 3.1.0、[MBProgressHUD](https://github.com/jdg/MBProgressHUD) 1.0.0。 

###1.NSURLConnection上传下载
苹果在iOS 9正式弃用NSURLConnection，同时作为非常热门的网络请求框架AFNetworking在3.0版本中删除了基于 NSURLConnection API的所有支持，但是作为一个开发者，我们还是很有必要了解这种请求的使用去兼容老项目的。
  
* NSURLConnection下载：NSURLConnection下载有两种方式，一种是直接下载，一种是使用代理的方式下载。直接下载是通过调用NSURLConnection类方法(发送异步请求，当然也有同步请求的方式，由于本次演示的是上传于下载，之后所有请求方式都指的是异步请求方式，同步方法可自行了解)：
`+ (void)sendAsynchronousRequest:(NSURLRequest*) request
                          queue:(NSOperationQueue*) queue
              completionHandler:(void (^)(NSURLResponse* _Nullable response, NSData* _Nullable data, NSError* _Nullable connectionError))`
代理方式方式则是在创建NSURLConnection时为其设置代理对象
`- (nullable instancetype)initWithRequest:(NSURLRequest *)request delegate:(nullable id)delegate`
请求过程与结果全是通过代理方法返回(代理方法也请自行了解)
* NSURLConnection上传：使用NSURLConnection上传，其请求头与请求体可能相对麻烦些，需要自行拼凑，但是看过AFNetworking 2.x有关上传的源码的话就会简单很多。首先我们需要了解一些上传请求的一些组成：![image](https://github.com/peanutNote/QYAsynDownloadDemo/blob/master/QYAsynDownloadDemo/demoImage1.jpeg)
这是通过google浏览器上传中捕获的请求参数，图中标记的部分需要重点注意。首先是请求头Headers中的*Content-Type*所对应的*multipart/form-data*与*boundary=----WebKitFormBoundaryFl8k0ntITA5cw3Ll*，*multipart/form-data*是一种类似POST的请求方式，而后面的*boundary=----……*则是一种占位符，代表我们规定的分割符，可以自己任意规定，但为了避免与请求体中的内容重复，尽量使用复杂一点的内容，接在看下面的请求体，这里我们使用抓包软件截取该上传请求：![image](https://github.com/peanutNote/QYAsynDownloadDemo/blob/master/QYAsynDownloadDemo/demoImage2.jpeg)
中间那一堆乱码就是图片数据，接下来我们只要仿照这种样式拼接请求体就行了：第一行是*----(占位符)*，第二行是*Content-Disposition*，然后换行(注意这里的换行必不可少包括后面的其他参数)，第三行则是*Content-Type*则是此次上传文件的[类型](http://www.iana.org/assignments/media-types/media-types.xhtml)，如果有请求其他参数拼接方式也图片相似，就是不要*Content-Type*这行数据。拼接完这些后就可以通过NSURLConnection的同步或者异步请求方式发送请求就行了

###2.NSURLSession上传下载
NSURLSession在iOS7.0时被Apple提出，但由于其功能上与NSURLConnection不相伯仲同时AFNetworking优秀的架构设计导致NSURLSession不怎么为人所知，然而2015年5月RFC 7540正式发表的下一代HTTP协议：HTTP /2，相对于前一个版本，HTTP /2以快著称，因此2015年WWDC上苹果决定NSURLSession开始正式支持HTTP /2，并大力支持使用NSURLSession，废弃NSURLConnection

* NSURLSession下载：与NSURLConnection相似，NSURLSession下载也有两种方式，一种是通过block的直接方式，一种是代理方式。直接方式是通过*NSURLSessionDownloadTask*的方法实现，具体的可以看demo代码。另一种代理方式需要通过
`+ (NSURLSession *)sessionWithConfiguration:(NSURLSessionConfiguration *)configuration delegate:(nullable id <NSURLSessionDelegate>)delegate delegateQueue:(nullable NSOperationQueue *)queue`
方法创建NSURLSession对象，其中的的各种配置也请参考demo中的代码，最后通过`- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request`方式发送请求同时返回NSURLSessionDownloadTask对象用于控制该请求过程(如:开始、取消、挂起、恢复)

###3.AFNetworking上传下载
前面已经介绍了，AFNetworking是一个非常优秀的网络请求框架，其实在AFNetworking 2.x时就已经加入了NSURLSession的内容，到苹果废弃NSURLConnection转为NSURLSession后，AFNetworking也相应升级到了3.x同时去掉了之前使用NSURLConnection相关方法，如果你的项目想升级到3.x请参考备注

* AFNetworking检测网络：在2.x我们使用的是AFHTTPRequestOperationManager属性reachabilityManager来监控网络状态，而在3.x中则是使用AFHTTPSessionManager属性reachabilityManager。具体代码请参考demo代码
* AFNetworking下载(主要介绍3.x中的使用方法)：首先是创建一个*AFURLSessionManager*对象，通过其：
`- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request
                                             progress:(NSProgress * __autoreleasing *)progress
                                          destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                    completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler`
方法设置请求同时返回NSURLSessionDownloadTask对象用于控制请求过程，该请求的回调则是通过设置AFURLSessionManager方式中的block回调来实现的：
`- (void)setDownloadTaskDidWriteDataBlock:(void (^)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite))block
`
`- (void)setDownloadTaskDidFinishDownloadingBlock:(NSURL * (^)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, NSURL *location))block
`
* AFNetworking上传：AFNetworking上传相对于NSURLSession与NSURLConnection来说就简单很多了，它已经将上传的请求头与请求体封装好了(封装的结构和原理与上面基本相似)，可以通过方法：
`- (AFHTTPRequestOperation *)POST:(NSString *)URLString
                      parameters:(id)parameters
       constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure`
创建请求，在*constructingBodyWithBlock*中拼接上传文件信息，具体实现可以自行了解AFNetworking代码

###4.总结
说了这么多上传下载的方法，由于篇幅原因实际上原理的内容涉及很少，这些都需要我们自己去了解才能保证在使用方法中不会出错，也可以更加灵活，毕竟再多方法原理其实都一样的嘛

备注：关于AFNetworking 3.x的迁移可以参考：[https://github.com/AFNetworking/AFNetworking/wiki/AFNetworking-3.0-Migration-Guide#new-requirements-ios-7-mac-os-x-109-watchos-2-tvos-9--xcode-7](https://github.com/AFNetworking/AFNetworking/wiki/AFNetworking-3.0-Migration-Guide#new-requirements-ios-7-mac-os-x-109-watchos-2-tvos-9--xcode-7)，国内大牛相关翻译参考：[暮落晨曦简书](http://www.jianshu.com/p/047463a7ce9b)。  