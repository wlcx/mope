//
//  AppDelegate.h
//  mope
//
//  Created by Samuel Willcocks on 24/04/2014.
//  Copyright (c) 2014 wlcx. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (weak) IBOutlet NSMenuItem *tracklabel;
@property (weak) IBOutlet NSMenuItem *artistlabel;

@property (assign) IBOutlet NSWindow *window;
@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong, nonatomic) IBOutlet NSMenu *statusMenu;
- (IBAction)play:(id)sender;
- (IBAction)pause:(id)sender;
@property (weak) IBOutlet NSMenuItem *updatePlayState;
@end
