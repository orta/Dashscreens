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
#import "ScreenConstrainedWindow.h"

@interface PrefsController()
@property (weak) IBOutlet APIController *api;
@property (strong) NSArray <ScreenViewController *> *screens;
@property (strong) NSArray <Tag *> *currentTags;

@property (strong) NSTimer *screenCheckTimer;
@property (strong) NSTimer *linksReloadTimer;
@end

@implementation PrefsController

- (void)awakeFromNib
{
    self.screens = @[];

    [super awakeFromNib];
    [self.prefsWindow becomeFirstResponder];

    // somehow this is called a bunch of times
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        [self startReloadLoop];
        [self startScreenCheckLoop];
    });
}


- (void)generateDashboardWindow:(ScreenSize)size
{
    ScreenViewController *webVC = [[ScreenViewController alloc] init];
    webVC.links = self.activeLinks;

    webVC.preferredScreenDeviceID = [self.prefsWindow.screen displayID];
    webVC.screenSize = size;
    webVC.tags = self.currentTags;

    // Ensure we've got a list of all active screens
    self.screens = [self.screens arrayByAddingObject:webVC];

    /// We need to have a way to constrain a window to a particular screen
    /// this can only really be done by a subclass of nswindow
    /// https://stackoverflow.com/questions/10195977/how-to-change-the-nsscreen-a-nswindow-appears-on
    NSWindow *window = [ScreenConstrainedWindow windowWithContentViewController:webVC];
    window.styleMask = NSWindowStyleMaskBorderless;
    window.hasShadow = NO;
}

- (IBAction)newHalfWindowLeft:(id)sender
{
    [self generateDashboardWindow:ScreenSizeHalfLeft];
    [self screensDidUpdate];
}


- (IBAction)newHalfWindowRight:(id)sender
{
    [self generateDashboardWindow:ScreenSizeHalfRight];
    [self screensDidUpdate];
}

- (IBAction)newFullScreenWindow:(id)sender
{
    [self generateDashboardWindow:ScreenSizeFull];
    [self screensDidUpdate];
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

    self.currentTags = selectedTags;

    // Pull out all the links which have tags which are selected
    // these are then bound to the UI
    self.activeLinks = [self linksForTags:selectedTags];

    // So we can toggle the make dashboard buttons
    self.hasActiveLinks = self.activeLinks.count > 0;
}

- (NSArray <Link *> *)linksForTags:(NSArray <Tag *> *)tags
{
    return [self.allLinks filter:^BOOL(Link *link) {
        for (Tag *tag in tags) {
            if ([link.tags containsObject:tag.name]) {
                return YES;
            }
        }
        return NO;
    }];
}

// Open a version of the window so you can log in etc
- (IBAction)didDoubleClickInHrefs:(NSTableView *)tableView
{
    Link *link = self.activeLinks[tableView.selectedRow];

    ScreenViewController *webVC = [[ScreenViewController alloc] init];
    webVC.links = @[link, link];

    NSWindow *window = [NSWindow windowWithContentViewController:webVC];
    CGSize size = window.screen.frame.size;
    [window setContentSize: CGSizeMake(size.width/2, size.height)];
    [window setFrameOrigin:NSPointFromCGPoint(CGPointMake(size.width/2, 0))];

    [window makeKeyAndOrderFront:self];
    [window makeFirstResponder:window];
}

- (void)startReloadLoop
{
    // Every 1.5hr reload the CSV
    self.linksReloadTimer = [NSTimer scheduledTimerWithTimeInterval: 60 * 90
                                                             target: self
                                                           selector: @selector(updateFromAPI)
                                                           userInfo: nil
                                                            repeats: YES];
    [self updateFromAPI];
}

- (void)updateFromAPI
{
    [self.api getLinksFromGoogSheets:^{
        // Updates any running screen's links at runtime after an API update
        for (ScreenViewController *screenVC in self.screens) {
            screenVC.links = [self linksForTags:screenVC.tags];
        }
    }];
}

- (void)startScreenCheckLoop
{
    self.screenCheckTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0
                                                             target: self
                                                           selector: @selector(updateDisplayID)
                                                           userInfo: nil
                                                            repeats: YES];
    [self updateDisplayID];
}

- (void)updateDisplayID
{
    self.currentScreenDisplayName = [[self.prefsWindow screen] displayName];
    [self performSelector:@selector(updateDisplayID) withObject:nil afterDelay:(1)];
}

- (IBAction)openGitHub:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/orta/Dashscreens"]];
}

// Try to just have one functiuon for updating all layouts, so that when screens are added/removed
// everything will get updated
//
- (void)screensDidUpdate
{
    NSArray *screens = [NSScreen screens];
    NSMutableArray *emptyScreens = [NSMutableArray array];
    NSMutableArray *foundScreensForVC = [NSMutableArray arrayWithArray:self.screens];

    // Loop through all the current screens finding a potential VC (or two)
    for (NSScreen *screen in screens) {
        NSNumber *screenID = [screen displayID];
        BOOL found = NO;

        for (ScreenViewController *screenVC in self.screens) {
            if (screenID.doubleValue == screenVC.preferredScreenDeviceID.doubleValue) {
                // Shape the window
                [self setupWindow:screenVC.view.window size:screenVC.screenSize];
                // Remove the VC from the
                [foundScreensForVC removeObject:screenVC];
                // This means the screen won't be classed as unfound
                found = YES;
            }
        }

        if (!found) {
            [emptyScreens addObject: screen];
        }
    }

    // Unsure how this state will happen but I'm willing to provide some code to prepare
    if (emptyScreens.count && foundScreensForVC.count) {
        for (NSScreen *screen in emptyScreens) {
            ScreenViewController *screenVC = [foundScreensForVC firstObject];
            if (screenVC) {
                [foundScreensForVC removeObject:screenVC];
                [self setupWindow:screenVC.view.window size:screenVC.screenSize];
            }

        }
    }

}

- (void)setupWindow:(NSWindow *)window size:(ScreenSize)sizeType
{
    CGSize screenSize = window.screen.frame.size;

    // start off at half, migrate to full size if needed
    CGSize windowSize = CGSizeMake(screenSize.width/2, screenSize.height);
    if (sizeType == ScreenSizeFull) { windowSize = screenSize; }
    [window setContentSize: windowSize];


    // start off at left, migrate to half-way if needed
    CGPoint originPoint = CGPointZero;
    if (sizeType == ScreenSizeHalfRight) { originPoint = CGPointMake(windowSize.width, 0); }
    [window setFrameOrigin:originPoint];

    // Bring it to the front
    [window makeKeyAndOrderFront:self];
    [window makeFirstResponder:window];
}

@end
