#import "PopoverViewController.h"
#import "AppDelegate.h"

@interface PopoverViewController ()
@end

@implementation PopoverViewController

+ (PopoverViewController *)create {
    return [[PopoverViewController alloc] initWithNibName:@"PopoverViewController" bundle:NULL];
}

- (void)viewDidAppear {
    [NSApp activateIgnoringOtherApps:YES];
    [self updateUI];
    
}

- (void)updateUI {
    NSDictionary *status = [(AppDelegate*)NSApp.delegate playerStatus];
    self.fieldTitle.stringValue = [(NSDictionary*)status[@"tag"] valueForKey:@"title"];
    self.fieldArtist.stringValue = [(NSDictionary*)status[@"tag"] valueForKey:@"artist"];
}

@end
