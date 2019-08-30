//
//  NVControlButton.m
//  cmusie
//
//  Created by nkanaev on 30/08/2019.
//  Copyright © 2019 nkanaev. All rights reserved.
//

#import "NVControlButton.h"

@implementation NVControlButton


- (NSTrackingArea*)trackingArea {
    NSTrackingAreaOptions options = NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways;
    return [[NSTrackingArea alloc] initWithRect:[self bounds] options:options owner:self userInfo:nil];
}

- (void)awakeFromNib
{
    [self setWantsLayer:YES];
    self.layer.masksToBounds = TRUE;
    self.layer.cornerRadius = 2;
}

- (void)updateTrackingAreas {
    [self addTrackingArea:[self trackingArea]];
}

- (void)mouseEntered:(NSEvent *)theEvent{
    if ([self isEnabled]) {
        [[self cell] setBackgroundColor:[[NSColor blackColor] colorWithAlphaComponent:0.1]];
    }
}

- (void)mouseExited:(NSEvent *)theEvent{
    if ([self isEnabled]) {
        [[self cell] setBackgroundColor:NULL];
    }
}

@end
