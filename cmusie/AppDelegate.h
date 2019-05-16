//
//  AppDelegate.h
//  cmusie
//
//  Created by nkanaev on 13/05/2019.
//  Copyright © 2019 nkanaev. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

- (void)mediaKeysTopPriority;
- (void)mediaKeysStart;
- (void)mediaKeysRestart;
- (void)mediaKeysStop;
- (bool)mediaKeysHandle:(NSEvent*)event;

@end
