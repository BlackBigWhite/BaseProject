//
//  QBWebViewController.m
//  QBCore
//
//  Created by Qiaokai on 2017/3/3.
//  Copyright © 2017年 QianBao. All rights reserved.
//

#import "QBWebViewController.h"
#import <MJRefresh/MJRefresh.h>

@interface QBWebViewController () <WKUIDelegate, QBWKWebViewMessageHandleDelegate, WKNavigationDelegate> {
    
    NSMutableDictionary *_backDict;
    BOOL isRefreshing;
}

@property (nonatomic, strong, readwrite) QBWebViewModel *viewModel;

@property (nonatomic, strong) QBWebView *webView;

@property (nonatomic, strong) WKWebViewJavascriptBridge *bridge;

@property (nonatomic, assign) NSInteger deep;                       ///<deep.


@end

@implementation QBWebViewController
@dynamic viewModel;


- (void)dealloc {
    NSLog(@"dealloc --- %@",NSStringFromClass([self class]));
    if (self.viewModel.shouldShowProgress) {
        [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    }
    
    if (self.viewModel.isUseWebPageTitle) {
        [self.webView removeObserver:self forKeyPath:@"title"];
    }
}

void swizzleMethod(Class class, SEL originalSelector, SEL swizzledSelector)
{
    // the method might not exist in the class, but in its superclass
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    // class_addMethod will fail if original method already exists
    BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    
    // the method doesn’t exist and we just added one
    if (didAddMethod) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }
    else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

+ (void)load {
    swizzleMethod([self class], NSSelectorFromString(@"evaluateJavaScript:completionHandler:"), @selector(altEvaluateJavaScript:completionHandler:));
}

- (void)altEvaluateJavaScript:(NSString *)javaScriptString completionHandler:(void(^)(id, NSError *))completionHandler {     id strongSelf = self;
    [self altEvaluateJavaScript:javaScriptString completionHandler:^(id r, NSError *e) {
        [strongSelf title];
        if(completionHandler) {
            completionHandler(r, e);
        }
    }];
}

#pragma mark - Life Circle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationBar.leftBarButtonItems = [self LeftBtns];
    
    isRefreshing = NO;
    
    [self setupWebView];
    
    self.bridge = [WKWebViewJavascriptBridge bridgeForWebView:_webView];
    [self.bridge setWebViewDelegate:self];
    
    self.deep = 0;
    
    if (self.viewModel.shouldShowProgress) {
        [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
    }
    
    if (self.viewModel.isUseWebPageTitle) {
        [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    }
    
    if (self.viewModel.url.length) {
        [self.webView loadRequestWithUrl:self.viewModel.url];
    }
    
    if (self.viewModel.htmlPath.length) {
        [self.webView loadLocalHTMLWithFileName:self.viewModel.htmlPath];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.webView.title || [self.webView.title isEqualToString:@""]) {
        [self refresh];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //    [self.navigationController hiddenSGProgress];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}


- (void)bindViewModel {
    [super bindViewModel];
    
}

#pragma mark - UI

- (void)setupWebView {
    WKUserContentController* userContentController = [WKUserContentController new];
    WKUserScript * cookieScript = [[WKUserScript alloc] initWithSource: @"document.cookie = 'skey=skeyValue';"injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [userContentController addUserScript:cookieScript];
    
    WKWebViewConfiguration *config = [WKWebViewConfiguration new];
    config.userContentController = userContentController;
    
    _webView = [[QBWebView alloc]initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 64) configuration:config];
    _webView.scrollView.scrollEnabled = self.viewModel.scrollEnabled;
    _webView.messageHandlerDelegate = self;
    _webView.navigationDelegate = self;
    _webView.UIDelegate = self;
    [self.view addSubview:_webView];
    
}

- (NSArray *)LeftBtns {//!<左侧导航栏按钮.
    UIBarButtonItem *goBack = [[UIBarButtonItem alloc] initWithImage:[self getImageByName:@"nav_back"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    return @[goBack];
}

- (NSArray *)LeftBtns2 {//!<左侧导航栏按钮.
    UIBarButtonItem *preStep = [[UIBarButtonItem alloc] initWithImage:[self getImageByName:@"setting_back"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    UIBarButtonItem *pop = [[UIBarButtonItem alloc] initWithImage:[self getImageByName:@"nav_back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    return @[preStep,pop];
}

#pragma mark - events

- (void)setDeep:(NSInteger)deep {
    _deep = deep;
    if (deep <= 1) {
        self.navigationBar.leftBarButtonItems = [self LeftBtns];
    }else {
        self.navigationBar.leftBarButtonItems = [self LeftBtns2];
    }
}

- (void)goBack {
    if ([self.webView canGoBack]) {
        self.deep -= 1;
        [self.webView goBack];
    }else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)refresh {
    if (self.webView.URL) {
        isRefreshing = YES;
        [self.webView reloadWebView];
    }
}

#pragma mark - private
- (void)registerNativeFunctions {
    
    @weakify(self);
    [_bridge registerHandler:@"lccb_login" handler:^(id data, WVJBResponseCallback responseCallback) {
        @strongify(self);
    }];
}

/**
 指定url，实时刷新
 */
- (void)againRefresh {
    //    if ([self.viewModel.startPage rangeOfString:h5_bid_content].length > 0) {
    //        [self refresh];
    //    }
    [self.bridge callHandler:@"lccb_countdownRefresh"];
    
}


#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        
        if (object == self.webView) {
            //            [self.navigationController setSGProgressPercentage:self.webView.estimatedProgress*100 andTintColor:[UIColor colorWithRed:24/255.0 green:124/255.0 blue:244/255.0f alpha:1.0]];
        }
        else{
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
    else if ([keyPath isEqualToString:@"title"]){
        if (object == self.webView) {
            if (self.viewModel.isUseWebPageTitle) {
                self.navigationBar.title = self.webView.title;
            }
        }
        else{
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - QBWKWebViewMessageHandleDelegate

/**
 *  JS调用原生方法处理
 */
- (void)webView:(QBWebView *)webView didReceiveScriptMessage:(QBScriptMessage *)message {
    
    NSLog(@"webView method:%@",message.method);
    
    //返回上一页
    if ([message.method isEqualToString:@"tobackpage"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    //打开新页面
    else if ([message.method isEqualToString:@"openappurl"]) {
        
        NSString *url = [message.params objectForKey:@"url"];
        if (url.length) {
        }
    }
}

#pragma mark - WKNavigationDelegate

/**
 *  页面开始加载时调用
 *
 *  @param webView    实现该代理的webview
 *  @param navigation 当前navigation
 */
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
    
    NSLog(@"%s：%@", __FUNCTION__,webView.URL);
}

/**
 *  当内容开始返回时调用
 *
 *  @param webView    实现该代理的webview
 *  @param navigation 当前navigation
 */
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    
    NSLog(@"%s", __FUNCTION__);
}

/**
 *  页面加载完成之后调用
 *
 *  @param webView    实现该代理的webview
 *  @param navigation 当前navigation
 */
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    NSLog(@"%s", __FUNCTION__);
    
    if (isRefreshing == NO) {
        self.deep += 1;
    }
    self.webView.hidden = NO;
    self.viewModel.successLoad = YES;
    isRefreshing = NO;
}

/**
 *  加载失败时调用
 *
 *  @param webView    实现该代理的webview
 *  @param navigation 当前navigation
 *  @param error      错误
 */
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
    NSLog(@"%s%@", __FUNCTION__,error);
    isRefreshing = NO;
    self.viewModel.successLoad = NO;
    [self endRefresh];
}

/**
 *  接收到服务器跳转请求之后调用
 *
 *  @param webView      实现该代理的webview
 *  @param navigation   当前navigation
 */
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    
    NSLog(@"%s", __FUNCTION__);
}

/**
 *  在收到响应后，决定是否跳转
 *
 *  @param webView            实现该代理的webview
 *  @param navigationResponse 当前navigation
 *  @param decisionHandler    是否跳转block
 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    
    NSLog(@"%s", __FUNCTION__);
    
    decisionHandler(WKNavigationResponsePolicyAllow);
}

/**
 *  在发送请求之前，决定是否跳转
 *
 *  @param webView          实现该代理的webview
 *  @param navigationAction 当前navigation
 *  @param decisionHandler  是否调转block
 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSLog(@"URL: %@", navigationAction.request.URL.absoluteString);
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    [webView reload];
}

- (NSString *)valueForParam:(NSString *)param inUrl:(NSURL *)url {
    
    NSArray *queryArray = [url.query componentsSeparatedByString:@"&"];
    for (NSString *params in queryArray) {
        NSArray *temp = [params componentsSeparatedByString:@"="];
        if ([[temp firstObject] isEqualToString:param]) {
            return [temp lastObject];
        }
    }
    return @"";
}

- (NSMutableDictionary *)paramsOfUrl:(NSURL *)url {
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    
    NSArray *queryArray = [url.query componentsSeparatedByString:@"&"];
    for (NSString *params in queryArray) {
        NSArray *temp = [params componentsSeparatedByString:@"="];
        NSString *key = [temp firstObject];
        NSString *value = temp.count == 2 ? [temp lastObject]:@"";
        [paramDict setObject:value forKey:key];
    }
    return paramDict;
}

- (NSString *)stringByJoinUrlParams:(NSDictionary *)params {
    
    NSMutableArray *arr = [NSMutableArray array];
    for (NSString *key in params.allKeys) {
        [arr addObject:[NSString stringWithFormat:@"%@=%@",key,params[key]]];
    }
    return [arr componentsJoinedByString:@"&"];
}

- (NSString *)urlWithoutQuery:(NSURL *)url {
    NSRange range = [url.absoluteString rangeOfString:@"?"];
    if (range.location != NSNotFound) {
        return [url.absoluteString substringToIndex:range.location];
    }
    return url.absoluteString;
}

#pragma mark - WKUIDelegate

/**
 *  处理js里的alert
 *
 */
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    
    //    if(/*UIViewController of WKWebView has finish push or present animation*/) {
    //        completionHandler();
    //        return;
    //    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确认"style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler();
    }]];
    //    if(/*UIViewController of WKWebView is visible*/)
    [self presentViewController:alertController animated:YES completion:nil];
}

/**
 *  处理js里的confirm
 */
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 刷新相关
- (void)endRefresh {
    [self.webView.scrollView.mj_header endRefreshing];
}

- (void)endLoadMore {
    [self.webView.scrollView.mj_footer endRefreshing];
}

- (BOOL)isRefreshing {
    return isRefreshing;
}

- (BOOL)isLoadingMore {
    return [self.webView.scrollView.mj_footer isRefreshing];
}

- (void)isCanRefresh:(BOOL)refresh {
    if (refresh == NO) {
        self.webView.scrollView.mj_header = nil;
    }
}
- (void)isCanLoadMore:(BOOL)loadMore {
    if (loadMore == NO) {
        self.webView.scrollView.mj_footer = nil;
    }
}

- (UIImage *)getImageByName:(NSString *)imageName{
    return [UIImage imageNamed:imageName];
}


#pragma mark - getter方法

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
