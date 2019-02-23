// https://stackoverflow.com/questions/1236498/how-to-get-the-display-name-with-the-display-id-in-mac-os-x

#import "NSObject+NSScreen_DisplayInfo.h"
#import <IOKit/graphics/IOGraphicsLib.h>

@implementation NSScreen (DisplayInfo)

-(NSString *) displayName
{
    CGDirectDisplayID displayID = [[self displayID] intValue];

    NSString *screenName = nil;

    NSDictionary *deviceInfo = (NSDictionary *)CFBridgingRelease(IODisplayCreateInfoDictionary(CGDisplayIOServicePort(displayID), kIODisplayOnlyPreferredName));
    NSDictionary *localizedNames = [deviceInfo objectForKey:[NSString stringWithUTF8String:kDisplayProductName]];

    if ([localizedNames count] > 0) {
        screenName = [localizedNames objectForKey:[[localizedNames allKeys] objectAtIndex:0]];
    }

    return screenName;
}

-(NSNumber *) displayID
{
    return [[self deviceDescription] valueForKey:@"NSScreenNumber"];
}
@end
