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

@property (strong) WKWebView *backWebView;
@property (strong) WKWebView *frontWebView;

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

    WKWebView *webview = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    webview.UIDelegate = self;
    webview.navigationDelegate = self;

    WKWebView *webview2 = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    webview2.UIDelegate = self;
    webview2.navigationDelegate = self;

    [self.view addSubview:webview2];
    [self.view addSubview:webview];

    self.frontWebView = webview;
    self.backWebView = webview2;

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

// Flips between two WKWebViews that keeps the data
// basically trying to avoid jumping content

- (void)showNextLink
{
    self.index++;
    if (self.index + 1 == self.links.count) {
        self.index = 0;
    }

    Link *link = self.links[self.index];

    // Move to front
    [self.backWebView removeFromSuperview];
    [self.view addSubview:self.backWebView];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:link.href]];
    [self.frontWebView loadRequest:request];

    NSLog(@"Showing: %@", link.href);
    NSLog(@"on: %@", self.backWebView);
    if (!self.debug) {
        // the 4 is loading time
        [self performSelector:@selector(showNextLink) withObject:nil afterDelay:link.time + 4];
    }

    // Switch the references
    WKWebView *intermediary = self.backWebView;
    self.backWebView = self.frontWebView;
    self.frontWebView = intermediary;
}


@end
