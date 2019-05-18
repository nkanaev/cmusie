#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

- (bool)playerToggle;
- (bool)playerPrev;
- (bool)playerNext;
- (NSDictionary*)playerStatus;

@end
