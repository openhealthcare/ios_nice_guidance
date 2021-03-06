//
//  DetailViewController.h
//  NICE Guidelines
//
//  Created by Colin Wren on 31/07/2012.
//  Copyright (c) 2012 OpenHealthCare UK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>
#import "Guideline.h"

@class MasterViewController;

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate, UIPopoverControllerDelegate, UIPrintInteractionControllerDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate>{
    IBOutlet UIWebView *web;
    NSURL *url;
    IBOutlet UIToolbar *bottomBar;
    UIBarButtonItem *print;
    UIBarButtonItem *share;
    UIBarButtonItem *favourite;
    NSString *name;
    IBOutlet UIBarButtonItem *favour;
}

@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

-(IBAction)favourite:(id)sender;
-(void)removeFavourite:(id)sender;
-(IBAction)share:(id)sender;
-(IBAction)print:(id)sender;

@end
