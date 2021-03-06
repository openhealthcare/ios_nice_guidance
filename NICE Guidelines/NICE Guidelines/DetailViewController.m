//
//  DetailViewController.m
//  NICE Guidelines
//
//  Created by Colin Wren on 31/07/2012.
//  Copyright (c) 2012 OpenHealthCare UK. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController

@synthesize detailItem = _detailItem;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize managedObjectContext;

- (void)dealloc
{
    [_detailItem release];
    [_masterPopoverController release];
    [super dealloc];
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    [web loadHTMLString:nil baseURL:nil];
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
        
        NSLog(@"download_date: %@", guideline.download_date);
        
        UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
        CGRect frame;
        UIColor *textColor;
        NSTextAlignment textAlign;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            NSArray *vComp = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
            
            if ([[vComp objectAtIndex:0] intValue] < 7) {
                // iOS-6 code
                textColor = [UIColor whiteColor];
            }
            
            textAlign = NSTextAlignmentCenter;
            self.navigationItem.rightBarButtonItem = nil;
            
                if(orientation == UIDeviceOrientationPortrait){
                    frame = CGRectMake(0, 0, 210, 44);
                }else if(orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight){
                    frame = CGRectMake(0, 0, 400, 44);
                }else{
                    frame = CGRectMake(0, 0, 210, 44);
                }
            
            UILabel *label = [[[UILabel alloc] initWithFrame:frame] autorelease];
            label.numberOfLines = 2;
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont boldSystemFontOfSize:14.0];
            label.textAlignment = textAlign;
            label.lineBreakMode = NSLineBreakByWordWrapping;
            label.lineBreakMode = NSLineBreakByTruncatingTail;
            if ([[vComp objectAtIndex:0] intValue] < 7) {
                // iOS-6 code
                label.textColor = textColor;
                label.shadowColor = [UIColor grayColor];
            }
            
            label.text = guideline.title;
            self.navigationItem.titleView = label;
        
        }else{
            self.navigationItem.title = guideline.title;
        }
        
        if(!guideline.download_date){
            guideline.download_date = [NSDate date];
        
        
            NSError *error = nil;
            if(![self.managedObjectContext save:&error]){
                NSLog(@"failed to save detailItem %@, %@", error, [error userInfo]);
                abort();
            }
           
            url = [[NSURL alloc] initWithString:guideline.url];
            NSURLRequest *request = [[[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60.0f] autorelease];
            [web loadRequest:request];
        }else{
            //Compare them dates 
            
            //grab the download_date
            NSDate *storeDate = guideline.download_date;
            
            //grab todays date
            NSDate *todayDate = [NSDate date];
            NSDate *thirtyDaysLater = [todayDate dateByAddingTimeInterval:60*60*24*30];
            NSLog(@"30 days time: %@", thirtyDaysLater);
            
            
            //if more than 30 days old load from the web
            NSComparisonResult compareDates = [thirtyDaysLater compare:storeDate];
            if(compareDates == NSOrderedDescending){
                NSLog(@"Loading old data");
                //The dates in the future so no need to reload
                url = [[NSURL alloc] initWithString:guideline.url];
                NSURLRequest *request = [[[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60.0f] autorelease];
                [web loadRequest:request];
            }else{
                NSLog(@"loading new data");
                //The dates in the past or is today so need to reload, set the date in guideline and save
                url = [[NSURL alloc] initWithString:guideline.url];
                NSURLRequest *request = [[[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:60.0f] autorelease];
                [web loadRequest:request]; 
                
                
                guideline.download_date = [NSDate date];
                
                
                NSError *error = nil;
                if(![self.managedObjectContext save:&error]){
                    NSLog(@"failed to save detailItem %@, %@", error, [error userInfo]);
                    abort();
                }
                
                
                
            }
            
            
        }

        
        
        name = guideline.title;
        
        
       
        
        
    }else{
        name = @"iPad";
        url = [[NSURL alloc] initWithString:@"http://openhealthcare.org.uk/"];
        NSURLRequest *request = [[[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f] autorelease];
        [web loadRequest:request];
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *path = [documentsDir stringByAppendingPathComponent:@"user_info.plist"];
    
    NSMutableDictionary *plist = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
    NSArray *favourites = [[NSArray alloc] initWithArray:[plist objectForKey:@"favourites"]];
    
    BOOL faved = NO;
    for(NSString *fav in favourites){
        if([name isEqualToString:fav]){
            faved = YES;
        }
    }
    [favourites release];
    [plist release];

       if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
       
        if(faved == YES){
            favourite = [[UIBarButtonItem alloc] initWithTitle:@"Unfavourite" style:UIBarButtonItemStyleDone target:self action:@selector(removeFavourite:)];
        }else{
            favourite = [[UIBarButtonItem alloc] initWithTitle:@"Favourite" style:UIBarButtonItemStyleDone target:self action:@selector(favourite:)];
        }
        
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
       }else{
           if(faved == YES){
               favour.image = [UIImage imageNamed:@"removefav.png"];
           }else{
               favour.image = [UIImage imageNamed:@"addfav.png"];
           }
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
    [web loadHTMLString:nil baseURL:nil];
    [self configureView];
    
    
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
    [web loadHTMLString:nil baseURL:nil];
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
    NSUInteger position = 0;
    NSUInteger favPos = 0;
    for(NSString *fav in favList){
        if([fav isEqualToString:name]){
            favPos = position;
            check = YES;
        }
        position++;
    }
    
    if(check == NO){
        [favList addObject:name];
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        if(check == YES){
            [favList removeObjectAtIndex:favPos];
        }
    }
    //need to save server date
    [plist setObject:favList forKey:@"favourites"];
    if([plist writeToFile:path atomically:YES]){
        NSLog(@"%@", favList);
    }else{
        NSLog(@"fail");
    }
    [plist release];
    [favList release];
    [self configureView];
}

-(void)removeFavourite:(id)sender{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *path = [documentsDir stringByAppendingPathComponent:@"user_info.plist"];
    
    NSMutableDictionary *plist = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
    NSMutableArray *favList = [[NSMutableArray alloc] initWithArray:[plist objectForKey:@"favourites"]];
    
    
    NSUInteger position = 0;
    NSUInteger favPos = 0;
    BOOL check = NO;
    for(NSString *fav in favList){
        if([fav isEqualToString:name]){
            favPos = position;
            check = YES;
        }
        position++;
    }
    
    
    if(check == YES){
        [favList removeObjectAtIndex:favPos];
    }
    
    
    NSArray *favLister = [[NSArray alloc] initWithArray:favList];
    [plist setObject:favLister forKey:@"favourites"];
    
    if([plist writeToFile:path atomically:YES]){
    }else{
        NSLog(@"fail");
    }
    [favList release];
    [favLister release];
    [plist release];
    [self configureView];
    
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
            NSString *bodyToWrite = [NSString stringWithFormat:@"<p>I've just read the NICE Guidelines on <strong> %@ </strong> using Open Health Care UK's NICE Guidelines app for iPhone and iPad. You can read it at <a href=\"%@\">%@</a></p>", name, url, url];
            [mfViewController setMessageBody:bodyToWrite isHTML:YES];
            mfViewController.mailComposeDelegate = self;
            
            [self presentViewController:mfViewController animated:YES completion:nil];
            [mfViewController release];
        }else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Status:" message:@"Your phone is not currently configured to send mail." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
            
            [alert show];
            [alert release];
        }
    }
    if(buttonIndex == 1){
        // Create the view controller
            
            SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            
            SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
                if (result == SLComposeViewControllerResultCancelled) {
                    
                    NSLog(@"Cancelled");
                    
                } else
                    
                {
                    NSLog(@"Done");
                }
                
                [controller dismissViewControllerAnimated:YES completion:Nil];
            };
            controller.completionHandler =myBlock;
            
            //Adding the Text to the facebook post value from iOS
            [controller setInitialText:[NSString stringWithFormat:@"NICE Guideline on %@",name]];
            
            //Adding the URL to the facebook post value from iOS
            
            [controller addURL:url];
            
            
            [self presentViewController:controller animated:YES completion:Nil];

    }
    
}
- (void)mailComposeController:(MFMailComposeViewController*)mailController didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self becomeFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
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
