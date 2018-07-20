//
//  ScreenViewController.m
//  Dashscreens
//
//  Created by Orta Therox on 7/19/18.
//  Copyright © 2018 Orta Therox. All rights reserved.
//

#import "ScreenViewController.h"
#import <WebKit/WebKit.h>

@interface WKPreferences (WKPrivate)
@property (nonatomic, setter=_setDeveloperExtrasEnabled:) BOOL _developerExtrasEnabled;
@end

@interface ScreenViewController () <WKUIDelegate, WKNavigationDelegate>
@property (strong) WKProcessPool *webViewProcessPool;
@property (weak) WKWebView *webView;
@property NSInteger index;
@end

@implementation ScreenViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear
{
    [super viewWillAppear];

    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.processPool = [self processPool];
    config.preferences._developerExtrasEnabled = YES;
    config.preferences.javaScriptCanOpenWindowsAutomatically = YES;
    config.applicationNameForUserAgent = @"Safari";

    WKWebView *webview = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    [self.view addSubview:webview];
    self.webView = webview;

    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;

    self.index = -1;
    [self showNextLink];
}

- (id)processPool
{
    if (!_webViewProcessPool) {
        _webViewProcessPool = [[WKProcessPool alloc] init];
    }
    return _webViewProcessPool;
}

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    // when there'd normally be a popup, e.g. for oauth, just show it in the main frame instead
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

- (void)showNextLink
{
    self.index++;
    if (self.index == self.links.count) {
        self.index = 0;
    }

    Link *link = self.links[self.index];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:link.href]];
    [self.webView loadRequest:request];
}



@end
