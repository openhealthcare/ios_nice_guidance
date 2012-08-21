//
//  FavouriteMasterViewController.h
//  NICE Guidelines
//
//  Created by Colin Wren on 20/08/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailViewController.h"

@interface FavouriteMasterViewController : UITableViewController<NSFetchedResultsControllerDelegate>{
    NSFetchedResultsController *frc;
    NSMutableArray *guidelines;
    NSFetchRequest *fetchRequest;
}
@property (strong, nonatomic) DetailViewController *detailViewController;
@property (strong, nonatomic) DetailViewController *actuallyworksDetail;
@property (strong, nonatomic)id detailObject;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, assign) IBOutlet UITableView *table;
-(NSMutableArray *)data;
-(void)refresh;
@end
