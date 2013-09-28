//
//  Update.m
//  NICE Guidelines
//
//  Created by Colin Wren on 12/08/2012.
//  Copyright (c) 2012 OpenHealthCare UK. All rights reserved.
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
       NSLog(@"updateData before");
        if(updateData == nil){
            NSArray *vComp = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
            
            if ([[vComp objectAtIndex:0] intValue] >= 7) {
                // iOS-7 code[current] or greater
                updateData = updates;//[NSData dataWithData:updates];
            } else if ([[vComp objectAtIndex:0] intValue] < 7) {
                // iOS-6 code
                updateData = [[NSData alloc] initWithData:updates];
            }
            
        }
        NSLog(@"updateData after");
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
    NSLog(@"view loaded");
    //Set up sort descriptors for organising the data
    NSSortDescriptor *catsort = [[NSSortDescriptor alloc] initWithKey:@"category" ascending:YES];
    NSSortDescriptor *subsort = [[NSSortDescriptor alloc] initWithKey:@"subcategory" ascending: YES];
    NSSortDescriptor *titlesort = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    //grab the existing data
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Guideline" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:catsort,subsort,titlesort,nil]];
    [catsort release];
    [titlesort release];
    [subsort release];
    NSError *error;
    
    //put that data into an array
    currentItems = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    
    //Now grab the import data
    xmlI = [[NSMutableArray alloc] init];
    [self parseXMLData:updateData];
    
    NSLog(@"after parsing XML");
    
    items = [xmlI sortedArrayUsingDescriptors:[NSArray arrayWithObjects:catsort, subsort, titlesort, nil]];
    NSLog(@"deleting the items");
    for(NSManagedObject *thisObj in currentItems){
        [self.managedObjectContext deleteObject:thisObj];
    }
    
    if(![self.managedObjectContext save:&error]){
        NSLog(@"handle error for not being able to delete existing data");
    }
    
    progress.progress = 0.5;
    
    NSLog(@"before saving");
    
    for(NSDictionary *dict in items){
        Guideline *newGuide = [NSEntityDescription insertNewObjectForEntityForName:@"Guideline" inManagedObjectContext:self.managedObjectContext];
        newGuide.title = [dict objectForKey:@"title"];
        newGuide.code = [dict objectForKey:@"code"];
        newGuide.category = [dict objectForKey:@"category"];
        newGuide.subcategory = [dict objectForKey:@"subcat"];
        newGuide.url = [dict objectForKey:@"url"];
    }
    
    NSLog(@"after saving");
    
    if(![self.managedObjectContext save:&error]){
        UIAlertView *ohno = [[UIAlertView alloc] initWithTitle:@"Error updating" message:@"There was an error while saving the new guideline data" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:@"", nil];
        [ohno show];
        [ohno release];
    }
    
    progress.progress = 1.0;
    
    
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
    [plist release];
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
    NSLog(@"parsing data");
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
        NSLog(@"XML:%@", xmlI);
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
