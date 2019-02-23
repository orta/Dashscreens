// https://stackoverflow.com/questions/1236498/how-to-get-the-display-name-with-the-display-id-in-mac-os-x

#import <Cocoa/Cocoa.h>

@interface NSScreen (DisplayInfo)

-(NSString *) displayName;
-(NSNumber *) displayID;

@end
