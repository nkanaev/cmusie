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

- (NVAppDelegate*)delegate {
    return (NVAppDelegate*)NSApp.delegate;
}

- (void)updateUI {
    NSDictionary *status = [[self delegate] playerStatus];
    self.fieldTitle.stringValue = [(NSDictionary*)status[@"tag"] valueForKey:@"title"];
    self.fieldArtist.stringValue = [(NSDictionary*)status[@"tag"] valueForKey:@"artist"];
    
    NSString* image = [status[@"playing"] boolValue] ? @"pause" : @"play";
    [self.btnPlay setImage:[NSImage imageNamed:image]];
}

- (IBAction)handlePrev:(id)sender {
    [[self delegate] playerPrev];
    [self updateUI];
}

- (IBAction)handleNext:(id)sender {
    [[self delegate] playerNext];
    [self updateUI];
}

- (IBAction)handlePlayToggle:(id)sender {
    [[self delegate] playerToggle];
    [self updateUI];
}

- (void)setPlayingButton:(BOOL)playing {
}

@end
