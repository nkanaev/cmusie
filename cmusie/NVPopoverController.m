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
    
    self.fieldTitle.stringValue = [(NSDictionary*)status[@"tag"] valueForKey:@"title"] ?: @"...";
    self.fieldArtist.stringValue = [(NSDictionary*)status[@"tag"] valueForKey:@"artist"] ?: @"...";
    
    switch ([[self delegate] mediaKeysStatus]) {
        case MediaKeyStatusUnaccessible:
            [self.btnLock setImage:[NSImage imageNamed:@"unlock"]];
            break;
        case MediaKeyStatusEnabled:
            [self.btnLock setImage:[NSImage imageNamed:@"unlink"]];
            break;
        case MediaKeyStatusDisabled:
            [self.btnLock setImage:[NSImage imageNamed:@"link"]];
            break;
    }
    
    BOOL running = [status[@"running"] boolValue];
    self.btnPrev.enabled = running;
    self.btnNext.enabled = running;
    self.btnPlay.enabled = running;
    
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

- (IBAction)handleMediaKeysUnlock:(id)sender {
    switch ([[self delegate] mediaKeysStatus]) {
        case MediaKeyStatusUnaccessible:
            [[self delegate] mediaKeysUnlock];
            break;
        case MediaKeyStatusEnabled:
            [[self delegate] mediaKeysStop];
            [self updateUI];
            break;
        case MediaKeyStatusDisabled:
            [[self delegate] mediaKeysStart];
            [self updateUI];
            break;
    }

}

@end
