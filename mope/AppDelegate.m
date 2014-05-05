//
//  AppDelegate.m
//  mope
//
//  Created by Samuel Willcocks on 24/04/2014.
//  Copyright (c) 2014 wlcx. All rights reserved.
//

#import "AppDelegate.h"
#import "MopidyConnector.h"

@interface AppDelegate () <MopidyConnectorDelegate> {}

@end

@implementation AppDelegate {MopidyConnector *mopidyConnector;}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.statusImageInactive = [NSImage imageNamed:@"statusbar_icon_inactive"];
    self.statusImageActive = [NSImage imageNamed:@"statusbar_icon_active.png"];
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setMenu:self.statusMenu];
    [self.statusItem setHighlightMode:YES];
    [self.statusItem setImage:self.statusImageInactive];
//    NSNetServiceBrowser *serviceBrowser;
//    serviceBrowser = [[NSNetServiceBrowser alloc] init];
    mopidyConnector = [[MopidyConnector alloc] initWithURL:[NSURL URLWithString:@"ws://127.0.0.1:6680/mopidy/ws/"]];
    mopidyConnector.mcdelegate = self;
    [mopidyConnector connect];
}


- (IBAction)quit:(id)sender {
    [[NSApplication sharedApplication] terminate:nil];
}

- (IBAction)playPause:(id)sender;
{
    [mopidyConnector togglePlayState];
}

#pragma mark - MopidyConnectorDelegate
- (void)playStateChanged:(MopidyConnector *)wat
{
    if([[mopidyConnector currentPlayState] isEqualToString:@"playing"])
    {
        [[self menuItemPlayPause] setTitle:@"Pause"];
    }
    else if([[mopidyConnector currentPlayState] isEqualToString:@"paused"])
    {
        [[self menuItemPlayPause] setTitle:@"Play"];
    }
    else if([[mopidyConnector currentPlayState] isEqualToString:@"stopped"])
    {
        [[self menuItemPlayPause] setTitle:@"Play"];
    }
}

- (void)connected:(MopidyConnector *)mopidyConnector
{
    NSLog(@"Connected");
    [self.statusItem setImage:self.statusImageActive];
    [mopidyConnector updatePlayState];
}

- (void)disconnected:(MopidyConnector *)mopidyConnector
{
    [self.statusItem setImage:self.statusImageInactive];
}
@end