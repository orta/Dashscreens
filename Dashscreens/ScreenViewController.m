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
@property Link *frontLink;
@end

@implementation ScreenViewController

/// Set up 2 WKWebViews which cycle between the pages, this
/// is done to remove loading flashes ideally.

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
    webview.customUserAgent = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_4) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.1 Safari/605.1.15";

    WKWebView *webview2 = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    webview2.UIDelegate = self;
    webview2.navigationDelegate = self;
    webview2.customUserAgent = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_4) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.1 Safari/605.1.15";

    [self.view addSubview:webview2];
    [self.view addSubview:webview];

    self.frontWebView = webview;
    self.backWebView = webview2;

    self.backWebView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    self.frontWebView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;

    // It's weird, but this ensures both of the webviews work by
    // making them both the initial link.
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
    Link *link = self.frontLink;//[self linkForURL:webView.URL.absoluteString];

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

    // Hide the chrome around the chat in slack
    if ([link.type isEqualToString:@"slack"]) {
        // This page has a loading screen, so we need to give time for that to happen
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSString *removeSidebar = @"document.getElementsByClassName('client_channels_list_container')[0].style.display = 'none';";
            NSString *removeInput = @"document.getElementById('footer').style.display = 'none';";
            NSString *removeHeader = @"document.getElementById('client_header').style.display = 'none';";
            NSString *removeBanner = @"document.getElementById('banner').style.display = 'none';";

            NSString *js = [@[removeSidebar, removeInput, removeHeader, removeBanner] componentsJoinedByString:@""];

            [webView evaluateJavaScript:js completionHandler:^(id _Nullable value, NSError * _Nullable error) {}];
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
    self.frontLink = link;

    if (!self.debug) {
        // the 4 is loading time
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showNextLink) object:nil];
        [self performSelector:@selector(showNextLink) withObject:nil afterDelay:(link.time * 60) + 4];
    }

    // Switch the references
    WKWebView *intermediary = self.backWebView;
    self.backWebView = self.frontWebView;
    self.frontWebView = intermediary;
}


@end
