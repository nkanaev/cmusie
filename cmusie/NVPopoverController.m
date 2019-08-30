#import "NVPopoverController.h"
#import "NVAppDelegate.h"

@interface NVPopoverController ()
@end

@implementation NVPopoverController

+ (NVPopoverController *)create {
    return [[NVPopoverController alloc] initWithNibName:@"NVPopoverViewController" bundle:NULL];
}

- (void)viewDidAppear {
    [NSApp activateIgnoringOtherApps:YES];
    [self updateUI];
}

- (void)updateUI {
    NSDictionary *status = [(NVAppDelegate*)NSApp.delegate playerStatus];
    self.fieldTitle.stringValue = [(NSDictionary*)status[@"tag"] valueForKey:@"title"];
    self.fieldArtist.stringValue = [(NSDictionary*)status[@"tag"] valueForKey:@"artist"];
}

- (void)setupTrackin {
}

- (void)mouseEntered:(NSEvent *)event {
    
}

- (void)mouseExited:(NSEvent *)event {
}


@end
