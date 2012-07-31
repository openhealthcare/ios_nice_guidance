//
//  MasterViewController.h
//  NICE Guidelines
//
//  Created by Colin Wren on 31/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Guidelines.h"

@class DetailViewController;

@interface MasterViewController : UITableViewController{
    NSArray *menuItems;
}

@property (strong, nonatomic) DetailViewController *detailViewController;
@property (strong, nonatomic)id detailObject;

-(NSArray *)loadMenu;


@end
