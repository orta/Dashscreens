//
//  Link.h
//  Dashscreens
//
//  Created by Orta Therox on 7/19/18.
//  Copyright © 2018 Orta Therox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Link : NSObject

+ (instancetype)linkWithHref:(NSString *)href time:(CGFloat)time tags:(NSString *)tags;

@property (nonatomic, copy) NSString *href;
@property (nonatomic, assign) CGFloat time;
@property (nonatomic, copy) NSArray<NSString *> *tags;

@end
