# QBRefresh

[![CI Status](http://img.shields.io/travis/lizhihui/QBRefresh.svg?style=flat)](https://travis-ci.org/lizhihui/QBRefresh)
[![Version](https://img.shields.io/cocoapods/v/QBRefresh.svg?style=flat)](http://cocoapods.org/pods/QBRefresh)
[![License](https://img.shields.io/cocoapods/l/QBRefresh.svg?style=flat)](http://cocoapods.org/pods/QBRefresh)
[![Platform](https://img.shields.io/cocoapods/p/QBRefresh.svg?style=flat)](http://cocoapods.org/pods/QBRefresh)

## 简单的例子

### Refresh_T1 刷新样式引入

> 1.接入
>```
self.scrollView.qb_header = [QBRefreshHeader headerWithRefreshingBlock:^{
   //put request data code here.
}];
```

> 2.开始刷新<br/>
>  `- (void)beginRefreshing;`<br/>
> 3.停止刷新<br/>
> `- (void)endRefreshing;`以及`- (void)endRefreshingLoadSuccess:(BOOL)success;`<br/>
> 4.查询刷新状态<br/>
> `- (BOOL)isRefreshing;`<br/>

### Refresh_T2 刷新样式引入

> 1.接入
>```
self.scrollView.qb_header = [QBRefreshHeader_T2 headerWithRefreshingBlock:^{
//put request data code here.
}];
```

> 2.开始刷新<br/>
>  `- (void)beginRefreshing;`<br/>
> 3.停止刷新<br/>
> `- (void)endRefreshing;`以及`- (void)endRefreshingLoadSuccess:(BOOL)success;`<br/>
> 4.查询刷新状态<br/>
> `- (BOOL)isRefreshing;`<br/>

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

QBRefresh is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "QBRefresh" 或者 pod "QBRefresh/Refresh_T1" 或者 pod "QBRefresh/Refresh_T2"
```

## Author

lizhihui, lizh@qianbao.com

## License

QBRefresh is available under the MIT license. See the LICENSE file for more info.


