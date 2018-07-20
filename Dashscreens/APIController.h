//
//  APIController.h
//  Dashscreens
//
//  Created by Orta Therox on 7/19/18.
//  Copyright © 2018 Orta Therox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Link.h"

@interface APIController : NSObject

- (void)getLinksFromTeamNav;

@property NSArray<Link *> *links;
@property BOOL hasLinks;

@end
