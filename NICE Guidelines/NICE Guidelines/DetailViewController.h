//
//  DetailViewController.h
//  NICE Guidelines
//
//  Created by Colin Wren on 31/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>{
    IBOutlet UIWebView *web;
    NSURL *url;
    IBOutlet UIToolbar *bottomBar;
}

@property (strong, nonatomic) id detailItem;

-(void)favourite;
-(void)share;
-(void)print;

@end
