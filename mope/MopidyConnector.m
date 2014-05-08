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
        self.connected = false;
        self.currentArtist = @"";
        self.currentTrack = @"";
        self.requestID = 1;
        self.pendingInvocations = [NSMutableDictionary dictionary];
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

- (void)disconnect
{
    NSLog(@"Closing socket....");
    [_webSocket close];
    NSLog(@"Closed");
    _webSocket.delegate = nil;
    self.connected = false;
    [self.mcdelegate disconnected:self];
}

- (void)invokeRPCMethod:(NSString *)method
                success:(void (^)(NSDictionary *response))success
                  error:(void (^)(NSDictionary *response))error;
{
    NSInteger requestId = self.requestID++; // get the next request id then increment it for next time
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    payload[@"jsonrpc"] = @"2.0";
    payload[@"method"] = method;
    payload[@"id"] = [NSNumber numberWithInteger:requestId];
    [_webSocket send:([NSJSONSerialization dataWithJSONObject:payload options:0 error:nil])];
    [self.pendingInvocations setObject:[NSArray arrayWithObjects: success, error, nil] forKey: [NSNumber numberWithInteger:requestId]];
}

- (void)processRPCResponse:(NSDictionary*)response
{
    NSArray *callbacks;
    if((callbacks = [self.pendingInvocations objectForKey:[NSNumber numberWithInteger:[response[@"id"] integerValue]]])) // Check if we have this response's ID as a pending request
    {
        if([response objectForKey:@"result"])
        {
            void (^success)(NSDictionary *response) = [callbacks objectAtIndex:0];
            success(response);
        }
        else if([response objectForKey:@"error"])
        {
            void (^error)(NSDictionary *response) = [callbacks objectAtIndex:0];
            error(response);
        }
        [self.pendingInvocations removeObjectForKey:response[@"id"]];
    }
    else // We don't know anything about this ID. This probably shouldn't happen
    {
        NSLog(@"ID %@ is not one we have as pending", response[@"id"]);
        NSLog(@"Pending: %@", self.pendingInvocations);
    }
}

- (void)togglePlayState
{
    if([[self currentPlayState] isEqualToString:@"playing"])
    {
        [self invokeRPCMethod:@"core.playback.pause"
                      success:^(NSDictionary *response){
                      }
                        error:^(NSDictionary *response){
                        }
         ];
    }
    else if([[self currentPlayState] isEqualToString:@"paused"])
    {
        [self invokeRPCMethod:@"core.playback.play" success:^(NSDictionary *response){} error:^(NSDictionary *response){}];
    }
}

- (void)updatePlayState
{
    [self invokeRPCMethod:@"core.playback.get_state"
                  success:^(NSDictionary *response){self.currentPlayState = response[@"result"]; [self.mcdelegate playStateChanged:self];}
                    error:^(NSDictionary *response){}
     ];
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
        if([response[@"event"] isEqualToString:@"track_playback_started"])
        {
            self.currentArtist = response[@"tl_track"][@"track"][@"name"];
            self.currentArtist = response[@"tl_track"][@"track"][@"artists"][0][@"name"];
            [self.mcdelegate playStateChanged:self];
        }
    }
    else if([response objectForKey:@"jsonrpc"]) // We received a JSONRPC response
    {
        [self processRPCResponse:response];
    }
    //NSLog(message);

}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    NSLog(@"Websocket connected!");
    self.connected = true;
    [self.mcdelegate connected:self];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"Websocket closed!");
    self.connected = false;
    _webSocket.delegate = nil;
    [self.mcdelegate disconnected:self];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    NSLog(@"Websocket failed!");
    self.connected = false;
    _webSocket.delegate = nil;
    [self.mcdelegate disconnected:self];
}
@end
