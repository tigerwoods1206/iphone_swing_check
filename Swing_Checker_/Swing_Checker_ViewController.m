//
//  Swing_Checker_ViewController.m
//  Swing_Checker_
//
//  Created by オオタ イサオ on 13/02/17.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "Swing_Checker_ViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "AVPlayerViewController.h"

@interface Swing_Checker_ViewController() 
-(void)saveUserDefault;
@end

@implementation Swing_Checker_ViewController
@synthesize imagePickercont;
@synthesize Mydelegate;

-(void)saveUserDefault
{
    // save userdefaylt file
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:tblist forKey:@"ARRAY_IMGFILEPATH"];
    if ( ![defaults synchronize] ) {
        NSLog( @"failed ..." );
    }
    
}

- (IBAction)showCameraSheet
{
	// make actionsheet
    
    if (Editing) {
        return;
    }
    
	UIActionSheet* sheet;
	sheet = [[UIActionSheet alloc]
			 initWithTitle:@"Select Source Type" 
			 delegate:self 
			 cancelButtonTitle:@"Cancel" 
			 destructiveButtonTitle:nil
			 otherButtonTitles:@"Photo Library", @"Camera", @"Saved Photos", nil
             ];
	[sheet autorelease];
    
    sheet.tag = 0;
	
	[sheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if(actionSheet.tag ==0){
        // check button index
        if (buttonIndex >= 3) {
            return;
        }
        //define soudetype
        UIImagePickerControllerSourceType   sourceType = 0;
        switch (buttonIndex) {
            case 0: {
                sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                break;
            }
            case 1: {
                sourceType = UIImagePickerControllerSourceTypeCamera;
                break;
            }
            case 2: {
                sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                break;
            }
        }
        
        if (![UIImagePickerController isSourceTypeAvailable:sourceType]) {  
            return;
        }
        
        self.imagePickercont.sourceType = sourceType;
        
        [self presentModalViewController:imagePickercont animated:YES];
    }
}

-(void)imagePickerController:(UIImagePickerController*)imagePicker
didFinishPickingMediaWithInfo:(NSDictionary*)info
{
    NSLog(@"imagePickerController");
    NSLog(@"info %@", [info description]);
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:@"public.movie"]){
        
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        
        NSLog(@"found a video");
        
        NSData *webData = [NSData dataWithContentsOfURL:videoURL];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                             NSDocumentDirectory,
                                                             NSUserDomainMask, 
                                                             YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* movieFilePath = [NSString stringWithFormat:@"%@/mov_%d.mov", documentsDirectory, tblist.count];
        
        if ([webData writeToFile:movieFilePath atomically:YES]) {
            NSLog(@"OK");
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:tblist.count inSection:0];
            NSArray *indexPaths = [NSArray arrayWithObjects:indexPath,nil];
            [tblist addObject:movieFilePath];
            
            [self saveUserDefault];
            
            [myTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
            // delegate widh AVPlayer controller
            [Mydelegate loadAsset_delegate:self loadasset:videoURL saveimage:movieFilePath];
            
        } else {
            NSLog(@"Error");
        }
        
    }    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController*)picker
{
    [self dismissModalViewControllerAnimated:YES];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSInteger row = [indexPath row];
        [tblist removeObjectAtIndex: row];
        [self saveUserDefault];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]  withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(IBAction) editon:(id) sender {
	if (Editing == 0) {
		[myTableView setEditing:YES animated:YES];
        cameraB.enabled = FALSE;
        Editing = 1;
	}
	else {
		[myTableView setEditing:NO animated:YES];
        cameraB.enabled = TRUE;
        Editing = 0;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {  
    return 100;  
}  

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    NSString *CellIdentifier = [[NSString alloc] initWithFormat:@"cell_1"];	
    UITableViewCell *cell = [myTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
    
    NSString *video_path = [tblist objectAtIndex:indexPath.row];
    NSString *image_path = [NSString stringWithFormat:@"%@.png", video_path];
    //cell.textLabel.text = video_path;
	
    if( [[NSFileManager defaultManager] fileExistsAtPath: image_path] )
    {
        UIImageView *imageView;
        imageView = cell.imageView;
        [imageView setImage:
         [UIImage imageWithContentsOfFile: image_path]];
        cell.imageView.transform = CGAffineTransformMakeRotation(M_PI * (90) / 180.0f);
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	//meiboAppDelegate *appDelegate = (meiboAppDelegate *)[[UIApplication sharedApplication] delegate];
	return [tblist count];
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	if(fromIndexPath.section == toIndexPath.section) {
		int toindex = toIndexPath.row;
		int fromindex = fromIndexPath.row;
		id obj = [tblist objectAtIndex:fromindex];
		[obj retain];
		[tblist removeObjectAtIndex:fromindex];
		[tblist insertObject:obj atIndex:toindex];
        [self saveUserDefault];
		[obj release];
		
    }
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	// Return NO if you do not want the item to be re-orderable.
	return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	
    [myTableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *video_path = [tblist objectAtIndex:indexPath.row];
    NSURL *video_url =  [NSURL fileURLWithPath:video_path];
    [Mydelegate loadAsset_delegate:self loadasset:video_url saveimage:video_path];
    [self presentModalViewController:avplayerViewCont animated:YES];
    
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
    tblist = [[NSMutableArray alloc] init];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    //load tblist object
    NSArray *array= [defaults arrayForKey:@"ARRAY_IMGFILEPATH"];
    for ( NSString* object in array ) {
        [tblist addObject:object];
        //   NSLog( object );
    }
    
	self.imagePickercont = [[UIImagePickerController alloc] init];
    self.imagePickercont.allowsEditing = YES;
    self.imagePickercont.delegate = self;
    self.imagePickercont.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePickercont.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeMovie];
    // need <MobileCoreServices/UTCoreTypes.h>
    
    Editing = 0;
	
	UIBarButtonItem *editButton = 
	[[UIBarButtonItem alloc] initWithTitle:@"Edit" 
									 style:UIBarButtonItemStyleDone target:self 
									action:@selector(editon:)];
	UINavigationItem* item = [myNavigate.items objectAtIndex:0];
	item.rightBarButtonItem = editButton;
	[editButton release];
    
    avplayerViewCont = [[AVPlayerViewController alloc] initWithNibName:@"AVPlayerViewController" bundle:[NSBundle mainBundle]];
    self.Mydelegate = avplayerViewCont;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	NSIndexPath* selection = [myTableView indexPathForSelectedRow];
	
	if (selection){
		[myTableView deselectRowAtIndexPath:selection animated:YES];
	}
	
	[myTableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	//	The scrollbars won't flash unless the tableview is long enough.
	[myTableView flashScrollIndicators];
}

- (void)dealloc
{
    [myTableView release];
    [myNavigate release];
    [tblist release];
    [avplayerViewCont release];
    [imagePickercont release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidUnload
{
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
