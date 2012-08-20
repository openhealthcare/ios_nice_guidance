//
//  DetailViewController.m
//  NICE Guidelines
//
//  Created by Colin Wren on 31/07/2012.
//  Copyright (c) 2012 Open Healthcare UK. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController

@synthesize detailItem = _detailItem;
@synthesize masterPopoverController = _masterPopoverController;

- (void)dealloc
{
    [_detailItem release];
    [_masterPopoverController release];
    [super dealloc];
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        [_detailItem release]; 
        _detailItem = [newDetailItem retain]; 

        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.
    if (self.detailItem) {
        //self.detailDescriptionLabel.text = [self.detailItem description];
        Guideline *guideline = (Guideline *)self.detailItem;
        
        self.navigationItem.title = guideline.title;
        name = guideline.title;
        
        
        url = [[NSURL alloc] initWithString:guideline.url];
        NSURLRequest *request = [[[NSURLRequest alloc] initWithURL:url] autorelease];
        [web loadRequest:request];
    }else{
        name = @"iPad";
        url = [[NSURL alloc] initWithString:@"http://openhealthcare.org.uk/"];
        NSURLRequest *request = [[[NSURLRequest alloc] initWithURL:url] autorelease];
        [web loadRequest:request];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
        favourite = [[UIBarButtonItem alloc] initWithTitle:@"Favourite" style:UIBarButtonItemStyleDone target:self action:@selector(favourite:)];
    

        share = [[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonItemStyleDone  target:self action:@selector(share:)];
    
    
        if([UIPrintInteractionController isPrintingAvailable]){
            print = [[UIBarButtonItem alloc] initWithTitle:@"Print" style:UIBarButtonItemStyleDone  target:self action:@selector(print:)];
            NSArray *buttonArray = [[NSArray alloc] initWithObjects:favourite,share,print, nil];
            [self.navigationItem setRightBarButtonItems:buttonArray];
            [buttonArray release];
        }else{
            NSArray *buttonArray = [[NSArray alloc] initWithObjects:favourite,share, nil];
            [self.navigationItem setRightBarButtonItems:buttonArray];
            [buttonArray release];
        }
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //self.title = NSLocalizedString(@"View PDF", @"View PDF");
    }
    return self;
}
							
#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Guidelines", @"Guidelines");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

-(IBAction)favourite:(id)sender{
    //Need to now save the name of the PDF to the user_info.plist file
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *path = [documentsDir stringByAppendingPathComponent:@"user_info.plist"];
    
    NSMutableDictionary *plist = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
    NSMutableArray *favList = [[NSMutableArray alloc] initWithArray:[plist objectForKey:@"favourites"]];
    
    BOOL check = NO;
    for(NSString *fav in favList){
        if([fav isEqualToString:name]){
            check = YES;
        }
    }
    
    if(check == NO){
        [favList addObject:name];
    }
    //need to save server date
    [plist setObject:favList forKey:@"favourites"];
    if([plist writeToFile:path atomically:YES]){
        NSLog(@"%@", favList);
    }else{
        NSLog(@"fail");
    }

}

-(IBAction)share:(id)sender{
    //do Share thing
    UIActionSheet *sharer = [[UIActionSheet alloc] initWithTitle:@"Share guideline" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email", @"Twitter", nil];
    [sharer showInView:self.view];
    [sharer release];
}

//To handle button press on actionsheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 0){
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *mfViewController = [[MFMailComposeViewController alloc] init];
            NSString *subjectToWrite = [NSString stringWithFormat:@"NICE Guideline -  %@", name];
            [mfViewController setSubject:subjectToWrite];
            NSString *bodyToWrite = [NSString stringWithFormat:@"<p>I've just read the NICE Guidelines on <strong> %@ </strong> using Open Health Care UK's NICE Guidelines app for iPhone and iPad. You can read can read it at <a href=\"%@\">%@</a></p>", name, url, url];
            [mfViewController setMessageBody:bodyToWrite isHTML:YES];
            mfViewController.mailComposeDelegate = self;
            
            [self presentModalViewController:mfViewController animated:YES];
            [mfViewController release];
        }else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Status:" message:@"Your phone is not currently configured to send mail." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
            
            [alert show];
            [alert release];
        }
    }
    if(buttonIndex == 1){
        // Create the view controller
        TWTweetComposeViewController *twitter = [[TWTweetComposeViewController alloc] init];
        
        // Optional: set an image, url and initial text
        //[twitter addImage:[UIImage imageNamed:@"iOSDevTips.png"]];
        [twitter addURL:url];
        [twitter setInitialText:[NSString stringWithFormat:@"NICE Guideline on %@",name]];
        
        // Show the controller
        [self presentModalViewController:twitter animated:YES];
        
        // Called when the tweet dialog has been closed
        twitter.completionHandler = ^(TWTweetComposeViewControllerResult result) 
        {
            NSString *title = @"Tweet Status";
            NSString *msg; 
            
            if (result == TWTweetComposeViewControllerResultCancelled)
                msg = @"Tweet compostion was canceled.";
            else if (result == TWTweetComposeViewControllerResultDone)
                msg = @"Tweet composition completed.";
            
            // Show alert to see how things went...
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [alertView show];
            
            // Dismiss the controller
            [self dismissModalViewControllerAnimated:YES];
        };
    }
}
- (void)mailComposeController:(MFMailComposeViewController*)mailController didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self becomeFirstResponder];
    [self dismissModalViewControllerAnimated:YES];
}

-(IBAction)print:(id)sender{
    //do print thing
    UIPrintInteractionController *controller = [UIPrintInteractionController sharedPrintController];
    if(!controller){
        NSLog(@"Couldn't get shared UIPrintInteractionController!");
        return;
    }
    void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) =
    ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
        if(!completed && error){
            NSLog(@"FAILED! due to error in domain %@ with error code %u",
                  error.domain, error.code);
        }
    };
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    printInfo.outputType = UIPrintInfoOutputGeneral;
    printInfo.jobName = [NSString stringWithFormat:@"%@",url];
    printInfo.duplex = UIPrintInfoDuplexLongEdge;
    controller.printInfo = printInfo;
    controller.showsPageRange = YES;
    
    UIViewPrintFormatter *viewFormatter = [web viewPrintFormatter];
    viewFormatter.startPage = 0;
    controller.printFormatter = viewFormatter;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [controller presentFromBarButtonItem:print animated:YES completionHandler:completionHandler];
    }else
        [controller presentAnimated:YES completionHandler:completionHandler];
}
@end