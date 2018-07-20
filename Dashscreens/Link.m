//
//  Link.m
//  Dashscreens
//
//  Created by Orta Therox on 7/19/18.
//  Copyright © 2018 Orta Therox. All rights reserved.
//

#import "Link.h"

@implementation Link

+ (instancetype)linkWithHref: (NSString *)href time:(CGFloat)time tags:(NSString *)tags
{
    Link *link =  [[self alloc] init];
    link.href = href;
    link.time = time;
    link.tags = [tags componentsSeparatedByString:@" "];
    return link;
}

@end
