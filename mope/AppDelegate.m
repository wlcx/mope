//
//  AppDelegate.m
//  mope
//
//  Created by Samuel Willcocks on 24/04/2014.
//  Copyright (c) 2014 wlcx. All rights reserved.
//

#import "AppDelegate.h"
#import "SRWebSocket.h"

@interface AppDelegate () <SRWebSocketDelegate>

@end

@implementation AppDelegate {SRWebSocket *webSocket;}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSImage *statusImageInactive = [NSImage imageNamed:@"icon_inactive.png"];
    NSImage *statusImageActive = [NSImage imageNamed:@"icon_active.png"];
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setMenu:self.statusMenu];
    [self.statusItem setHighlightMode:YES];
    [self.statusItem setImage:statusImageInactive];
    NSNetServiceBrowser *serviceBrowser;
    serviceBrowser = [[NSNetServiceBrowser alloc] init];
    webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"ws://10.10.0.1:6680/mopidy/ws/"]]];
    webSocket.delegate = self;
    NSLog(@"Opening socket....");
    [webSocket open];
    
}

- (IBAction)quit:(id)sender {
    [[NSApplication sharedApplication] terminate:nil];
}

- (IBAction)play:(id)sender;
{
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    payload[@"jsonrpc"] = @"2.0";
    payload[@"method"] = @"core.playback.play";
    payload[@"id"] = [NSNumber numberWithInt:1];
    [webSocket send:([NSJSONSerialization dataWithJSONObject:payload options:0 error:nil])];
}

#pragma mark - SRWebSocketDelegate

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message;
{
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSLog(message);
//    if(response[@"result"])
//    {
//        [self.tracklabel setTitle:response[@"result"][@"name"]];
//        [self.artistlabel setTitle:response[@"result"][@"artists"][0][@"name"]];
//        NSLog(@"Now playing: %@ - %@", response[@"result"][@"name"], response[@"result"][@"artists"][0][@"name"]);
//    }
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    NSLog(@"Websocket opened");
    NSImage *statusImageActive = [NSImage imageNamed:@"icon_active.png"];
    [self.statusItem setImage:statusImageActive];
}
- (IBAction)pause:(id)sender {
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    payload[@"jsonrpc"] = @"2.0";
    payload[@"method"] = @"core.playback.pause";
    payload[@"id"] = [NSNumber numberWithInt:1];
    [webSocket send:([NSJSONSerialization dataWithJSONObject:payload options:0 error:nil])];
}
@end