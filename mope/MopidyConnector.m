//
//  MopidyConnector.m
//  mope
//
//  Created by Sam W on 27/04/2014.
//  Copyright (c) 2014 wlcx. All rights reserved.
//

#import "MopidyConnector.h"
#import "SRWebSocket.h"

@interface MopidyConnector () <SRWebSocketDelegate>

@end

@implementation MopidyConnector {
    SRWebSocket *_webSocket;
}

- (id)initWithURL:(NSURL *)socketURL;
{
    if(self = [super init])
    {
        self.socketURL = socketURL;
        _webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[self socketURL]]];
        return self;
    }
    else
        return nil;
}

- (void)connect
{
    NSLog(@"Opening socket....");
    _webSocket.delegate = self;
    [_webSocket open];
}

- (NSMutableDictionary *)makeRPCMethod:(NSString *)method
{
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    payload[@"jsonrpc"] = @"2.0";
    payload[@"method"] = method;
    payload[@"id"] = [NSNumber numberWithInt:1];
    return payload;
}

- (void)togglePlayState
{
    if([[self currentPlayState] isEqualToString:@"playing"])
    {
        [_webSocket send:([NSJSONSerialization dataWithJSONObject:[self makeRPCMethod:@"core.playback.pause"] options:0 error:nil])];
    }
    else if([[self currentPlayState] isEqualToString:@"paused"])
    {
        [_webSocket send:([NSJSONSerialization dataWithJSONObject:[self makeRPCMethod:@"core.playback.play"] options:0 error:nil])];
    }
}

- (void)updatePlayState
{
    [_webSocket send:([NSJSONSerialization dataWithJSONObject:[self makeRPCMethod:@"core.playback.get_state"] options:0 error:nil])];
}

#pragma mark - SRWebSocketDelegate

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message;
{
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if([response objectForKey:@"event"]) // We received an event from the server
    {
        if([response[@"event"] isEqualToString:@"playback_state_changed"])
        {
            self.currentPlayState = response[@"new_state"];
            [self.mcdelegate playStateChanged:self];
        }
    }
    NSLog(message);

}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    NSLog(@"Websocket connected!");
    [self.mcdelegate connected:self];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"Websocket disconnected!");
    _webSocket.delegate = nil;
    [self.mcdelegate disconnected:self];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    NSLog(@"Websocket failed!");
    _webSocket.delegate = nil;
    [self.mcdelegate disconnected:self];
}
@end
