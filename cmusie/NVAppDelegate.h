#import <Cocoa/Cocoa.h>

typedef enum {
    MediaKeyStatusUnaccessible,
    MediaKeyStatusEnabled,
    MediaKeyStatusDisabled,
} MediaKeyStatus;

@interface NVAppDelegate : NSObject <NSApplicationDelegate>

- (BOOL)playerToggle;
- (BOOL)playerPrev;
- (BOOL)playerNext;

- (MediaKeyStatus)mediaKeysStatus;
- (void)mediaKeysUnlock;
- (void)mediaKeysStart;
- (void)mediaKeysStop;

- (NSDictionary*)playerStatus;

@end
