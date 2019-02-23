//
//  Link.m
//  Dashscreens
//
//  Created by Orta Therox on 7/19/18.
//  Copyright © 2018 Orta Therox. All rights reserved.
//

#import "Link.h"

@implementation Link

+ (instancetype)linkWithHref:(NSString *)href time:(CGFloat)time tags:(NSString *)tags type:(NSString *)type name:(NSString *)name;
{
    Link *link =  [[self alloc] init];
    link.href = href;
    link.time = time;
    link.name = name;
    link.type = type;
    link.tags = [tags componentsSeparatedByString:@" "];
    return link;
}

@end
