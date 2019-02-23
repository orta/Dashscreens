//
//  PrefsController.h
//  Dashscreens
//
//  Created by Orta Therox on 6/25/18.
//  Copyright © 2018 Orta Therox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "Link.h"
#import "Tag.h"

@interface PrefsController : NSObject <NSTableViewDelegate>

/// The main window for setting up your dashboards
@property (weak) IBOutlet NSWindow *prefsWindow;

- (IBAction)newHalfWindow:(id)sender;

@property (assign) BOOL writableMode;

/// What is the full set?
@property NSArray<Link *> *allLinks;
/// What is derived from the selected tags?
@property NSArray<Link *> *activeLinks;
/// What are all the tags
@property NSArray<Tag *> *tags;
/// Have we got stuff?
@property BOOL hasActiveLinks;

/// Which screen is this window currently on?
@property NSString *currentScreenDisplayName;

- (void)screensDidUpdate;
@end
