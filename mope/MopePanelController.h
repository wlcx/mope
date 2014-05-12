#import <Cocoa/Cocoa.h>
#import "AXStatusItemPopup.h"

@interface MopePanelController : NSViewController

@property (weak, nonatomic) AXStatusItemPopup *statusItemPopup;

@property (weak) IBOutlet NSButton *buttonPlayPause;
@property (weak) IBOutlet NSButton *buttonItemNext;
@property (weak) IBOutlet NSButton *buttonItemPrev;
@property (weak) IBOutlet NSSlider *sliderVolume;
@property (weak) IBOutlet NSButton *buttonConnectToggle;
@property (weak) IBOutlet NSTextField *artistLabel;
@property (weak) IBOutlet NSTextField *trackLabel;

- (IBAction)playPause:(id)sender;
- (IBAction)next:(id)sender;
- (IBAction)prev:(id)sender;
- (IBAction)connectToggle:(id)sender;
- (IBAction)volumeChanged:(id)sender;

- (void)enablePlayControls:(BOOL)hidden;
- (void)hideNowPlaying:(BOOL)hidden;

@end
