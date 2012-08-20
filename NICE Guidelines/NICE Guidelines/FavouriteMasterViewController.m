//
//  FavouriteMasterViewController.m
//  NICE Guidelines
//
//  Created by Colin Wren on 20/08/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FavouriteMasterViewController.h"

@implementation FavouriteMasterViewController
@synthesize managedObjectContext, detailViewController, detailObject, actuallyworksDetail, table;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Favourites", @"Favourites");
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            self.clearsSelectionOnViewWillAppear = NO;
            self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
        }
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Guideline" inManagedObjectContext:managedObjectContext];
    
    [fetchRequest setEntity:entity];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES] autorelease]]];
    
    frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *path = [documentsDir stringByAppendingPathComponent:@"user_info.plist"];
    
    NSMutableDictionary *plist = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
    NSArray *favourites = [[NSArray alloc] initWithArray:[plist objectForKey:@"favourites"]];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(title in %@)",favourites];
    [fetchRequest setPredicate:pred];
    
    [plist release];
    [favourites release];
    
    NSError *frcErr;
    [frc performFetch:&frcErr];
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
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *path = [documentsDir stringByAppendingPathComponent:@"user_info.plist"];
    
    NSMutableDictionary *plist = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
    NSArray *favourites = [[NSArray alloc] initWithArray:[plist objectForKey:@"favourites"]];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(title in %@)",favourites];
    [fetchRequest setPredicate:pred];
    
    [favourites release];
    [plist release];
    
    NSError *err;
    [frc performFetch:&err];
    [self.table reloadData];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[frc sections] objectAtIndex:0];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"redoing cells");
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[frc sections] objectAtIndex:indexPath.section];
    NSMutableArray *cellGuides = [[NSMutableArray alloc] init];
    
    NSString *deltaTitle = @"";
    for(Guideline *guide in [sectionInfo objects]){
        if([guide.title isEqualToString:deltaTitle]){
        }else{
            [cellGuides addObject:guide];
            deltaTitle = guide.title;
        }
    }
    
    
    Guideline *guide = [cellGuides objectAtIndex:indexPath.row];
    cell.textLabel.text = guide.title;
    [cellGuides release];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{ 
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[frc sections] objectAtIndex:indexPath.section];
    
    NSMutableArray *cellGuides = [[NSMutableArray alloc] init];
    
    NSString *deltaTitle = @"";
    for(Guideline *guide in [sectionInfo objects]){
        if([guide.title isEqualToString:deltaTitle]){
        }else{
            [cellGuides addObject:guide];
            deltaTitle = guide.title;
        }
    }
    Guideline *selectedGuideline = (Guideline *)[cellGuides objectAtIndex:indexPath.row];
    detailObject = selectedGuideline;
    
    [cellGuides release];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    if (!self.detailViewController) {
	        self.detailViewController = [[[DetailViewController alloc] initWithNibName:@"DetailViewController_iPhone" bundle:nil] autorelease];
	    }
        [self.detailViewController setDetailItem:detailObject];
        [self.navigationController pushViewController:self.detailViewController animated:YES];
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
    }else{
        [self.actuallyworksDetail setDetailItem:detailObject];
        
    }
}

//Delete a table row
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDir = [paths objectAtIndex:0];
        NSString *path = [documentsDir stringByAppendingPathComponent:@"user_info.plist"];
        
        NSMutableDictionary *plist = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
        
        id <NSFetchedResultsSectionInfo> sectionInfo = [[frc sections] objectAtIndex:indexPath.section];
        
        NSMutableArray *cellGuides = [[NSMutableArray alloc] init];
        
        NSLog(@"number of faves: %i", [cellGuides count]);
        
        NSString *deltaTitle = @"";
        for(Guideline *guide in [sectionInfo objects]){
            if([guide.title isEqualToString:deltaTitle]){
            }else{
                [cellGuides addObject:guide.title];
                deltaTitle = guide.title;
            }
        }
        
        [cellGuides removeObjectAtIndex:indexPath.row];
        
        NSLog(@"new favourites: %@", cellGuides);
        
        [plist setObject:cellGuides forKey:@"favourites"];
        //need to save server date;
        if([plist writeToFile:path atomically:YES]){
        }else{
            NSLog(@"fail");
        }
        [cellGuides release];
        [plist release];
        NSError *error = nil;
        [frc performFetch:&error];
        [self.table reloadData];

    }
}

@end
