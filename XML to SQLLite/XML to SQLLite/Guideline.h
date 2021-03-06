//
//  Guideline.h
//  XML to SQLLite
//
//  Created by Colin Wren on 06/08/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Guideline : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * subcategory;
@property (nonatomic, retain) NSString * code;

@end
