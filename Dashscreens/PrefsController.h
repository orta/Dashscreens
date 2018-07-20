//
//  PrefsController.h
//  Dashscreens
//
//  Created by Orta Therox on 6/25/18.
//  Copyright © 2018 Orta Therox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface PrefsController : NSObject
@property (weak) IBOutlet NSWindow *prefsWindow;
- (IBAction)newHalfWindow:(id)sender;
@property (assign) BOOL writableMode;

@end
