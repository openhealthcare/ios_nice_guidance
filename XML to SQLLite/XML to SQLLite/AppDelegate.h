//
//  AppDelegate.h
//  XML to SQLLite
//
//  Created by Colin Wren on 06/08/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSXMLParserDelegate>{
    NSXMLParser *parser;
    NSString *element;
    NSMutableString *title, *url, *category, *code, *subcat;
    IBOutlet NSTextField *counter;
    int number;
}

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;
-(void)loadInitialData;
@end
