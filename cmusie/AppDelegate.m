//
//  AppDelegate.m
//  cmusie
//
//  Created by nkanaev on 13/05/2019.
//  Copyright © 2019 nkanaev. All rights reserved.
//

#import "AppDelegate.h"

#define MEDIAKEY_DOWN(event) (((([event data1] & 0x0000FFFF) & 0xFF00) >> 8) == 0xA)
#define MEDIAKEY_CODE(event) (([event data1] & 0xFFFF0000) >> 16)

@interface AppDelegate () {
    CFMachPortRef _mk_tap_port;
}

@property (strong, nonatomic) NSStatusItem *statusItem;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSMenu *menu = [[NSMenu alloc] init];
    [menu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@""];
    
    NSStatusItem *item = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    item.button.image = [NSImage imageNamed:@"play-circle@2x.png"];
    
    self.statusItem = item;
    self.statusItem.menu = menu;
    
    [self mediaKeysStart];
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
            [self runCommand:@[@"cmus-remote", @"--pause"]];
            return true;
        case NX_KEYTYPE_REWIND:
            [self runCommand:@[@"cmus-remote", @"--prev"]];
            return true;
        case NX_KEYTYPE_FAST:
            [self runCommand:@[@"cmus-remote", @"--next"]];
            return true;
    }
    return false;
}

- (void)runCommand:(NSArray*)command {
    NSTask *task = [[NSTask alloc] init];
    
    NSMutableDictionary *env = [[NSMutableDictionary alloc] initWithDictionary:[[NSProcessInfo processInfo] environment]];
    NSString *path = [NSString stringWithFormat:@"%@:/usr/local/bin", [env objectForKey:@"PATH"]];
    [env setObject:path forKey:@"PATH"];
    [task setEnvironment:env];
    [task setExecutableURL:[NSURL fileURLWithPath:@"/usr/bin/env"]];
    [task setArguments:command];
    [task launchAndReturnError:nil];
    [task waitUntilExit];
}

static CGEventRef tap_event_callback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *ctx) {
    AppDelegate *delegate = (__bridge AppDelegate*)ctx;
    
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
