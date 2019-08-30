#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NVPopoverController : NSViewController

+ (NVPopoverController*)create;


@property (weak) IBOutlet NSTextField *fieldTitle;
@property (weak) IBOutlet NSTextField *fieldArtist;

@end

NS_ASSUME_NONNULL_END
