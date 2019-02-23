//
//  ScreenViewController.m
//  Dashscreens
//
//  Created by Orta Therox on 7/19/18.
//  Copyright © 2018 Orta Therox. All rights reserved.
//

#import "ScreenViewController.h"
#import <WebKit/WebKit.h>
#import "Extensions.h"

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

    // It's weird, but this ensures both of the webviews work
    self.index = -1;
    [self showNextLink];
    self.index = -1;
    [self showNextLink];
}

- (Link *)linkForURL:(NSString *)href
{
    for (Link *link in self.links) {
        if ([link.href isEqualToString:href]) {
            return link;
        }
    }
    return nil;
}

- (void)replaceLink:(Link *)link withLinks:(NSArray <Link *>*)links
{
    NSInteger index = [self.links indexOfObject:link];
    if (index != NSNotFound) {
        NSMutableArray <Link *>*mutableLinks = self.links.mutableCopy;
        [mutableLinks removeObjectAtIndex:index];
        [mutableLinks addObjectsFromArray:links];
        self.links = [NSArray arrayWithArray:mutableLinks];
    }
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

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    Link *link = [self linkForURL:webView.URL.absoluteString];

    // We want to expand all of the individual pages from a project root for a galleries.io link
    // so that we can be lazy, and just say the main project.
    //

    if ([link.type isEqualToString:@"gallery project root"]) {
        // This page is JS rendered, so we need to give time for that to happen
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

            // throw this into safari's inspector to see what it does
            NSString *jsToGetData = @"Array.from(document.querySelectorAll('.thumbnail-item')).map(thumbnail => ({ name: thumbnail.querySelector('.file-name input').value, href: thumbnail.querySelector('a').href}) )";

            [webView evaluateJavaScript:jsToGetData completionHandler:^(id _Nullable value, NSError * _Nullable error) {
                NSLog(@"Got new pages:  %@", value);
                // It's an array of { name: string, href: string }
                if (value){
                    NSArray <Link *> *links = [value map:^id(id obj) {
                        return [Link linkWithHref:obj[@"href"] time:5 tags:[link.tags componentsJoinedByString:@" "] type:@"page" name:obj[@"name"]];
                    }];

                    [self replaceLink:link withLinks:links];
                    [self showNextLink];
                }
            }];
        });
    }
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
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showNextLink) object:nil];
        [self performSelector:@selector(showNextLink) withObject:nil afterDelay:link.time + 4];
    }

    // Switch the references
    WKWebView *intermediary = self.backWebView;
    self.backWebView = self.frontWebView;
    self.frontWebView = intermediary;
}


@end
