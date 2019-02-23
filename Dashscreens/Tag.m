//
//  Tag.m
//  Dashscreens
//
//  Created by Orta Therox on 2/22/19.
//  Copyright © 2019 Orta Therox. All rights reserved.
//

#import "Tag.h"

@implementation Tag

+ (instancetype)tagWithName:(NSString *)name selected:(BOOL)selected;
{
    Tag *tag =  [[Tag alloc] init];
    tag.name = name;
    tag.selected = selected;
    return tag;
}

@end
