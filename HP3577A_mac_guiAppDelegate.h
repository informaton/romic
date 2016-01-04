//
//  HP3577A_mac_guiAppDelegate.h
//  HP3577A_mac_gui
//
//  Created by Hyatt Moore
//  Copyright 2016 Informaton. All rights reserved.
//


#import <Cocoa/Cocoa.h>

@interface HP3577A_mac_guiAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
