//
//  Extensions.m
//  Dashscreens
//
//  Created by Orta Therox on 7/19/18.
//  Copyright © 2018 Orta Therox. All rights reserved.
//

#import "Extensions.h"

@implementation NSArray (Exts)

- (NSArray *) map:(id(^)(id obj))block
{
    NSMutableArray *a = @[].mutableCopy;
    for (id o in self) {
        id on = block(o);
        if (!on) {
            NSLog(@"NSArray::map() - object returned by block is nil!");
            abort();
        }
        [a addObject: on];
    }
    return [NSArray arrayWithArray: a];
}

- (NSArray *) filter:(BOOL (^)(id obj))block
{
    NSMutableArray *a = @[].mutableCopy;
    for (id o in self) {
        if (block(o)) {
            [a addObject: o];
        }

    }
    return [NSArray arrayWithArray: a];
}
- (void) apply:(void(^)(id obj))block
{
    for (id o in self) {
        block(o);
    }
}

@end
