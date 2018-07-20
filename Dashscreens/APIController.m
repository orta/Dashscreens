//
//  APIController.m
//  Dashscreens
//
//  Created by Orta Therox on 7/19/18.
//  Copyright © 2018 Orta Therox. All rights reserved.
//

#import "APIController.h"
#import "Extensions.h"

@implementation APIController

- (void)awakeFromNib
{
    [self getLinksFromTeamNav];
}

- (void)getLinksFromTeamNav
{
    NSString *query = @"{ links { href time tags } }";
    NSString *safeQuery =  [query stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    NSURL *URL = [NSURL URLWithString:[@"https://team.artsy.net/api?query=" stringByAppendingString:safeQuery]];
//    NSURL *URL = [NSURL URLWithString:[@"http:/localhost:3000/api?query=" stringByAppendingString:safeQuery]];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    NSString *secret = [[NSProcessInfo processInfo] environment][@"TEAM_NAV_SECRET"];
    if(!secret) {
        @throw @"You need to set TEAM_NAV_SECRET in your Scheme env";
        // cmd + shift + ,
        // then edit environment
    }

//    [request setValue:@"" forHTTPHeaderField:@"secret"];
    [request setValue:secret forHTTPHeaderField:@"secret"];

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
                      self.links = [results[@"data"][@"links"] map:^id(id obj) {
                          BOOL canGetTime = (obj[@"time"] && obj[@"time"] != [NSNull null]);
                          CGFloat time = canGetTime ? [obj[@"time"] doubleValue] : 5;
                          return [Link linkWithHref:obj[@"href"] time:time tags:obj[@"tags"]];
                      }];

                      self.hasLinks = YES;
                  }
              }
          }
      }];

    [task resume];
}


@end
