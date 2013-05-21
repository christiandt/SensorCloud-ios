//
//  Port.h
//  SensorCloud
//
//  Created by Christian Brunner on 5/20/13.
//  Copyright (c) 2013 Christian Brunner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "XivelyDatastreamModel.h"


@interface Port : NSManagedObject <XivelySubscribableDelegate>

@property (strong, nonatomic) XivelyDatastreamModel *model;

@property (nonatomic, retain) NSNumber * currentValue;
@property (nonatomic, retain) NSString * datastreamID;
@property (nonatomic, retain) NSNumber * feedID;
@property (nonatomic, retain) NSNumber * icon;
@property (nonatomic, retain) NSDate * lastUpdate;
@property (nonatomic, retain) NSNumber * portID;

-(void)fetch;
-(void)setCurrentValueWithNumber:(NSNumber*)currentValue;
-(void)setDatastreamIDWithString:(NSString *)datastreamID;
-(void)setFeedIDWithNumber:(NSNumber *)feedID;
-(void)setIconWithNumber:(NSNumber *)icon;
-(void)setPortIDWithNumber:(NSNumber *)portID;
-(void)setLastUpdateWithString:(NSString *)lastUpdate;

@end
