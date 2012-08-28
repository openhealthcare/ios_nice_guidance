//
//  MasterViewController.m
//  NICE Guidelines
//
//  Created by Colin Wren on 31/07/2012.
//  Copyright (c) 2012 OpenHealthCare UK. All rights reserved.
//

#import "MasterViewController.h"
#import "Guideline.h"
#import "DetailViewController.h"

@implementation MasterViewController

@synthesize detailViewController = _detailViewController;
@synthesize detailObject, actuallyworksDetail, managedObjectContext,frc, searchfrc, searchWasActive, savedSearchTerm, searchController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"A - Z", @"A - Z");
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            self.clearsSelectionOnViewWillAppear = NO;
            self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
        }
    }
    return self;
}
							
- (void)dealloc
{
    [_detailViewController release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    self.savedSearchTerm = [self.searchDisplayController.searchBar text];
    self.searchWasActive = [self.searchDisplayController isActive];
    
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    UISearchBar *searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44.0)] autorelease];
    searchBar.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.tableView.tableHeaderView = searchBar;
    
    self.searchController = [[[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self] autorelease];
    self.searchController.delegate = self;
    self.searchController.searchResultsDataSource = self;
    self.searchController.searchResultsDelegate = self;
    
    if(self.savedSearchTerm){
        [self.searchDisplayController setActive:self.searchWasActive];
        [self.searchDisplayController.searchBar setText:savedSearchTerm];
        
        self.savedSearchTerm = nil;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Guideline" inManagedObjectContext:managedObjectContext];
    
    [fetchRequest setEntity:entity];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES] autorelease]]];
    
   /* NSPredicate *pred = [NSPredicate predicateWithFormat:@"title unique"];
    
    [fetchRequest setPredicate:pred];*/
    
    self.frc = [[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:@"title.stringGroupByFirstInitial" cacheName:nil] autorelease];

        
    self.searchfrc = [[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil] autorelease];

    
    NSError *frcErr;
    [self.frc performFetch:&frcErr];
    
    frcErr = nil;
    
    [fetchRequest release];
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
    self.searchWasActive = [self.searchDisplayController isActive];
    self.savedSearchTerm = [self.searchDisplayController.searchBar text];
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

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[[self fetchedResultsControllerForTableView:tableView] sections] count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsControllerForTableView:tableView] sections] objectAtIndex:section];
    return [sectionInfo name];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsControllerForTableView:tableView] sections] objectAtIndex:section];
    
    NSMutableArray *sectionGuides = [[[NSMutableArray alloc] init] autorelease];
    
    NSString *deltaTitle = @"";
    for(Guideline *guide in [sectionInfo objects]){
        if([guide.title isEqualToString:deltaTitle]){
        }else{
            [sectionGuides addObject:guide];
            deltaTitle = guide.title;
        }

    }
    return [sectionGuides count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
        // Configure the cell.
    [self fetchedResultsController:[self fetchedResultsControllerForTableView:tableView] configureCell:cell atIndexPath:indexPath];
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsControllerForTableView:tableView] sections] objectAtIndex:indexPath.section];
    NSMutableArray *sectionGuides = [[NSMutableArray alloc] init];
    
    NSString *deltaTitle = @"";
    for(Guideline *guide in [sectionInfo objects]){
        if([guide.title isEqualToString:deltaTitle]){
        }else{
            [sectionGuides addObject:guide];
            deltaTitle = guide.title;
        }
        
    }
    Guideline *selectedGuideline = (Guideline *)[sectionGuides objectAtIndex:indexPath.row];
    [sectionGuides release];
    detailObject = selectedGuideline;
    

    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    if (!self.detailViewController) {
	        self.detailViewController = [[[DetailViewController alloc] initWithNibName:@"DetailViewController_iPhone" bundle:nil] autorelease];
             self.detailViewController.hidesBottomBarWhenPushed = YES;
	    }
        [self.detailViewController setDetailItem:detailObject];
       
        [self.navigationController pushViewController:self.detailViewController animated:YES];
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
    }else{
        [self.actuallyworksDetail setDetailItem:detailObject];
        
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//Method to return the fetchedResultsController to use based on comparing if the tableview is the actual table view or the search one
-(NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView{
    return tableView == self.tableView ? self.frc : self.searchfrc;
}

// Method to put info into tableview cell based on the frc in use
- (void)fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController configureCell:(UITableViewCell *)theCell atIndexPath:(NSIndexPath *)theIndexPath{
    
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:theIndexPath.section];
    
    NSMutableArray *sectionGuide = [[NSMutableArray alloc] init];
   
    NSString *deltaTitle = @"";
    for(Guideline *guide in [sectionInfo objects]){
        if([guide.title isEqualToString:deltaTitle]){
        }else{
            [sectionGuide addObject:guide];
            deltaTitle = guide.title;
        }
    }
    Guideline *cellguide = [sectionGuide objectAtIndex:theIndexPath.row];
    [sectionGuide release];
    theCell.textLabel.text = cellguide.title;
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSInteger)scope
{
    self.savedSearchTerm = searchText;
    
  
    if(searchText != nil){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title contains[cd] %@", searchText];
        [self.searchfrc.fetchRequest setPredicate:predicate];
    }else{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"All"];
        [self.searchfrc.fetchRequest setPredicate:predicate];
    }
    
    
    
    NSError *error = nil;
    if(![self.searchfrc performFetch:&error]){
        NSLog(@"error %@, %@", error, [error userInfo]);
    }
    
    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView;
{
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString 
                               scope:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] 
                               scope:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller 
{
    UITableView *tableView = controller == self.searchfrc ? self.tableView : self.searchDisplayController.searchResultsTableView;
    [tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    UITableView *tableView = controller == self.searchfrc ? self.tableView : self.searchDisplayController.searchResultsTableView;
    
    switch(type) 
    {
        case NSFetchedResultsChangeInsert:
            [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObjectatIndexPath:(NSIndexPath *)theIndexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = controller == self.searchfrc ? self.tableView : self.searchDisplayController.searchResultsTableView;
    switch(type) 
    {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:theIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self fetchedResultsController:controller configureCell:[tableView cellForRowAtIndexPath:theIndexPath] atIndexPath:theIndexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:theIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    UITableView *tableView = controller == self.frc ? self.tableView : self.searchDisplayController.searchResultsTableView;
    [tableView endUpdates];
}

- (NSFetchedResultsController *)newFetchedResultsControllerWithSearch:(NSString *)searchString{
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES] autorelease]];
    NSPredicate *filterPredicate = nil; // your predicate here
    
    /*
     Set up the fetched results controller.
     */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *callEntity = [NSEntityDescription entityForName:@"Guideline" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:callEntity];
    
    NSMutableArray *predicateArray = [NSMutableArray array];
    if(searchString.length)
    {
        // your search predicate(s) are added to this array
        [predicateArray addObject:[NSPredicate predicateWithFormat:@"title CONTAINS[cd] %@", searchString]];
        NSLog(@"array:%@",predicateArray);
        // finally add the filter predicate for this view
        if(filterPredicate)
        {
            filterPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:filterPredicate, [NSCompoundPredicate orPredicateWithSubpredicates:predicateArray], nil]];
        }
        else
        {
            filterPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:predicateArray];
        }
    }
    [fetchRequest setPredicate:filterPredicate];
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext  sectionNameKeyPath:nil  cacheName:nil] autorelease];
    
    aFetchedResultsController.delegate = self;
    
    [fetchRequest release];
    
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error]) 
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return aFetchedResultsController;
}    

- (NSFetchedResultsController *)fetchedResultsController {
    if (self.frc != nil) 
    {
        return self.frc;
    }
    self.frc = [self newFetchedResultsControllerWithSearch:nil];
    return [[self.frc retain] autorelease];
}   

- (NSFetchedResultsController *)searchFetchedResultsController {
    if (self.searchfrc != nil) 
    {
        return self.searchfrc;
    }
    self.searchfrc = [self newFetchedResultsControllerWithSearch:self.searchDisplayController.searchBar.text];
    return [[self.searchfrc retain] autorelease];
}

@end

@implementation NSString (FetchedGroupByString)

-(NSString *)stringGroupByFirstInitial{
    if(!self.length || self.length == 1){
        return self;
    }
    return [self substringToIndex:1];
}

@end
