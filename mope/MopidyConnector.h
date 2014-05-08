//
//  MopidyConnector.h
//  mope
//
//  Created by Sam W on 27/04/2014.
//  Copyright (c) 2014 wlcx. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MopidyConnector;

@protocol MopidyConnectorDelegate

- (void)playStateChanged:(MopidyConnector *)sender;
- (void)connected:(MopidyConnector *)sender;
- (void)disconnected:(MopidyConnector *)sender;

@end

@interface MopidyConnector : NSObject

@property (nonatomic, assign) id <MopidyConnectorDelegate> mcdelegate;

@property NSURL *socketURL;
@property BOOL connected;

@property NSString *currentPlayState;
@property NSString *currentTrack;
@property NSString *currentArtist;

@property NSMutableDictionary *pendingInvocations;
@property NSInteger requestID;

- (id)initWithURL:(NSURL *)socketURL;

- (void)connect;
- (void)disconnect;

- (void)togglePlayState;
- (void)updatePlayState;

- (void)invokeRPCMethod:(NSString *)method
                success:(void (^)(NSDictionary *response))success
                  error:(void (^)(NSDictionary *response))error;
-(void)processRPCResponse:(NSDictionary *)response;

@end
