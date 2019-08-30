#import "NVAppDelegate.h"
#import "NVPopoverController.h"

#define MEDIAKEY_DOWN(event) (((([event data1] & 0x0000FFFF) & 0xFF00) >> 8) == 0xA)
#define MEDIAKEY_CODE(event) (([event data1] & 0xFFFF0000) >> 16)

@interface NVAppDelegate () {
    CFMachPortRef _mk_tap_port;
}

@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong, nonatomic) NSPopover *popover;

- (void)popoverToggle:(NSEvent*)sender;

- (void)mediaKeysTopPriority;
- (void)mediaKeysRestart;
- (bool)mediaKeysHandle:(NSEvent*)sender;

@end

@implementation NVAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSMenu *menu = [[NSMenu alloc] init];
    [menu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@""];
    
    NSStatusItem *item = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    item.button.image = [NSImage imageNamed:@"AppIcon"];
    item.button.imageScaling = NSImageScaleProportionallyUpOrDown;
    
    self.statusItem = item;
    [self.statusItem.button setAction:@selector(popoverToggle:)];
    
    self.popover = [[NSPopover alloc] init];
    self.popover.animates = NO;
    self.popover.behavior = NSPopoverBehaviorSemitransient;
    self.popover.contentViewController = [NVPopoverController create];
    
    if (AXIsProcessTrusted())
        [self mediaKeysStart];
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    if (self.popover.shown) {
        [self.popover performClose:nil];
    }
}

- (BOOL)playerToggle {
    return [self runCommand:@[@"cmus-remote", @"--pause"]].terminationStatus == 0;
}

- (BOOL)playerPrev {
    return [self runCommand:@[@"cmus-remote", @"--prev"]].terminationStatus == 0;
}

- (BOOL)playerNext {
    return [self runCommand:@[@"cmus-remote", @"--next"]].terminationStatus == 0;
}

- (NSDictionary*)playerStatus {
    NSMutableDictionary *tag = [[NSMutableDictionary alloc] init];
    BOOL running = NO, playing = NO;
    
    NSTask *task = [self runCommand:@[@"cmus-remote", @"-Q"]];
    if (task.terminationStatus == 0) {
        running = YES;
        NSPipe *stdout = (NSPipe*)task.standardOutput;
        NSData *outputData = [[stdout fileHandleForReading] readDataToEndOfFile];
        NSString *outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];

        NSArray *lines = [outputString componentsSeparatedByString:@"\n"];
        for (NSString *line in lines) {
            NSArray *chunks = [line componentsSeparatedByString:@" "];
            if ([chunks[0] isEqualToString:@"status"]) {
                playing = [chunks[1] isEqualToString:@"playing"];
            } else if ([chunks[0] isEqualToString:@"tag"]) {
                NSArray *valueChunks = [chunks subarrayWithRange:NSMakeRange(2, chunks.count - 2)];
                NSString *value = [valueChunks componentsJoinedByString:@" "];
                [tag setValue:value forKey:chunks[1]];
            }
        }
    }
    return @{
        @"tag": tag,
        @"running": [NSNumber numberWithBool:running],
        @"playing": [NSNumber numberWithBool:playing]
    };
}

- (MediaKeyStatus)mediaKeysStatus {
    if (!AXIsProcessTrusted())
        return MediaKeyStatusUnaccessible;
    return _mk_tap_port ? MediaKeyStatusEnabled : MediaKeyStatusDisabled;
}

- (void)mediaKeysUnlock {
    NSDictionary *options = @{(__bridge id)kAXTrustedCheckOptionPrompt: @YES};
    BOOL accessibilityEnabled = AXIsProcessTrustedWithOptions((CFDictionaryRef)options);
    if (accessibilityEnabled) {
        [self mediaKeysStart];
    }
}

- (void)popoverToggle:(NSEvent*)sender {
    if (self.popover.shown) {
        [self.popover performClose:sender];
    } else {
        [self.popover showRelativeToRect:self.statusItem.button.bounds
                                  ofView:self.statusItem.button
                           preferredEdge:NSRectEdgeMinY];
    }
}

- (void)applicationWillBecomeActive:(NSNotification *)notification {
    [self mediaKeysTopPriority];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [[NSStatusBar systemStatusBar] removeStatusItem:self.statusItem];
}

- (void)mediaKeysTopPriority {
    if (self->_mk_tap_port == nil)
        return;
    
    CGEventTapInformation *taps = calloc(1, sizeof(CGEventTapInformation));
    uint32_t numTaps = 0;
    CGError err = CGGetEventTapList(1, taps, &numTaps);
    
    if (err == kCGErrorSuccess && numTaps > 0) {
        pid_t processID = [NSProcessInfo processInfo].processIdentifier;
        if (taps[0].tappingProcess != processID) {
            [self mediaKeysStop];
            [self mediaKeysStart];
        }
    }
    free(taps);
}

- (void)mediaKeysStart {
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_mk_tap_port = CGEventTapCreate(
            kCGSessionEventTap,
            kCGHeadInsertEventTap,
            kCGEventTapOptionDefault,
            CGEventMaskBit(NX_SYSDEFINED),
            tap_event_callback,
            (__bridge void*)self);
        
        if (self->_mk_tap_port) {
            NSMachPort *port = (__bridge NSMachPort *)self->_mk_tap_port;
            [[NSRunLoop mainRunLoop] addPort:port forMode:NSRunLoopCommonModes];
        }
    });
}

- (void)mediaKeysRestart {
    if (self->_mk_tap_port) CGEventTapEnable(self->_mk_tap_port, true);
}

- (void)mediaKeysStop {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMachPort *port = (__bridge NSMachPort*)self->_mk_tap_port;
        if (port) {
            CGEventTapEnable(self->_mk_tap_port, false);
            [[NSRunLoop mainRunLoop] removePort:port forMode:NSRunLoopCommonModes];
            CFRelease(self->_mk_tap_port);
            self->_mk_tap_port = nil;
        }
    });
}

- (bool)mediaKeysHandle:(NSEvent*)event {
    switch (MEDIAKEY_CODE(event)) {
        case NX_KEYTYPE_PLAY:
            return [self playerToggle];
        case NX_KEYTYPE_REWIND:
            return [self playerPrev];
        case NX_KEYTYPE_FAST:
            return [self playerNext];
    }
    return false;
}

- (NSTask*)runCommand:(NSArray*)command {
    NSTask *task = [[NSTask alloc] init];
    
    NSMutableDictionary *env = [[NSMutableDictionary alloc] initWithDictionary:[[NSProcessInfo processInfo] environment]];
    NSString *path = [NSString stringWithFormat:@"%@:/usr/local/bin", [env objectForKey:@"PATH"]];
    [env setObject:path forKey:@"PATH"];
    [task setEnvironment:env];
    [task setExecutableURL:[NSURL fileURLWithPath:@"/usr/bin/env"]];
    [task setArguments:command];
    [task setStandardOutput:[NSPipe pipe]];
    [task launchAndReturnError:nil];
    [task waitUntilExit];
    return task;
}

static CGEventRef tap_event_callback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *ctx) {
    NVAppDelegate *delegate = (__bridge NVAppDelegate*)ctx;
    
    if (type == kCGEventTapDisabledByTimeout) {
        // The Mach Port receiving the taps became unresponsive for some
        // reason, restart listening on it.
        [delegate mediaKeysRestart];
        return event;
    }
    
    if (type == kCGEventTapDisabledByUserInput)
        return event;
    
    NSEvent *nse = [NSEvent eventWithCGEvent:event];
    
    if ([nse type] != NSEventTypeSystemDefined || [nse subtype] != 8)
        // This is not a media key
        return event;
    
    if (MEDIAKEY_DOWN(nse) && [delegate mediaKeysHandle:nse])
        return nil;
    return event;
}

@end
