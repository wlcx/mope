#import "AppDelegate.h"
#import "MopidyConnector.h"
#import "AXStatusItemPopup.h"
#import "MopeMainViewController.h"

@interface AppDelegate () <NSNetServiceBrowserDelegate> {
    AXStatusItemPopup *_statusItemPopup;
}
@end

@implementation AppDelegate {}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    MopeMainViewController *mopeMainViewController = [[MopeMainViewController alloc] initWithNibName:@"MopeMainView" bundle:nil];
    _statusItemPopup = [[AXStatusItemPopup alloc] initWithViewController:mopeMainViewController image:[NSImage imageNamed:@"statusbar_icon_inactive"]];
    mopeMainViewController.statusItemPopup = _statusItemPopup;
}


- (IBAction)quit:(id)sender {
    [[NSApplication sharedApplication] terminate:nil];
}


@end