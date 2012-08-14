//
//  Update.m
//  NICE Guidelines
//
//  Created by Colin Wren on 12/08/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Update.h"
#import "Guideline.h"

@implementation Update
@synthesize updateData, appDel, managedObjectContext;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil updateData:(NSData *)updates serverDate:(NSDate *)server
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        if(managedObjectContext == nil){
            managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        }
        if(updateData == nil){
            updateData = [[NSData alloc] initWithData:updates];
        }
        if(serverDate == nil){
            serverDate = [[NSDate alloc] init];
            serverDate = server;
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
    // Do any additional setup after loading the view from its nib.
    continueButton.enabled = NO;
    
    //Set up sort descriptors for organising the data
    NSSortDescriptor *catsort = [[NSSortDescriptor alloc] initWithKey:@"category" ascending:YES];
    NSSortDescriptor *subsort = [[NSSortDescriptor alloc] initWithKey:@"subcategory" ascending: YES];
    NSSortDescriptor *titlesort = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    //grab the existing data
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Guideline" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:catsort,subsort,titlesort,nil]];
    NSError *error;
    
    //put that data into an array
    currentItems = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    
    //Now grab the import data
    xmlI = [[NSMutableArray alloc] init];
    [self parseXMLData:updateData];
    
    
    items = [xmlI sortedArrayUsingDescriptors:[NSArray arrayWithObjects:catsort, subsort, titlesort, nil]];
    NSEnumerator* importIterator = [items objectEnumerator];
    NSEnumerator* objectIterator = [currentItems objectEnumerator];
    NSString *thisImportIdentifier = [importIterator nextObject];
    NSManagedObject *thisObject = [objectIterator nextObject];
    NSArray *overwritables = [[NSArray alloc] initWithObjects:@"url",@"code",@"category",@"subcategory", nil];
    NSUInteger currentInt = 0;
    progress.progress = 0;
    // Loop through both lists, comparing identifiers, until both are empty
    while (thisImportIdentifier || thisObject) {
        // Compare identifiers
        NSComparisonResult comparison;
        if (!thisImportIdentifier) {  // If the import list has run out, the import identifier sorts last (i.e. remove remaining objects)
            comparison = NSOrderedDescending;
        } else if (!thisObject) {  // If managed object list has run out, the import identifier sorts first (i.e. add remaining objects)
            comparison = NSOrderedAscending;
        } else {  // If neither list has run out, compare with the object
            comparison = [[thisImportIdentifier valueForKey:@"title"] compare:[thisObject valueForKey:@"title"]];
        }
        if (comparison == NSOrderedSame) {  // Identifiers match
            
            if (overwritables) {  // Merge the allowed non-identifier properties, if not nil
                NSDictionary *importAttributes = [items objectAtIndex:currentInt];
                NSDictionary *overwriteAttributes = [NSDictionary dictionaryWithObjects:[importAttributes objectsForKeys:overwritables notFoundMarker:@""] forKeys:overwritables];
                
                [thisObject setValuesForKeysWithDictionary:overwriteAttributes];
                NSError *error;
                if(![self.managedObjectContext save:&error]){
                    NSLog(@"error saving updated object: %@ %@", error, [error localizedDescription]);
                }
            }
            
            // Move ahead in both lists 
           
    
            thisObject = [objectIterator nextObject];
            thisImportIdentifier = [importIterator nextObject];
            currentInt++;
            progress.progress = (currentInt / [items count]);
       } else if (comparison == NSOrderedAscending) {  // Imported item sorts before stored item
            
            // The imported item is previously unseen - add it and move ahead to the next import identifier
            
            NSManagedObject *newObject = [NSEntityDescription insertNewObjectForEntityForName:@"Guidelines" inManagedObjectContext:self.managedObjectContext];
            [newObject setValue:[thisImportIdentifier valueForKey:@"title"] forKey:@"title"];
            [newObject setValue:[thisImportIdentifier valueForKey:@"url"] forKey:@"url"];
            [newObject setValue:[thisImportIdentifier valueForKey:@"code"] forKey:@"code"];
            [newObject setValue:[thisImportIdentifier valueForKey:@"category"] forKey:@"category"];
            [newObject setValue:[thisImportIdentifier valueForKey:@"subcategory"] forKey:@"subcategory"];
            //[newObject setValuesForKeysWithDictionary:[items objectAtIndex:currentInt]];
            thisImportIdentifier = [importIterator nextObject];
            currentInt++;
            progress.progress = (currentInt / [items count]);
        } else {  // Imported item sorts after stored item
            
            // The stored item is not among those imported, and should be removed, then move ahead to the next stored item
            
            [self.managedObjectContext deleteObject:thisObject];
            thisObject = [objectIterator nextObject];
            currentInt++;
            progress.progress = (currentInt / [items count]);
        }
    }
    //Need to now save the timestamp to the user_info.plist file
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *path = [documentsDir stringByAppendingPathComponent:@"user_info.plist"];
    
    NSMutableDictionary *plist = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
    //need to save server date
    [plist setObject:serverDate forKey:@"current_version"];
    if([plist writeToFile:path atomically:YES]){
        continueButton.enabled = YES;
    }else{
        [appDel finishedUpdates:nil];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
-(void)parseXMLData:(NSData *)xmlData{
    items = [[NSMutableArray alloc] init];
    parser = [[NSXMLParser alloc] initWithData:xmlData];
    [parser setDelegate:self];
    [parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];
    [parser parse];
}
-(void)parserDidStartDocument:(NSXMLParser *)parser{
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSString * errorString = [NSString stringWithFormat:@"Unable to download story feed from web site (Error code %i )", [parseError code]];
	NSLog(@"issue: %@", errorString);
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    element = [elementName copy];
    if([elementName isEqualToString:@"guideline"]){
        xmlItem = [[NSMutableDictionary alloc] init];
        title = [[NSMutableString alloc] init];
        url = [[NSMutableString alloc] init];
        code = [[NSMutableString alloc] init];
        category = [[NSMutableString alloc] init];
        subcat = [[NSMutableString alloc] init];
        [code appendString:[attributeDict objectForKey:@"code"]];
        [category appendString:[attributeDict objectForKey:@"category"]];
        [subcat appendString:[attributeDict objectForKey:@"subcategory"]];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    if([elementName isEqualToString:@"guideline"]){
        
        /*Guideline *item = [NSEntityDescription insertNewObjectForEntityForName:@"Guideline" inManagedObjectContext:context]; 
        
        item.title = title;
        item.url = url;
        item.code = code; 
        item.category = category;
        item.subcategory = subcat;*/
        [xmlItem setObject:title forKey:@"title"];
        [xmlItem setObject:url forKey:@"url"];
        [xmlItem setObject:code forKey:@"code"];
        [xmlItem setObject:category forKey:@"category"];
        [xmlItem setObject:subcat forKey:@"subcategory"];
        [xmlI addObject:xmlItem];
        /*[title release];
        [url release];
        [code release];
        [category release];
        [subcat release];*/
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    NSString *cleanString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    
    if([element isEqualToString:@"title"]){
        [title appendString:cleanString];
    }
    if([element isEqualToString:@"url"]){
        [url appendString:cleanString];
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    
}
-(IBAction)contPressed:(id)sender{
    [appDel finishedUpdates:nil];
}

@end
