#import <Cocoa/Cocoa.h>

@interface NVAppDelegate : NSObject <NSApplicationDelegate>

- (bool)playerToggle;
- (bool)playerPrev;
- (bool)playerNext;
- (NSDictionary*)playerStatus;

@end
