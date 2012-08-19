//
//  MasterViewController.h
//  NICE Guidelines
//
//  Created by Colin Wren on 31/07/2012.
//  Copyright (c) 2012 Open Healthcare UK. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController<UISearchBarDelegate, UISearchDisplayDelegate,NSFetchedResultsControllerDelegate>{
    //FetchedResultsControllers one with all data, one for only search data
    //NSFetchedResultsController *frc;
   //NSFetchedResultsController *searchfrc;
    
    //The saved state of the search UI if a memory warning removes the view
    NSString *savedSearchTerm;
    BOOL searchWasActive;
}

@property (strong, nonatomic) DetailViewController *detailViewController;
@property (strong, nonatomic) DetailViewController *actuallyworksDetail;
@property (strong, nonatomic)id detailObject;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *searchfrc;
@property (nonatomic, retain) NSFetchedResultsController *frc;
@property (nonatomic, assign) NSString *savedSearchTerm;
@property (nonatomic, assign) BOOL searchWasActive;
@property (nonatomic, retain) UISearchDisplayController *searchController;
-(NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView;
- (void)fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController configureCell:(UITableViewCell *)theCell atIndexPath:(NSIndexPath *)theIndexPath;
@end
