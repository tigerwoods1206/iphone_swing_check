//
//  Swing_Checker_ViewController.h
//  Swing_Checker_
//
//  Created by オオタ イサオ on 13/02/17.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVPlayerViewController;
@protocol Swing_Checker_ViewController_Delegate;

@interface Swing_Checker_ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UINavigationBarDelegate,
UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    IBOutlet UITableView *myTableView;
    IBOutlet UINavigationBar *myNavigate;
    IBOutlet UIBarButtonItem *cameraB;
    AVPlayerViewController *avplayerViewCont;
    UIImagePickerController *imagePickercont;
    NSMutableArray       *tblist;
    NSInteger            Editing;
    id <Swing_Checker_ViewController_Delegate> Mydelegate;
}

@property (nonatomic, retain) UIImagePickerController *imagePickercont;
@property (nonatomic, assign) id <Swing_Checker_ViewController_Delegate> Mydelegate;

- (IBAction) editon:(id) sender;
- (IBAction) showCameraSheet;

@end

@protocol Swing_Checker_ViewController_Delegate <NSObject>

- (void) loadAsset_delegate:(Swing_Checker_ViewController *)Swing_CheckerView_Controller loadasset:(NSURL *)url saveimage:(NSString *)video_path;

@end
