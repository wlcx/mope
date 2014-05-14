#import "MopidyConnector.h"
#import "SRWebSocket.h"

@interface MopidyConnector () <SRWebSocketDelegate>

@end

@implementation MopidyConnector {
    SRWebSocket *_webSocket;
}

- (id)initWithURL:(NSURL *)socketURL {
    if(self = [super init]) {
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

- (void)connect {
    NSLog(@"Opening socket....");
    _webSocket.delegate = self;
    [_webSocket open];
}

- (void)disconnect {
    NSLog(@"Closing socket....");
    [_webSocket close];
    NSLog(@"Closed");
    _webSocket.delegate = nil;
    self.connected = false;
    self.currentArtist = @"";
    self.currentTrack = @"";
    [self.mcdelegate disconnected:self];
}

- (void)invokeRPCMethod:(NSString *)method
                success:(void (^)(NSDictionary *))success
                  error:(void (^)(NSDictionary *))error {
    [self invokeRPCMethod:method withParameters:@[] success:success error:error];
}

- (void)invokeRPCMethod:(NSString *)method
         withParameters:(id)parameters
                success:(void (^)(NSDictionary *response))success
                  error:(void (^)(NSDictionary *response))error {
    if(!parameters) {
        parameters = @[];
    }
    NSAssert([parameters isKindOfClass:[NSDictionary class]] || [parameters isKindOfClass:[NSArray class]], @"Expected parameters as NSArray or NSDictionary");
    
    NSInteger requestId = self.requestID++; // get the next request id then increment it for next time
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    payload[@"jsonrpc"] = @"2.0";
    payload[@"method"] = method;
    payload[@"params"] = parameters;
    payload[@"id"] = [NSNumber numberWithInteger:requestId];
    [_webSocket send:([NSJSONSerialization dataWithJSONObject:payload options:0 error:nil])];
    [self.pendingInvocations setObject:[NSArray arrayWithObjects: success, error, nil] forKey: [NSNumber numberWithInteger:requestId]];
}

- (void)processRPCResponse:(NSDictionary*)response {
    NSArray *callbacks;
    if((callbacks = [self.pendingInvocations objectForKey:[NSNumber numberWithInteger:[response[@"id"] integerValue]]])) { // Check if we have this response's ID as a pending request
        if([response objectForKey:@"result"]) {
            void (^success)(NSDictionary *response) = [callbacks objectAtIndex:0];
            success(response);
        }
        else if([response objectForKey:@"error"]) {
            void (^error)(NSDictionary *response) = [callbacks objectAtIndex:0];
            error(response);
        }
        [self.pendingInvocations removeObjectForKey:response[@"id"]];
    }
    else { // We don't know anything about this ID. This probably shouldn't happen
        NSLog(@"ID %@ is not one we have as pending", response[@"id"]);
        NSLog(@"Pending: %@", self.pendingInvocations);
    }
}

- (void)togglePlayState {
    if([[self currentPlayState] isEqualToString:@"playing"]) {
        [self invokeRPCMethod:@"core.playback.pause"
                      success:^(NSDictionary *response) {
                      }
                        error:^(NSDictionary *response) {
                        }
         ];
    }
    else if([[self currentPlayState] isEqualToString:@"paused"]) {
        [self invokeRPCMethod:@"core.playback.play"
                      success:^(NSDictionary *response){}
                        error:^(NSDictionary *response){}
         ];
    }
}

- (void)nextTrack {
    [self invokeRPCMethod:@"core.playback.next"
                  success:^(NSDictionary *response){}
                    error:^(NSDictionary *response){}
     ];
}

- (void)prevTrack {
    [self invokeRPCMethod:@"core.playback.previous"
                  success:^(NSDictionary *response){}
                    error:^(NSDictionary *response){}
     ];
}

- (void)changeVolume:(NSInteger)volume {
    self.volume = volume;
    [self invokeRPCMethod:@"core.playback.set_volume"
           withParameters:@{@"volume": [NSNumber numberWithInteger:volume]}
                  success:^(NSDictionary *response){}
                    error:^(NSDictionary *response){}
     ];
}

- (void)updatePlayState {
    [self invokeRPCMethod:@"core.playback.get_state"
                  success:^(NSDictionary *response) {
                      self.currentPlayState = response[@"result"];
                      [self.mcdelegate playStateChanged:self];
                  }
                    error:^(NSDictionary *response){}
     ];
    [self invokeRPCMethod:@"core.playback.get_current_track"
                  success:^(NSDictionary *response){
                      if(response[@"result"] != [NSNull null]) {
                          self.currentTrack = response[@"result"][@"name"];
                          self.currentArtist = response[@"result"][@"artists"][0][@"name"];
                      }
                      else { // Nothing playing
                          self.currentTrack = @"";
                          self.currentArtist = @"";
                      }
                      [self.mcdelegate playStateChanged:self];
                  }
                    error:^(NSDictionary *response){NSLog(@"%@", response);}
     ];
    [self invokeRPCMethod:@"core.playback.get_volume"
                  success:^(NSDictionary *response){
                      self.volume = [response[@"result"] integerValue];
                      [self.mcdelegate playStateChanged:self];
                  }
                    error:^(NSDictionary *response){}
     ];
}

#pragma mark - SRWebSocketDelegate

- (void)webSocket:(SRWebSocket *)webSocket
didReceiveMessage:(id)message {
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if([response objectForKey:@"event"]) { // We received an event from the server
        if([response[@"event"] isEqualToString:@"playback_state_changed"]) {
            self.currentPlayState = response[@"new_state"];
            [self.mcdelegate playStateChanged:self];
        }
        if([response[@"event"] isEqualToString:@"track_playback_started"]) {
            self.currentTrack = response[@"tl_track"][@"track"][@"name"];
            self.currentArtist = response[@"tl_track"][@"track"][@"artists"][0][@"name"];
            [self.mcdelegate playStateChanged:self];
        }
        if([response[@"event"] isEqualToString:@"volume_changed"]) {
            self.volume = [response[@"volume"] integerValue];
            [self.mcdelegate playStateChanged:self];
        }
    }
    else if([response objectForKey:@"jsonrpc"]) { // We received a JSONRPC response
        [self processRPCResponse:response];
    }

}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"Websocket connected!");
    self.connected = true;
    [self.mcdelegate connected:self];
}

- (void)webSocket:(SRWebSocket *)webSocket
 didCloseWithCode:(NSInteger)code
           reason:(NSString *)reason
         wasClean:(BOOL)wasClean {
    NSLog(@"Websocket closed!");
    self.connected = false;
    _webSocket.delegate = nil;
    [self.mcdelegate disconnected:self];
}

- (void)webSocket:(SRWebSocket *)webSocket
 didFailWithError:(NSError *)error {
    NSLog(@"Websocket failed!");
    self.connected = false;
    _webSocket.delegate = nil;
    [self.mcdelegate disconnected:self];
}
@end
