//
//  Guidelines.h
//  NICE Guidelines
//
//  Created by Colin Wren on 31/07/2012.
//  Copyright (c) 2012 Open Healthcare UK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Guidelines : NSManagedObject

@property(nonatomic, strong)NSString *title;
@property(nonatomic, strong)NSString *url;
@property(nonatomic, strong)NSString *category;
@property(nonatomic, strong)NSString *code;
@property(nonatomic, strong)NSString *subcategory;


@end
