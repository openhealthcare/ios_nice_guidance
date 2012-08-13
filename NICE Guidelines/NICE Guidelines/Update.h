//
//  Update.h
//  NICE Guidelines
//
//  Created by Colin Wren on 12/08/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface Update : UIViewController{
    NSMutableData *updateData;
    AppDelegate *appDel;
    IBOutlet UIButton *continueButton;
    IBOutlet UIImageView *progressImage;
    NSMutableArray *items;
    NSArray *currentItems;
}
@property (nonatomic, retain) NSMutableData *updateData;
@property (nonatomic, retain) AppDelegate *appDel;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
