QYAsynDownloadDemo
====
最近在做项目的时候接触到下载相关需要，于是在多番查找资料之后发现一篇介绍非常详细关于iOS各种方式实现下载功能的博客。在满足项目需求的同时希望能将这几种方法都保存下来方便以后研究，由于博主只是将代码放在博客中并没有提供源代码demo的下载地址，小猿就自作主张将该博客的中的代码稍作整理成一个demo方便各位有需求的开发者下载使用。>.<   

由于demo中使用了cocoaPods，因此下载的各位大大mac需要有安装cocoaPods环境，这种教程网上很多就不多啰嗦了，小猿用的比较新的cocoaPods 1.0有问题可以注意一下。下载后再项目目录下执行`pod install`就可以了。

相比原博客代码，本demo中有如下一些修改  

* 更新使用AFNetworking 3.1.0
* 更新使用MBProgressHUD 1.0.0  

关于AFNetworking 3.x的迁移可以参考：[https://github.com/AFNetworking/AFNetworking/wiki/AFNetworking-3.0-Migration-Guide#new-requirements-ios-7-mac-os-x-109-watchos-2-tvos-9--xcode-7](https://github.com/AFNetworking/AFNetworking/wiki/AFNetworking-3.0-Migration-Guide#new-requirements-ios-7-mac-os-x-109-watchos-2-tvos-9--xcode-7)，国内大牛相关翻译参考：[暮落晨曦简书](http://www.jianshu.com/p/047463a7ce9b)。  

当然了这些都是些小修改，后期我会根据一些具体需求做部分更新，在这里再次感谢原博客作者`KenmuHuang`的无私奉献。原博客下载地址：[http://www.cnblogs.com/huangjianwu/p/4795568.html](http://www.cnblogs.com/huangjianwu/p/4795568.html)  
既然连代码都借鉴了，这里就继续把博客上的效果图也“借鉴”下吧：

![image](http://images2015.cnblogs.com/blog/66516/201509/66516-20150909174937122-1421325396.gif)