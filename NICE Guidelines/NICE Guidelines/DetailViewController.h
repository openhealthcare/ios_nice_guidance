//
//  DetailViewController.h
//  NICE Guidelines
//
//  Created by Colin Wren on 31/07/2012.
//  Copyright (c) 2012 Open Healthcare UK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Guidelines.h"

@class MasterViewController;

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate, UIPopoverControllerDelegate>{
    IBOutlet UIWebView *web;
    NSURL *url;
    IBOutlet UIToolbar *bottomBar;
}

@property (strong, nonatomic) id detailItem;


-(void)favourite;
-(void)share;
-(void)print;

@end
