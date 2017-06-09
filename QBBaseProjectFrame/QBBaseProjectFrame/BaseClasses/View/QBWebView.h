//
//  QBWebView.h
//  QBBaseProjectFrame
//
//  Created by Qiaokai on 2017/3/10.
//  Copyright © 2017年 qianbao. All rights reserved.
//

#import <WebKit/WebKit.h>

@class QBWebView;
@class QBScriptMessage;

@protocol QBWKWebViewMessageHandleDelegate <NSObject>

@optional
- (void)webView:(nonnull QBWebView *)webView didReceiveScriptMessage:(nonnull QBScriptMessage *)message;

@end


@interface QBWebView : WKWebView <WKScriptMessageHandler,QBWKWebViewMessageHandleDelegate>

//webview加载的url地址
@property (nullable, nonatomic, copy) NSString *webViewRequestUrl;

@property (nullable, nonatomic, weak) id<QBWKWebViewMessageHandleDelegate> messageHandlerDelegate;

#pragma mark - Load Url

- (void)loadRequestWithUrl:(nonnull NSString *)url;

/**
 *  加载本地HTML页面
 *
 *  @param htmlName html页面文件名称
 */
- (void)loadLocalHTMLWithFileName:(nonnull NSString *)htmlName;

#pragma mark - View Method

/**
 *  重新加载webview
 */
- (void)reloadWebView;

#pragma mark - JS Method Invoke

/**
 *  调用JS方法（无返回值）
 *
 *  @param jsMethod JS方法名称
 */
- (void)callJS:(nonnull NSString *)jsMethod;

/**
 *  调用JS方法（可处理返回值）
 *
 *  @param jsMethod JS方法名称
 *  @param handler  回调block
 */
- (void)callJS:(nonnull NSString *)jsMethod handler:(nullable void(^)(__nullable id response))handler;


@end
