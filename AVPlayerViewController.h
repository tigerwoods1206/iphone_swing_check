//
//  AVPlayerViewController.h
//  viewbaesd_tableview_savefile
//
//  Created by オオタ イサオ on 13/01/06.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerView.h"
#import "Swing_Checker_ViewController.h"

@class PlayerView;
@interface AVPlayerViewController : UIViewController <Swing_Checker_ViewController_Delegate>
{
   	IBOutlet UISlider *mScrubber;
    IBOutlet UIToolbar *mToolbar;
    IBOutlet UIBarButtonItem *mPlayButton;
    IBOutlet UIBarButtonItem *mStopButton; 
}

@property (nonatomic, retain) AVPlayer *player; 
@property (retain) AVPlayerItem *playerItem; 
@property (nonatomic, assign) id playTimeObserver; //! 再生位置の更新タイマー通知ハンドラ
@property (nonatomic, retain) IBOutlet PlayerView *playerView;
@property (nonatomic, retain) IBOutlet UISlider *mScrubber;
@property (nonatomic, retain) IBOutlet UIToolbar *mToolbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *mPlayButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *mStopButton;




- (IBAction)play:sender;
- (void)syncUI;
- (void)setupSeekBar;

@end

