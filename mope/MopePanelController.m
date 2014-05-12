#import "MopePanelController.h"
#import "MopidyConnector.h"

@interface MopePanelController () <MopidyConnectorDelegate>

@end

@implementation MopePanelController {MopidyConnector *mopidyConnector;}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (IBAction)playPause:(id)sender {
    [mopidyConnector togglePlayState];
}

- (IBAction)next:(id)sender {
    [mopidyConnector nextTrack];
}

- (IBAction)prev:(id)sender {
    [mopidyConnector prevTrack];
}

- (IBAction)connectToggle:(id)sender {
    if(mopidyConnector.connected)
    {
        [mopidyConnector disconnect];
    }
    else
    {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Enter server URL" defaultButton:@"Connect" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@""];
        NSTextField *urlInput = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 220, 24)];
        [urlInput setStringValue:@"ws://10.10.0.1:6680/mopidy/ws/"];
        [alert setAccessoryView:urlInput];
        NSInteger button = [alert runModal];
        if (button == NSAlertDefaultReturn) {
            mopidyConnector = [[MopidyConnector alloc] initWithURL:[NSURL URLWithString:[urlInput stringValue]]];
            mopidyConnector.mcdelegate = self;
            [mopidyConnector connect];
        }
    }
}

- (void)hidePlayControls:(BOOL)hidden
{
    [self.buttonPlayPause setHidden:hidden];
    [self.buttonItemNext setHidden:hidden];
    [self.buttonItemPrev setHidden:hidden];
    
}

- (void)hideNowPlaying:(BOOL)hidden
{
    [self.artistLabel setHidden:hidden];
    [self.trackLabel setHidden:hidden];
}


#pragma mark MopidyConnectorDelegate
- (void)playStateChanged:(MopidyConnector *)sender
{
    if([[mopidyConnector currentPlayState] isEqualToString:@"playing"])
    {
        [[self buttonPlayPause] setImage:[NSImage imageNamed:@"transport_pause"]];
        [self hideNowPlaying:false];
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = @"Now playing:";
        notification.subtitle = [mopidyConnector currentTrack];
        notification.informativeText = [mopidyConnector currentArtist];
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    }
    else if([[mopidyConnector currentPlayState] isEqualToString:@"paused"])
    {
        [[self buttonPlayPause] setImage:[NSImage imageNamed:@"transport_play"]];
        [self hideNowPlaying:false];
    }
    else if([[mopidyConnector currentPlayState] isEqualToString:@"stopped"])
    {
        [[self buttonPlayPause] setImage:[NSImage imageNamed:@"transport_play"]];
        [self hideNowPlaying:true];
    }
    [self.trackLabel setStringValue:mopidyConnector.currentTrack];
    [self.artistLabel setStringValue:mopidyConnector.currentArtist];
}

- (void)connected:(MopidyConnector *)sender
{
    NSLog(@"Connected");
    [self.statusItemPopup setImage:[NSImage imageNamed:@"statusbar_icon_active"]];
    [self.statusItemPopup setAlternateImage:[NSImage imageNamed:@"statusbar_icon_active"]];
    [self.buttonConnectToggle setTitle:@"Disconnect"];
    [mopidyConnector updatePlayState];
    [self hidePlayControls:false];
}

- (void)disconnected:(MopidyConnector *)sender
{
    [self.statusItemPopup setImage:[NSImage imageNamed:@"statusbar_icon_inactive"]];
    [self.statusItemPopup setAlternateImage:[NSImage imageNamed:@"statusbar_icon_inactive"]];
    [self.buttonConnectToggle setTitle:@"Connect"];
    [self hidePlayControls:true];
    [self hideNowPlaying:true];
}

@end
