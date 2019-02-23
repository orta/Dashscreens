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

@interface PrefsController()
@property (weak) IBOutlet APIController *api;
@property (weak) IBOutlet NSTextField *tagsTextField;
@end

@implementation PrefsController

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.prefsWindow becomeFirstResponder];
}

- (NSArray <Link*> *)filteredLinks
{
    return [self.allLinks filter:^BOOL(Link *link) {
        NSArray *tags = [self.tagsTextField.stringValue componentsSeparatedByString:@" "];
        for (NSString *tag in tags) {
            for (NSString *linkTag in link.tags) {
                if ([linkTag isEqualToString:tag]) {
                    return YES;
                }
            }
        }
        return NO;
    }];
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
    if(!self.writableMode) {
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

- (IBAction)newFullScreenWindow:(id)sender {
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
    NSIndexSet *selected = [tableview selectedRowIndexes];



    self.activeLinks = [self.allLinks filter:^BOOL(Link *link) {
        NSInteger index = [self.allLinks indexOfObject:link];
        return [selected containsIndex:index];
    }];



}

@end
