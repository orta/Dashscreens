//
//  Extensions.h
//  Dashscreens
//
//  Created by Orta Therox on 7/19/18.
//  Copyright © 2018 Orta Therox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface  NSArray (Exts)
- (NSArray *) map:(id(^)(id obj))block;
- (NSArray *) filter:(BOOL (^)(id obj))block;
@end
