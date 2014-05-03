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

- (void)playStateChanged:(MopidyConnector *)mopidyConnector;
- (void)connected:(MopidyConnector *)mopidyConnector;
- (void)disconnected:(MopidyConnector *)mopidyConnector;

@end

@interface MopidyConnector : NSObject

@property (nonatomic, assign) id <MopidyConnectorDelegate> mcdelegate;
@property NSURL *socketURL;

@property NSString *currentPlayState;

- (id)initWithURL:(NSURL *)socketURL;
- (void)connect;
- (void)togglePlayState;
- (void)updatePlayState;
- (NSMutableDictionary *)makeRPCMethod:(NSString *)method;
@end
