#import "AppDelegate.h"
#import "MopidyConnector.h"
#import "AXStatusItemPopup.h"
#import "MopeMainViewController.h"

@interface AppDelegate () <NSNetServiceBrowserDelegate> {
    AXStatusItemPopup *_statusItemPopup;
}
@end

@implementation AppDelegate {}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    MopeMainViewController *mopeMainViewController = [[MopeMainViewController alloc] initWithNibName:@"MopeMainView" bundle:nil];
    _statusItemPopup = [[AXStatusItemPopup alloc] initWithViewController:mopeMainViewController image:[NSImage imageNamed:@"statusbar_icon_inactive"]];
    mopeMainViewController.statusItemPopup = _statusItemPopup;
    //self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    //[self.statusItem setHighlightMode:YES];
    //[self.statusItem setImage:self.statusImageInactive];
    //self.browser = [[NSNetServiceBrowser alloc] init];
    //[self.browser setDelegate:self];
}


- (IBAction)quit:(id)sender {
    [[NSApplication sharedApplication] terminate:nil];
}


@end