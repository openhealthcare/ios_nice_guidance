//
//  MasterViewController.h
//  NICE Guidelines
//
//  Created by Colin Wren on 31/07/2012.
//  Copyright (c) 2012 Open Healthcare UK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Guidelines.h"

@class DetailViewController;

@interface MasterViewController : UITableViewController<NSXMLParserDelegate>{
    NSArray *menuItems;
    NSXMLParser *menuParser;
    NSString *currentElement;
    NSMutableString *currentTitle, *currentURL, *currentCategory, *currentCode, *currentSubCat;
    NSMutableArray *menuData;
    Guidelines *guideline;
}

@property (strong, nonatomic) DetailViewController *detailViewController;
@property (strong, nonatomic) DetailViewController *actuallyworksDetail;
@property (strong, nonatomic)id detailObject;
-(NSArray *)loadMenu;
-(void)parseXMLFileAtURL:(NSString *)URL;


@end
