//
//  QBWebViewController.h
//  QBCore
//
//  Created by Qiaokai on 2017/3/3.
//  Copyright © 2017年 QianBao. All rights reserved.
//

#import "QBViewController.h"
#import "QBWebView.h"
#import "QBWebViewModel.h"
#import "QBScriptMessage.h"
#import <WebViewJavascriptBridge/WKWebViewJavascriptBridge.h>

@interface QBWebViewController : QBViewController



- (void)endRefresh;//!<结束下拉刷新.
- (void)endLoadMore;//!<结束加载更多.
- (BOOL)isRefreshing;//!<是否在刷新.
- (BOOL)isLoadingMore;//!<是否正在加载更多.
- (void)isCanRefresh:(BOOL)refresh;//!<是否支持下拉刷新.
- (void)isCanLoadMore:(BOOL)loadMore;//!<是否支持加载更多.

@end
