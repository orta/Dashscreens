// https://stackoverflow.com/questions/10195977/how-to-change-the-nsscreen-a-nswindow-appears-on

#import "ScreenConstrainedWindow.h"
#import "ScreenViewController.h"
#import "NSObject+NSScreen_DisplayInfo.h"

@implementation ScreenConstrainedWindow

- (NSRect)constrainFrameRect:(NSRect)frameRect toScreen:(NSScreen *)screen
{
    ScreenViewController *screenVC = (id)self.contentViewController;
    for (NSScreen *screen in [NSScreen screens]) {
        if (screenVC.preferredScreenDeviceID.doubleValue == screen.displayID.doubleValue) {
            return [super constrainFrameRect:frameRect toScreen:screen];
        }
    }

    // Fallback to the one that was passed in
    return [super constrainFrameRect:frameRect toScreen:screen];
}

@end
