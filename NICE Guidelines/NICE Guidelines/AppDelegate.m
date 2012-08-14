//
//  AppDelegate.m
//  NICE Guidelines
//
//  Created by Colin Wren on 31/07/2012.
//  Copyright (c) 2012 Open Healthcare UK. All rights reserved.
//

#import "AppDelegate.h"

#import "MasterViewController.h"
#import "Guideline.h"
#import "DetailViewController.h"
#import "Reachability.h"
#import "Update.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;
@synthesize splitViewController = _splitViewController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

- (void)dealloc
{
    [_window release];
    [_navigationController release];
    [_splitViewController release];
    [__managedObjectModel release];
    [__managedObjectContext release];
    [__persistentStoreCoordinator release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Save the user_info.plist file to the documents directory
    NSError *plistError;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    path = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"user_info.plist"]];
    
    NSFileManager *fileMan = [NSFileManager defaultManager];
    if(![fileMan fileExistsAtPath:path]){
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"user_info" ofType:@"plist"];
        [fileMan copyItemAtPath:bundle toPath:path error:&plistError];
    }
    
    //See if we have a network connection, if no then don't worry about updating but display a message saying there might be updates available
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    hostReachable = [[Reachability reachabilityWithHostName:@"www.openhealthcare.org.uk"] retain];
    //update if file moves URL
    [hostReachable startNotifier];
    
    updates = [[NSData alloc] init];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        MasterViewController *masterViewController = [[[MasterViewController alloc] initWithNibName:@"MasterViewController_iPhone" bundle:nil] autorelease];
        self.navigationController = [[[UINavigationController alloc] initWithRootViewController:masterViewController] autorelease];
        self.window.rootViewController = self.navigationController;
        masterViewController.managedObjectContext = self.managedObjectContext;
    } else {
        MasterViewController *masterViewController = [[[MasterViewController alloc] initWithNibName:@"MasterViewController_iPad" bundle:nil] autorelease];
        UINavigationController *masterNavigationController = [[[UINavigationController alloc] initWithRootViewController:masterViewController] autorelease];
        
        DetailViewController *detailViewController = [[[DetailViewController alloc] initWithNibName:@"DetailViewController_iPad" bundle:nil] autorelease];
        UINavigationController *detailNavigationController = [[[UINavigationController alloc] initWithRootViewController:detailViewController] autorelease];
        
        masterViewController.actuallyworksDetail = detailViewController;
    	
        self.splitViewController = [[[UISplitViewController alloc] init] autorelease];
        self.splitViewController.delegate = detailViewController;
        self.splitViewController.viewControllers = [NSArray arrayWithObjects:masterNavigationController, detailNavigationController, nil];
        
        self.window.rootViewController = self.splitViewController;
       masterViewController.managedObjectContext = self.managedObjectContext;
    }
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Guidelines" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:@"Guidelines" ofType:@"sqlite"];
    NSString *storePath =  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    storePath = [storePath stringByAppendingPathComponent: @"Guidelines.sqlite"];
    
    NSError *error;
    if(![[NSFileManager defaultManager] fileExistsAtPath:storePath]){
        if([[NSFileManager defaultManager] copyItemAtPath:defaultStorePath toPath:storePath error:&error]){
            NSLog(@"Copied starting data to %@", storePath);
        }else{
            NSLog(@"Error copying default DB to %@ (%@)", storePath, error);
        }
    }
    
    
    NSURL *storeURL = [NSURL fileURLWithPath:storePath];
    
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

-(void)checkNetworkStatus:(NSNotification *)notice{
    NetworkStatus hostStatus = [hostReachable currentReachabilityStatus];
    switch (hostStatus) {
        case NotReachable:
        {
            hostActive = NO;
            break;
        }
        case ReachableViaWiFi:
        {
            hostActive = YES;
            break;
        }
        case ReachableViaWWAN:
        {
            hostActive = YES;
            break;
        }
    }
    [self checkForUpdates];
}
-(void)checkForUpdates{
    //Check for the updated data async
    NSURLRequest *updateData = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.openhealthcare.org.uk/guidelines.xml"] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:60.0];
    updateConnection = [[NSURLConnection alloc] initWithRequest:updateData delegate:self];
    if(updateConnection){
        updatedData = [[NSMutableData data] retain];
        newDataAvailable = NO;
    }
}
//deal with all the connection mumbo jumbo
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    //Grab the header from the response
    NSHTTPURLResponse *hr = (NSHTTPURLResponse *)response;
    NSDictionary *dict = [hr allHeaderFields];
    NSString *lastMod = [dict valueForKey:@"Last-Modified"];
    
    //Convert to a date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss zzzz"];
    NSDate *serverD = [dateFormatter dateFromString:lastMod];
    server = [serverD copy];
    
    //Get current version date from user_info property list
    NSDictionary *user_info_dict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSDate *currentVersion = [user_info_dict valueForKey:@"current_version"];
    
    //Compare with date from user_info 
    if([currentVersion compare:server] == NSOrderedAscending){
        //This means that there is new data
        newDataAvailable = YES;
    }
    
    //reset the data
    [updatedData setLength:0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [updatedData appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
}

//If the connection has finished loading
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [connection release];
    if(newDataAvailable){
        //Do the update stuff as new data is available
        [updates initWithData:updatedData];
        UIAlertView *updateMessage = [[UIAlertView alloc] initWithTitle:@"Updates available" message:@"There is a newer version of the NICE guidelines list. Press Update to download" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Update", nil];
        [updateMessage show];
        [updateMessage release];
    }
}
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1){
        //The user pressed update so now we will run the script to update the information
         if(update == nil){
             update = [[Update alloc] initWithNibName:@"Update" bundle:[NSBundle mainBundle] updateData:updates serverDate:server];
        }
        CGFloat width, height;
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            width = 280.0f;
            height = 280.0f;
        }else{
            width = 320.0f;
            height = 320.0f;
        }
        CGFloat xaxis = (self.window.frame.size.width / 2) - (width / 2);
        CGFloat yaxis = (self.window.frame.size.height / 2) - (height / 2);
        CGRect frame = CGRectMake(xaxis, yaxis, width, height);
        update.view.frame = frame;	
        update.updateData = updates;
        update.appDel = self;
        update.managedObjectContext = self.managedObjectContext;
        [self.window insertSubview:update.view aboveSubview:self.window.rootViewController.view];
    }
}
-(void)finishedUpdates:(id)sender{
    [update.view removeFromSuperview];
    [update release];
    update = nil;
}
@end
