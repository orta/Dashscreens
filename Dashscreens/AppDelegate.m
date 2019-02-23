//
//  AppDelegate.m
//  Dashscreens
//
//  Created by Orta Therox on 6/25/18.
//  Copyright © 2018 Orta Therox. All rights reserved.
//

#import "AppDelegate.h"
#import "PrefsController.h"

@interface AppDelegate ()
@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet PrefsController *prefs;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)applicationDidChangeScreenParameters:(NSNotification *)notification
{
        
}

@end
