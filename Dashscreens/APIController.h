//
//  APIController.h
//  Dashscreens
//
//  Created by Orta Therox on 7/19/18.
//  Copyright © 2018 Orta Therox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Link.h"
#import "Tag.h"
#import "PrefsController.h"

@interface APIController : NSObject

// Updates the Prefs controller
- (void)getLinksFromGoogSheets:(void(^)(void))done;

@property (weak) IBOutlet PrefsController *prefs;

@end
