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
//    return [self.api.links filter:^BOOL(Link *link) {
//        NSString *text = self.tagsTextField.stringValue;
//        return [link.tags containsObject:text];
//    }];
    return self.api.links;
}

- (IBAction)newHalfWindow:(id)sender
{
    ScreenViewController *webVC = [[ScreenViewController alloc] init];
    webVC.links = [self filteredLinks];

    NSWindow *window = [NSWindow windowWithContentViewController:webVC];
    if(!self.writableMode) {
            window.styleMask = NSWindowStyleMaskBorderless;
            window.hasShadow = NO;

    }

    CGSize size = [NSScreen mainScreen].frame.size;
    [window setContentSize: CGSizeMake(size.width/2, size.height)];
    [window setFrameOrigin:NSPointFromCGPoint(CGPointMake(0, 0))];
    [window makeKeyAndOrderFront:self];
    [window makeFirstResponder:window];
}

- (IBAction)newHalfWindowRight:(id)sender
{
    ScreenViewController *webVC = [[ScreenViewController alloc] init];
    webVC.links = [self filteredLinks];

    NSWindow *window = [NSWindow windowWithContentViewController:webVC];
    window.styleMask = NSWindowStyleMaskBorderless;
    window.hasShadow = NO;

    CGSize size = [NSScreen mainScreen].frame.size;
    [window setContentSize: CGSizeMake(size.width/2, size.height)];
    [window setFrameOrigin:NSPointFromCGPoint(CGPointMake(size.width/2, 0))];
    [window makeKeyAndOrderFront:self];

}

@end
