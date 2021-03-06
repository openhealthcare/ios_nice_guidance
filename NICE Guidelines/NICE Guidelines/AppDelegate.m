//
//  AppDelegate.m
//  NICE Guidelines
//
//  Created by Colin Wren on 31/07/2012.
//  Copyright (c) 2012 OpenHealthCare UK. All rights reserved.
//

#import "AppDelegate.h"

#import "MasterViewController.h"
#import "Guideline.h"
#import "DetailViewController.h"
#import "Reachability.h"
#import "Update.h"
#import "CategoryMasterViewController.h"
#import "FavouriteMasterViewController.h"

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
    
    NSArray *vComp = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    
    if ([[vComp objectAtIndex:0] intValue] >= 7) {
        // iOS-7 code[current] or greater
        updates = nil;
    } else if ([[vComp objectAtIndex:0] intValue] < 7) {
        // iOS-6 code
        updates = [[NSData alloc] init];
    }
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    
    
    
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        UITabBarController *tabBarController = [[UITabBarController alloc] init];
        tabBarController.delegate = self;
        
        //If the user iterface is for the iPhone we only load the mast view
        masterViewController = [[[MasterViewController alloc] initWithNibName:@"MasterViewController_iPhone" bundle:nil] autorelease];
        
        catViewController = [[[CategoryMasterViewController alloc] initWithNibName:@"CategoryMasterViewController_iPhone" bundle:nil] autorelease];
        
        favViewController = [[[FavouriteMasterViewController alloc] initWithNibName:@"MasterViewController_iPhone" bundle:nil] autorelease];
        
        //set up the nav controller
        self.navigationController = [[[UINavigationController alloc] initWithRootViewController:masterViewController] autorelease];
        
        UINavigationController *cat = [[[UINavigationController alloc] initWithRootViewController:catViewController] autorelease];
        
        UINavigationController *fav = [[[UINavigationController alloc] initWithRootViewController:favViewController] autorelease];
        
        NSArray *controllers = [NSArray arrayWithObjects:self.navigationController , cat, fav, nil];
        tabBarController.viewControllers = controllers;
        
        self.navigationController.tabBarItem.image = [UIImage imageNamed:@"33-cabinet.png"];
        cat.tabBarItem.image = [UIImage imageNamed:@"15-tags.png"];
        fav.tabBarItem.image = [UIImage imageNamed:@"108-badge.png"];
        
        //set the root view controller to the nav controller
        self.window.rootViewController = tabBarController;//self.navigationController;
        
        //pass the managedObjectContext to the masterview so we can use it there
        masterViewController.managedObjectContext = self.managedObjectContext;
        catViewController.managedObjectContext = self.managedObjectContext;
        favViewController.managedObjectContext = self.managedObjectContext;
        
        
    } else {
        UITabBarController *tabBarController = [[UITabBarController alloc] init];
        tabBarController.delegate = self;
        
        masterViewController = [[[MasterViewController alloc] initWithNibName:@"MasterViewController_iPad" bundle:nil] autorelease];
        
        catViewController = [[[CategoryMasterViewController alloc] initWithNibName:@"CategoryMasterViewController_iPad" bundle:nil] autorelease];
        
       favViewController = [[[FavouriteMasterViewController alloc] initWithNibName:@"MasterViewController_iPad" bundle:nil] autorelease];
        
        UINavigationController *masterNavigationController = [[[UINavigationController alloc] initWithRootViewController:masterViewController] autorelease];
        UINavigationController *cat = [[[UINavigationController alloc] initWithRootViewController:catViewController] autorelease];
        UINavigationController *fav = [[[UINavigationController alloc] initWithRootViewController:favViewController] autorelease];
        
        NSArray *controllers = [NSArray arrayWithObjects:masterNavigationController , cat, fav, nil];
        tabBarController.viewControllers = controllers;
        
        masterNavigationController.tabBarItem.image = [UIImage imageNamed:@"33-cabinet.png"];
        cat.tabBarItem.image = [UIImage imageNamed:@"15-tags.png"];
        fav.tabBarItem.image = [UIImage imageNamed:@"108-badge.png"];
        
        DetailViewController *detailViewController = [[[DetailViewController alloc] initWithNibName:@"DetailViewController_iPad" bundle:nil] autorelease];
        UINavigationController *detailNavigationController = [[[UINavigationController alloc] initWithRootViewController:detailViewController] autorelease];
        
        masterViewController.actuallyworksDetail = detailViewController;
        catViewController.actuallyworksDetail = detailViewController;
        favViewController.actuallyworksDetail = detailViewController;
    	
        self.splitViewController = [[[UISplitViewController alloc] init] autorelease];
        self.splitViewController.delegate = detailViewController;
        self.splitViewController.viewControllers = [NSArray arrayWithObjects:tabBarController, detailNavigationController, nil];
        
        self.window.rootViewController = self.splitViewController;
       masterViewController.managedObjectContext = self.managedObjectContext;
        catViewController.managedObjectContext = self.managedObjectContext;
        favViewController.managedObjectContext = self.managedObjectContext;
    }
    
    [self.window makeKeyAndVisible];
    return YES;
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    NSLog(@"selecting item");
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
    NSLog(@"data:%@ connection: %@", updateData, updateConnection);
    if(updateConnection){
        updatedData = [[NSMutableData data] retain];
        newDataAvailable = NO;
    }
}
//deal with all the connection mumbo jumbo
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSLog(@"receieved response");
    //Grab the header from the response
    NSHTTPURLResponse *hr = (NSHTTPURLResponse *)response;
    NSDictionary *dict = [hr allHeaderFields];
    NSString *lastMod = [dict valueForKey:@"Last-Modified"];
    
    //Convert to a date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss zzzz"];
    NSDate *serverD = [dateFormatter dateFromString:lastMod];
    server = [serverD copy];
    [dateFormatter release];
    
    //Get current version date from user_info property list
    NSDictionary *user_info_dict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSDate *currentVersion = [user_info_dict valueForKey:@"current_version"];
    
    NSLog(@"serverDate:%@ phoneDate:%@", server, currentVersion);
    
    //Compare with date from user_info 
    if([currentVersion compare:server] == NSOrderedAscending){
        //This means that there is new data
        newDataAvailable = YES;
    }
    
    //reset the data
    [updatedData setLength:0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    NSLog(@"received some data");
    [updatedData appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"FAILED to get data");
}

//If the connection has finished loading
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [connection release];
    if(newDataAvailable){
        //Do the update stuff as new data is available
        
        updates = [NSData dataWithData:updatedData];
        //NSLog(@"new data was available and now updating %@", updates);
        
        UIAlertView *updateMessage = [[UIAlertView alloc] initWithTitle:@"Updates available" message:@"There is a newer version of the NICE guidelines list. Press Update to download" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Update", nil];
        [updateMessage show];
        [updateMessage release];
    }
}
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1){
        //The user pressed update so now we will run the script to update the information
        NSLog(@"before calling UPDATE view:%@", updatedData);
        if(update == nil){
             update = [[Update alloc] initWithNibName:@"Update" bundle:[NSBundle mainBundle] updateData:updatedData serverDate:server];
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
        NSLog(@"before setting property");
        update.updateData = updatedData;
        NSLog(@"after setting property");
        update.appDel = self;
        update.managedObjectContext = self.managedObjectContext;
        [self.window insertSubview:update.view aboveSubview:self.window.rootViewController.view];
    }
}
-(void)finishedUpdates:(id)sender{
    [update.view removeFromSuperview];
    [update release];
    update = nil;
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        [masterViewController postUpdateRefresh];
    }else{
        UITabBarController *tabs = (UITabBarController *)[self.splitViewController.viewControllers objectAtIndex:0]; 
        UINavigationController *nav = (UINavigationController *) [tabs.viewControllers objectAtIndex:0];
        [[nav.viewControllers objectAtIndex:0] postUpdateRefresh];
    }
    [favViewController refresh];
    [catViewController refresh];
}
@end
