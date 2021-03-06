//
//  AppDelegate.h
//  NICE Guidelines
//
//  Created by Colin Wren on 31/07/2012.
//  Copyright (c) 2012 OpenHealthCare UK. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Reachability;
@class Update;
@class MasterViewController;
@class FavouriteMasterViewController;
@class CategoryMasterViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>{
    Reachability *hostReachable;
    BOOL hostActive, newDataAvailable;
    NSURLConnection *updateConnection;
    NSMutableData *updatedData;
    Update *update;
    NSData *updates;
    NSDate *server;
    NSString *path;
    MasterViewController *masterViewController;
    FavouriteMasterViewController *favViewController;
    CategoryMasterViewController *catViewController;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *navigationController;

@property (strong, nonatomic) UISplitViewController *splitViewController;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
-(void)checkForUpdates;
-(void)finishedUpdates:(id)sender;
@end
