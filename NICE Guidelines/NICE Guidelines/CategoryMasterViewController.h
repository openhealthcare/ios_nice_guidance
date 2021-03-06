//
//  CategoryMasterViewController.h
//  NICE Guidelines
//
//  Created by Colin Wren on 20/08/2012.
//  Copyright (c) 2012 OpenHealthCare UK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailViewController.h"

@interface CategoryMasterViewController : UITableViewController{
    IBOutlet UITableView *table;
    NSFetchedResultsController *frc;
}
@property (strong, nonatomic) DetailViewController *detailViewController;
@property (strong, nonatomic) DetailViewController *actuallyworksDetail;
@property (strong, nonatomic)id detailObject;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
- (void)refresh;
@end
