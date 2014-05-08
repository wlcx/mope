//
//  AppDelegate.h
//  mope
//
//  Created by Samuel Willcocks on 24/04/2014.
//  Copyright (c) 2014 wlcx. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (assign) IBOutlet NSWindow *window;

@property (weak) IBOutlet NSMenuItem *tracklabel;
@property (weak) IBOutlet NSMenuItem *artistlabel;
@property (weak) IBOutlet NSMenuItem *menuItemPlayPause;
@property (weak) IBOutlet NSMenuItem *menuItemConnectToggle;
@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong, nonatomic) IBOutlet NSMenu *statusMenu;

@property NSImage *statusImageInactive;
@property NSImage *statusImageActive;
@property NSAlert *alert;
@property NSTextField *urlInput;

- (IBAction)playPause:(id)sender;
- (IBAction)quit:(id)sender;
- (IBAction)toggleConnect:(id)sender;

@end
