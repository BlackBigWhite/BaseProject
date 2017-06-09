//
//  QBWebView.m
//  QBBaseProjectFrame
//
//  Created by Qiaokai on 2017/3/10.
//  Copyright © 2017年 qianbao. All rights reserved.
//

#import "QBWebView.h"
#import "QBScriptMessage.h"

@interface QBWebView ()

@property (nonatomic, strong) NSURL *baseUrl;

@end

@implementation QBWebView

- (instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration {
    self = [super initWithFrame:frame configuration:configuration];
    if (self) {
        if (configuration) {
            [configuration.userContentController addScriptMessageHandler:self name:@"webViewApp"];
        }
        self.baseUrl = [NSURL URLWithString:@""];
    }
    return self;
}


#pragma mark - Load Url

- (void)loadRequestWithUrl:(NSString *)url; {
    
    NSURL *URL = [NSURL URLWithString:url];
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
//    [request setAllHTTPHeaderFields:[self h5_header]];
    [request addValue:@"" forHTTPHeaderField:@"Cookie"];
    
    [self loadRequest:request];
    
}

/**
 *  加载本地HTML页面
 *
 *  @param htmlName html页面文件名称
 */
- (void)loadLocalHTMLWithFileName:(nonnull NSString *)htmlName {
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    NSString * htmlPath = [[NSBundle mainBundle] pathForResource:htmlName
                                                          ofType:@"html"];
    NSString * htmlCont = [NSString stringWithContentsOfFile:htmlPath
                                                    encoding:NSUTF8StringEncoding
                                                       error:nil];
    
    [self loadHTMLString:htmlCont baseURL:baseURL];
}

/**
 *  重新加载webview
 */
- (void)reloadWebView {
    [self loadRequestWithUrl:self.webViewRequestUrl];
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    NSLog(@"message:%@",message.body);
    if ([message.body isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *body = (NSDictionary *)message.body;
        
        QBScriptMessage *msg = [QBScriptMessage new];
        [msg setValuesForKeysWithDictionary:body];
        
        if (self.messageHandlerDelegate && [self.messageHandlerDelegate respondsToSelector:@selector(webView:didReceiveScriptMessage:)]) {
            [self.messageHandlerDelegate webView:self didReceiveScriptMessage:msg];
        }
    }
}

#pragma mark - JS

- (void)callJS:(NSString *)jsMethod {
    [self callJS:jsMethod handler:nil];
}

- (void)callJS:(NSString *)jsMethod handler:(void (^)(id _Nullable))handler {
    
    NSLog(@"call js:%@",jsMethod);
    [self evaluateJavaScript:jsMethod completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        if (handler) {
            handler(response);
        }
    }];
}



@end
