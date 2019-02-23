//
//  APIController.m
//  Dashscreens
//
//  Created by Orta Therox on 7/19/18.
//  Copyright © 2018 Orta Therox. All rights reserved.
//

#import "APIController.h"
#import "Extensions.h"
#import <Keys/DashscreensKeys.h>
#import "Tag.h"

@implementation APIController

- (void)awakeFromNib
{
    [self getLinksFromTeamNav];
}

- (void)getLinksFromTeamNav
{
    NSString *query = @"{ links { href time tags type name } }";
    NSString *safeQuery =  [query stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    NSURL *URL = [NSURL URLWithString:[@"https://team.artsy.net/api?query=" stringByAppendingString:safeQuery]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];

    DashscreensKeys *keys = [[DashscreensKeys alloc] init];
    [request setValue:keys.teamNavSecret forHTTPHeaderField:@"secret"];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
          if (error != nil) {
              NSLog(@"ERR: %@ ",error);
          } else {
              NSHTTPURLResponse *httpResponse = (id)response;
              NSLog(@"HTTP: %@", @(httpResponse.statusCode));
              NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
              if (error != nil) {
                  NSLog(@"PARSE ERR: %@ ", error);
                  NSLog(@"RESP: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);

              } else {
                  if (results[@"errors"]) {
                      NSLog(@"Query ERR: %@", results[@"errors"]);

                  } else if(results[@"data"][@"links"]) {
                      self.prefs.allLinks = [results[@"data"][@"links"] map:^id(id obj) {
                          BOOL canGetTime = (obj[@"time"] && obj[@"time"] != [NSNull null]);
                          CGFloat time = canGetTime ? [obj[@"time"] doubleValue] : 5;
                          return [Link linkWithHref:obj[@"href"] time:time tags:obj[@"tags"] type:obj[@"type"] name:obj[@"name"]];
                      }];

                      self.prefs.hasLinks = YES;
                      NSMutableSet *tagSet = [NSMutableSet set];
                      [self.prefs.allLinks enumerateObjectsUsingBlock:^(Link * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                          [tagSet addObjectsFromArray:obj.tags];
                      }];

                      NSArray<NSString *> *tagNames = [[tagSet allObjects] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];

                      self.prefs.tags = [tagNames map:^id(NSString *tag) {
                          BOOL isSelected = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"selected-%@", tag]];
                          return [Tag tagWithName:tag selected:isSelected];
                      }];
                  }
              }
          }
      }];


    [task resume];
}


@end
