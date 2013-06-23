//
//  AVPlayerViewController.m
//  viewbaesd_tableview_savefile
//
//  Created by オオタ イサオ on 13/01/06.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "AVPlayerViewController.h"

NSString* const kStatusKey = @"status";
static void* AVPlayerViewControllerStatusObservationContext = &AVPlayerViewControllerStatusObservationContext;

@interface AVPlayerViewController ()
@property (nonatomic, assign) BOOL isPlaying; // isPlaying == TRUE, movie is Playing
- (void)seekBarValueChanged:(UISlider *)slider;
- (void)showPlayButton;
- (void)showStopButton;

@end

@implementation AVPlayerViewController
@synthesize player, playerView, playerItem,playTimeObserver,isPlaying;
@synthesize mToolbar, mScrubber, mPlayButton, mStopButton;

//key value watching context string
static const NSString *ItemStatusContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(IBAction)play:(id)sender {
    if (self.isPlaying) {
        self.isPlaying = NO;
        [self.player pause];
        [self showPlayButton];
    }
    else {
        self.isPlaying = YES;
        [player play];
        [self showStopButton];
    }
}

-(IBAction) close:(id)sender
{
    self.isPlaying = NO;
    [self.player pause];
    [self.player removeTimeObserver:self.playTimeObserver];  

    [self dismissModalViewControllerAnimated:YES];
}

-(void)showStopButton
{
    NSMutableArray *toolbarItems = [NSMutableArray arrayWithArray:[mToolbar items]];
    [toolbarItems replaceObjectAtIndex:0 withObject:mStopButton];
    mToolbar.items = toolbarItems;
}

/* Show the play button in the movie player controller. */
-(void)showPlayButton
{
    NSMutableArray *toolbarItems = [NSMutableArray arrayWithArray:[mToolbar items]];
    [toolbarItems replaceObjectAtIndex:0 withObject:mPlayButton];
    mToolbar.items = toolbarItems;
}


-(void) loadAsset_delegate:(Swing_Checker_ViewController *) Swing_Checker_ViewController loadasset:(NSURL *)url saveimage:(NSString *)video_path
{
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    NSString *tracksKey = @"tracks";
    
    [asset loadValuesAsynchronouslyForKeys:[NSArray arrayWithObject:tracksKey] completionHandler:
     ^{
         dispatch_async(dispatch_get_main_queue(), 
                        ^{
                            
                            NSError *error =  nil;
                            AVKeyValueStatus status = [asset statusOfValueForKey:tracksKey error:&error];
                            if (status == AVKeyValueStatusLoaded) {
                                self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
                                [playerItem addObserver:self forKeyPath:@"status" options:0 context:&ItemStatusContext];
                                [[NSNotificationCenter defaultCenter] 
                                 addObserver:self 
                                 selector:@selector(playerItemDidReachEnd:) 
                                 name:AVPlayerItemDidPlayToEndTimeNotification 
                                 object:playerItem];
                                
                                self.player = [AVPlayer playerWithPlayerItem:playerItem];
                            
                                [playerView setPlayer:player];
                            }
                            else {
                                NSLog(@"The asset's tracks were not loaded:\n%@", [error
                                                                                   localizedDescription]);
                            }
                        });
     }];

    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    Float64 durationSeconds = CMTimeGetSeconds([asset duration]); 
    CMTime midpoint = CMTimeMakeWithSeconds(durationSeconds/2.0, 600); 
    NSError *error = nil; 
    CMTime actualTime;
    CGImageRef halfWayImage = [imageGenerator copyCGImageAtTime:midpoint actualTime:&actualTime error:&error];
    UIImage *newImage = [[UIImage alloc] initWithCGImage:halfWayImage];
    
  //  NSError* err;
    NSString* photoFilePath = [NSString stringWithFormat:@"%@.png", video_path];
     NSLog(@"%@",photoFilePath);
    NSData *pngData = [[NSData alloc] initWithData:UIImagePNGRepresentation( newImage )];
    if ([pngData writeToFile:photoFilePath atomically:YES]) {
        NSLog(@"png save OK");
    } else {
        NSLog(@"%@",video_path);
        NSLog(@"%@",photoFilePath);
        NSLog(@"png save Error");
    }
 
    
    CGImageRelease(halfWayImage);
    [newImage release];
    [pngData release];
    [imageGenerator release];

}

-(void)playerItemDidReachEnd:(NSNotification *)notification {
    [player seekToTime:kCMTimeZero];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == &ItemStatusContext) {
        
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [self syncUI];
                           [self setupSeekBar];
                       });
        return;
    }
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    return;
}

- (void)syncUI 
{ 
    if ((player.currentItem != nil) &&
        ([player.currentItem status] == AVPlayerItemStatusReadyToPlay)) { 
        self.mScrubber.enabled = YES;
    } else {
        self.mScrubber.enabled = NO;
    }
}



- (void)seekBarValueChanged:(UISlider *)slider
{
   // [self.player seekToTime:CMTimeMakeWithSeconds( slider.value, 600 ) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
     [self.player seekToTime:CMTimeMakeWithSeconds( slider.value, 600 ) toleranceBefore:CMTimeMakeWithSeconds( 0.1f, 600 ) toleranceAfter:CMTimeMakeWithSeconds( 0.1f, 600 )];
}

// sync SeekBar with playtime。
- (void)syncSeekBar
{
    const double duration = CMTimeGetSeconds( [self.player.currentItem duration] );
    const double time = CMTimeGetSeconds([self.player currentTime]);
    const float value = ( self.mScrubber.maximumValue - self.mScrubber.minimumValue ) * time / duration + self.mScrubber.minimumValue;
    
    [self.mScrubber setValue:value];
    
  //  self.currentTimeLabel.text = [self timeToString:self.seekBar.value];
}

- (void)setupSeekBar
{
    if(self.mScrubber ==nil) return;
    self.mScrubber.minimumValue = 0;
    self.mScrubber.maximumValue = CMTimeGetSeconds( self.playerItem.duration );
    self.mScrubber.value = 0;
    [self.mScrubber addTarget:self action:@selector(seekBarValueChanged:) forControlEvents:UIControlEventValueChanged];
    //mScrubber
    
    const double interval = ( self.mScrubber.maximumValue ) / self.mScrubber.bounds.size.width;
    const CMTime time = CMTimeMakeWithSeconds( interval, NSEC_PER_SEC );
    self.playTimeObserver = [self.player addPeriodicTimeObserverForInterval:time
                                                                          queue:NULL
                                                                usingBlock:^( CMTime time ) { [self syncSeekBar]; }];
    
   // self.durationLabel.text = [self timeToString:self.seekBar.maximumValue];
}


- (NSString* )timeToString:(float)value
{
    const NSInteger time = value;
    return [NSString stringWithFormat:@"%d:%02d", ( int )( time / 60 ), ( int )( time % 60 )];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[player pause];
	
	[super viewWillDisappear:animated];
}


#pragma mark - View lifecycle

- (void)dealloc
{
    [player release];
    [playerView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self syncUI];
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *scrubberItem = [[UIBarButtonItem alloc] initWithCustomView:mScrubber];
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    mToolbar.items = [NSArray arrayWithObjects:mPlayButton, flexItem, scrubberItem,  nil];
    [scrubberItem release];
    [flexItem release];
}

- (void)viewDidUnload
{
    [self.player pause];
    [self.player removeTimeObserver:self.playTimeObserver];  
    self.mToolbar = nil;
    self.mPlayButton = nil;
    self.mStopButton = nil;
    self.mScrubber = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
