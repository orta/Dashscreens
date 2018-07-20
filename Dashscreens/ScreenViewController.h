//
//  ScreenViewController.h
//  Dashscreens
//
//  Created by Orta Therox on 7/19/18.
//  Copyright © 2018 Orta Therox. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Link.h"

@interface ScreenViewController : NSViewController
@property NSArray<Link *> *links;
@property BOOL debug;
@end
