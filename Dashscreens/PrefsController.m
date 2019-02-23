//
//  PrefsController.m
//  Dashscreens
//
//  Created by Orta Therox on 6/25/18.
//  Copyright © 2018 Orta Therox. All rights reserved.
//

#import "PrefsController.h"
#import <AppKit/AppKit.h>
#import "ScreenViewController.h"
#import "APIController.h"
#import "Link.h"
#import "Extensions.h"
#import "NSObject+NSScreen_DisplayInfo.h"

@interface PrefsController()
@property (weak) IBOutlet APIController *api;
@property (strong) NSArray <NSWindow *>*windows;
@end

@implementation PrefsController

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.prefsWindow becomeFirstResponder];

    // somehow this is called a bunch of times
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        [self startReloadLoop];
        [self startScreenCheckLoop];
    });
}

- (IBAction)newHalfWindow:(id)sender
{
    NSWindow *window = [self generateWindow];

    CGSize size = [NSScreen mainScreen].frame.size;
    [window setContentSize: CGSizeMake(size.width/2, size.height)];
    [window setFrameOrigin:NSPointFromCGPoint(CGPointMake(0, 0))];
    [window makeKeyAndOrderFront:self];
    [window makeFirstResponder:window];
}

- (NSWindow *)generateWindow
{
    ScreenViewController *webVC = [[ScreenViewController alloc] init];
    webVC.links = self.activeLinks;
    webVC.debug = self.writableMode;

    NSWindow *window = [NSWindow windowWithContentViewController:webVC];
    if (!self.writableMode) {
        window.styleMask = NSWindowStyleMaskBorderless;
        window.hasShadow = NO;
    }

    return window;
}

- (IBAction)newHalfWindowRight:(id)sender
{
    NSWindow *window = [self generateWindow];

    CGSize size = [NSScreen mainScreen].frame.size;
    [window setContentSize: CGSizeMake(size.width/2, size.height)];
    [window setFrameOrigin:NSPointFromCGPoint(CGPointMake(size.width/2, 0))];
    [window makeKeyAndOrderFront:self];
    [window makeFirstResponder:window];
}

- (IBAction)newFullScreenWindow:(id)sender
{
    NSWindow *window = [self generateWindow];

    CGSize size = [NSScreen mainScreen].frame.size;
    [window setContentSize: size];
    [window setFrameOrigin:NSPointFromCGPoint(CGPointZero)];
    [window makeKeyAndOrderFront:self];
    [window makeFirstResponder:window];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSTableView *tableview = [notification object];
    BOOL isTagSelector = tableview.numberOfColumns == 1;
    if (isTagSelector) {
        [self didChangeSelectionForTagTableView:tableview];
    }
}

- (void)didChangeSelectionForTagTableView:(NSTableView *)tableView
{
    NSIndexSet *selected = [tableView selectedRowIndexes];
    NSArray <Tag *> *selectedTags =  [self.tags filter:^BOOL(Tag *link) {
                NSInteger index = [self.tags indexOfObject:link];
                return [selected containsIndex:index];
    }];


    self.activeLinks = [self.allLinks filter:^BOOL(Link *link) {
        for (Tag *tag in selectedTags) {
            if ([link.tags containsObject:tag.name]) {
                return YES;
            }
        }
        return NO;
    }];

    self.hasActiveLinks = self.activeLinks.count > 0;
}

- (IBAction)didDoubleClickInHrefs:(NSTableView *)tableView
{
    Link *link = self.activeLinks[tableView.selectedRow];

    ScreenViewController *webVC = [[ScreenViewController alloc] init];
    webVC.links = @[link, link];
    webVC.debug = YES;

    NSWindow *window = [NSWindow windowWithContentViewController:webVC];
    CGSize size = [NSScreen mainScreen].frame.size;
    [window setContentSize: CGSizeMake(size.width/2, size.height)];
    [window setFrameOrigin:NSPointFromCGPoint(CGPointMake(size.width/2, 0))];

    [window makeKeyAndOrderFront:self];
    [window makeFirstResponder:window];
}

- (void)startReloadLoop
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateFromAPI) object:nil];
    [self performSelector:@selector(updateFromAPI) withObject:nil afterDelay:(2 * 60)];
    [self updateFromAPI];
}

- (void)updateFromAPI
{
    [self.api getLinksFromGoogSheets];
}

- (void)startScreenCheckLoop
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateDisplayID) object:nil];
    [self performSelector:@selector(updateDisplayID) withObject:nil afterDelay:(1)];
    [self updateDisplayID];
}

- (void)updateDisplayID
{
    self.currentScreenDisplayName = [[self.prefsWindow screen] displayName];
}

- (IBAction)openGitHub:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/orta/Dashscreens"]];
}

- (void)screensDidUpdate
{

}

@end
