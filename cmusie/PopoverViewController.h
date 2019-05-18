#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface PopoverViewController : NSViewController

+ (PopoverViewController*)create;


@property (weak) IBOutlet NSTextField *fieldTitle;
@property (weak) IBOutlet NSTextField *fieldArtist;

@end

NS_ASSUME_NONNULL_END
