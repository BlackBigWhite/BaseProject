# QBNetworking

[![CI Status](http://img.shields.io/travis/lizhihui/QBNetworking.svg?style=flat)](https://travis-ci.org/lizhihui/QBNetworking)
[![Version](https://img.shields.io/cocoapods/v/QBNetworking.svg?style=flat)](http://cocoapods.org/pods/QBNetworking)
[![License](https://img.shields.io/cocoapods/l/QBNetworking.svg?style=flat)](http://cocoapods.org/pods/QBNetworking)
[![Platform](https://img.shields.io/cocoapods/p/QBNetworking.svg?style=flat)](http://cocoapods.org/pods/QBNetworking)

## 钱包网络请求框架简介

由于需要适应多个平台的网络请求(加解密方式,参数打包方式,状态码类型的不同),所以我们把网络请求设计成一个单纯的数据请求通道,对于差异化的部分抽象成数据请求模型(`QBRequestModel`)和数据响应模型(`QBResponseModel`).所以您在使用这套请求框架的时候需要根据您自己的实际需要子类化这两个模型,比如:网络请求头你需要在`QBRequestModel`的子类中实现方法`httpHeader`.

## 提供的功能

基本的POST/GET请求;<br>
网络请求批处理;<br>
网络请求参数和响应的加解密;<br>
动态监听网络状态;<br>

## 使用方法

### 初始化

`[QBNetworkingManager manager]`:实例化网络请求类(单例).
`[[QBNetworkingManager manager]enableLog:YES]`:是否打印网络请求过程中的日志,默认不打印.
`[QBNetworkingManager manager].certificateNames = @[@"qianbao"]`:网络请求中用到的证书,如果是https,且该站点不是CA的根证书,则需要引入,证书的扩展名为"cer".

### POST/GET请求

```
CustomReqModel *model = [CustomReqModel new];实例化数据请求模型
[model setEncyType:QBCodeTypeDES];设置参数加密方式
model.url = @"https://apis.qianbao.com/bank_union/v1/app/login";
model.key = @"LCCBYTM2MTYwYjctZjdhZC00ZDE5LWI5MzEtZTllNGI0YjY2MjIyIOS";
model.para = @{
               @"mobilePhone":@"18210281536",
               @"pwd":@"cWIwMDAwMDA=",
               };
[[QBNetworkingManager manager] POST:model successBlock:^(QBResponseModel *responseObj) {
    NSLog(@"request successful : %@",responseObj);
    } failBlock:^(NSError *error) {
    NSLog(@"request failed : %@",error);
}];
```
### 批处理

```
CustomReqModel *model = [CustomReqModel new];
[model setEncyType:QBCodeTypeDES];
model.url = @"https://apis.qianbao.com/bank_union/v1/app/login";
model.key = @"LCCBYTM2MTYwYjctZjdhZC00ZDE5LWI5MzEtZTllNGI0YjY2MjIyIOS";
model.para = @{
               @"mobilePhone":@"18210281536",
               @"pwd":@"cWIwMDAwMDA=",
               @"code":@"",
              };
NSURLSessionDataTask *task1 = [[QBNetworkingManager manager] POST:model successBlock:^(QBResponseModel *responseObj) {
     NSLog(@"task1 request successful : %@",responseObj);
} failBlock:^(NSError *error) {
     NSLog(@"task1 request failed : %@",error);
}];
NSURLSessionDataTask *task2 = [[QBNetworkingManager manager] POST:model successBlock:^(QBResponseModel *responseObj) {
     NSLog(@"task2 request successful : %@",responseObj);
} failBlock:^(NSError *error) {
     NSLog(@"task2 request failed : %@",error);
}];
[[QBNetworkingManager manager] batchOfRequestTasks:@[task1,task2] progressBlock:^(NSUInteger numberOfFinishedTasks, NSUInteger totalNumberOfTasks) {
     NSLog(@"--------------------批处理进度---------------------");
     NSLog(@"--------------------完成%zi-总数%zi---------------------",numberOfFinishedTasks,totalNumberOfTasks);
} completionBlock:^(NSArray<NSURLSessionDataTask *> *operations) {
     NSLog(@"------------批处理结束----------------");
}];
```
### 网络状态

`[QBNetworkingManager manager].networkStatus`:您可以用这个属性判断当前网络状态,也可以监听该属性获取实时的网络状态.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

QBNetworking is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "QBNetworking"
```

## Author

lizhihui, lizh@qianbao.com

## License

QBNetworking is available under the MIT license. See the LICENSE file for more info.

![qianbao](http://www.qianbao.com/)


