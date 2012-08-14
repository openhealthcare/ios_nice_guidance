//
//  Update.h
//  NICE Guidelines
//
//  Created by Colin Wren on 12/08/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface Update : UIViewController<NSXMLParserDelegate>{
    NSData *updateData;
    AppDelegate *appDel;
    IBOutlet UIButton *continueButton;
    IBOutlet UIProgressView *progress;
    NSMutableDictionary *xmlItem;
    NSMutableArray *xmlI;
    NSArray *currentItems, *items;
    NSXMLParser *parser;
    NSString *element;
    NSMutableString *title, *category, *code, *subcat,*url;
    NSDate *serverDate;
}
@property (nonatomic, retain) NSData *updateData;
@property (nonatomic, retain) AppDelegate *appDel;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil updateData:(NSData *)updates serverDate:(NSDate *)server;
-(void)parseXMLData:(NSData *)xmlData;
-(IBAction)contPressed:(id)sender;
@end
