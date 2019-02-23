//
//  ScreenViewController.h
//  Dashscreens
//
//  Created by Orta Therox on 7/19/18.
//  Copyright © 2018 Orta Therox. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Link.h"
#import "ScreenSize.h"
#import "Tag.h"

@interface ScreenViewController : NSViewController

// The tags so that it can handle being updated
@property NSArray<Tag *> *tags;

// The links to loop through
@property NSArray<Link *> *links;

/// What fill?
@property ScreenSize screenSize;

/// Aim to be on this screen when we can
@property (copy) NSNumber *preferredScreenDeviceID;

@end
