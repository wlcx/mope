#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (assign) IBOutlet NSWindow *window;

@property (weak) IBOutlet NSMenuItem *tracklabel;
@property (weak) IBOutlet NSMenuItem *artistlabel;
@property (weak) IBOutlet NSMenuItem *menuItemPlayPause;
@property (weak) IBOutlet NSMenuItem *menuItemNext;
@property (weak) IBOutlet NSMenuItem *menuItemPrev;
@property (weak) IBOutlet NSMenuItem *menuItemConnectToggle;
@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong, nonatomic) IBOutlet NSMenu *statusMenu;

@property NSImage *statusImageInactive;
@property NSImage *statusImageActive;
@property NSAlert *alert;
@property NSTextField *urlInput;

- (IBAction)playPause:(id)sender;
- (IBAction)nextTrack:(id)sender;
- (IBAction)prevTrack:(id)sender;
- (IBAction)quit:(id)sender;
- (IBAction)toggleConnect:(id)sender;

@end
