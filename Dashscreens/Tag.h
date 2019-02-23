//
//  Tag.h
//  Dashscreens
//
//  Created by Orta Therox on 2/22/19.
//  Copyright © 2019 Orta Therox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Tag : NSObject

+ (instancetype)tagWithName:(NSString *)href selected:(BOOL)selected;

@property (nonatomic, assign) BOOL selected;
@property (nonatomic, copy) NSString *name;

@end

NS_ASSUME_NONNULL_END
