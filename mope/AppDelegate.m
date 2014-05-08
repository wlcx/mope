#import "AppDelegate.h"
#import "MopidyConnector.h"

@interface AppDelegate () <MopidyConnectorDelegate> {}

@end

@implementation AppDelegate {MopidyConnector *mopidyConnector;}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.statusImageInactive = [NSImage imageNamed:@"statusbar_icon_inactive"];
    self.statusImageActive = [NSImage imageNamed:@"statusbar_icon_active"];
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setMenu:self.statusMenu];
    [self.statusItem setHighlightMode:YES];
    [self.statusItem setImage:self.statusImageInactive];
//    NSNetServiceBrowser *serviceBrowser;
//    serviceBrowser = [[NSNetServiceBrowser alloc] init];
    self.alert = [NSAlert alertWithMessageText:@"Enter server URL" defaultButton:@"Connect" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@""];
    self.urlInput = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 220, 24)];
    [self.urlInput setStringValue:@"ws://127.0.0.1:6680/mopidy/ws/"];
    [self.alert setAccessoryView:self.urlInput];
}


- (IBAction)quit:(id)sender {
    [[NSApplication sharedApplication] terminate:nil];
}

- (IBAction)playPause:(id)sender;
{
    [mopidyConnector togglePlayState];
}

- (IBAction)toggleConnect:(id)sender;
{
    if(mopidyConnector.connected)
    {
        [mopidyConnector disconnect];
    }
    else
    {
        NSInteger button = [self.alert runModal];
        if (button == NSAlertDefaultReturn) {
            mopidyConnector = [[MopidyConnector alloc] initWithURL:[NSURL URLWithString:[self.urlInput stringValue]]];
            mopidyConnector.mcdelegate = self;
            [mopidyConnector connect];
        }
    }
}

#pragma mark - MopidyConnectorDelegate
- (void)playStateChanged:(MopidyConnector *)sender
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

- (void)connected:(MopidyConnector *)sender
{
    NSLog(@"Connected");
    [self.statusItem setImage:self.statusImageActive];
    [self.menuItemConnectToggle setTitle:@"Disconnect"];
    [mopidyConnector updatePlayState];
}

- (void)disconnected:(MopidyConnector *)sender
{
    [self.statusItem setImage:self.statusImageInactive];
    [self.menuItemConnectToggle setTitle:@"Connect"];
}
@end