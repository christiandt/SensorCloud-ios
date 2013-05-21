//
//  Port.m
//  SensorCloud
//
//  Created by Christian Brunner on 5/20/13.
//  Copyright (c) 2013 Christian Brunner. All rights reserved.
//

#import "Port.h"
#import "AppDelegate.h"


@implementation Port

@dynamic currentValue;
@dynamic datastreamID;
@dynamic feedID;
@dynamic icon;
@dynamic lastUpdate;
@dynamic portID;

@synthesize model = _model;

+(void)queueToPebble:(Port*)port
{
    static NSMutableArray* queue = nil;
    
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    @synchronized(appDelegate)
    {
        if (!queue)
            queue = [[NSMutableArray alloc]init];
    
        [queue addObject:port];
    
        // send update to pebble
        if ([queue count] >= 5 && appDelegate.pebbleWatch)
        {
            NSLog(@"Sending data dictionary.");

            NSMutableDictionary* update = [[NSMutableDictionary alloc] init];

            for (int idx = 0; idx < [queue count]; idx++)
            {
                Port* currentPort = [queue objectAtIndex:idx];
                
                int portID = [currentPort.portID int32Value];
                NSNumber* keyData = [NSNumber numberWithUint32:0xFF1F + (portID-1)*16];
                NSNumber* keyIcon = [NSNumber numberWithUint32:0xFF1E + (portID-1)*16];
        
                [update setObject:[currentPort.currentValue description] forKey:keyData];
                [update setObject:[NSNumber numberWithUint8:[currentPort.icon int8Value]] forKey:keyIcon];
            }

            [appDelegate.pebbleWatch appMessagesPushUpdate:update onSent:^(PBWatch *watch, NSDictionary *update, NSError *error)
            {
                if(!error)
                {
                    NSLog(@"Sending data dictionary success.");
                }
                else
                {
                    NSLog(@"Sending data dictionary error: %@", error);
                }
            }];
            
            [queue removeAllObjects];
            
            // Save the context.
            NSError *error = nil;
            if (![appDelegate.managedObjectContext save:&error])
            {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            }
        }
    }
}

-(void)setCurrentValueWithNumber:(NSNumber*)currentValue
{
  
    if ([currentValue compare:[self currentValue]] != NSOrderedSame)
        self.currentValue = currentValue;
}

-(void)setDatastreamIDWithString:(NSString *)datastreamID
{
    if ([datastreamID compare:[self datastreamID]] != NSOrderedSame)
        self.datastreamID = datastreamID;
}

-(void)setFeedIDWithNumber:(NSNumber *)feedID
{
    if ([feedID compare:[self feedID]] != NSOrderedSame)
        self.feedID = feedID;
}

-(void)setIconWithNumber:(NSNumber *)icon
{
    if ([icon compare:[self icon]] != NSOrderedSame)
        self.icon = icon;
}

-(void)setLastUpdateWithString:(NSString *)lastUpdate
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    
    NSDate* at = [dateFormatter dateFromString:lastUpdate];
    if ([at compare:[self lastUpdate]] != NSOrderedSame)
        self.lastUpdate = at;
}

-(void)setPortIDWithNumber:(NSNumber *)portID
{
    if ([portID compare:[self portID]] != NSOrderedSame)
        self.portID = portID;
}

-(void)fetch
{
    if (!self.model)
        self.model = [[XivelyDatastreamModel alloc]init];
    
    [self.model unsubscribe];
    self.model.delegate = nil;
    
    self.model.feedId = [self.feedID integerValue];
    [self.model.info setObject:self.datastreamID forKey:@"id"];
    self.model.delegate = self;
    [self.model fetch];
}

-(void)updateModel:(XivelyModel*)model
{
    NSString* currentValue = (NSString*)[[model info] valueForKeyPath:@"current_value"];
    NSString* lastUpdate = (NSString*)[[model info] valueForKeyPath:@"at"];
    
    [self setCurrentValueWithNumber:[NSNumber numberWithDouble:[currentValue doubleValue]]];
    [self setLastUpdateWithString:lastUpdate];
}

#pragma mark – Socket Connection Delegate Methods

- (void)modelDidSubscribe:(XivelyModel *)model
{
    NSLog (@"modelDidSubscribe");
}

- (void)modelDidUnsubscribe:(XivelyModel *)model withError:(NSError *)error
{
    NSLog (@"modelDidUnsubscribe");
    if (error)
    {
        NSLog(@"Error subscribing %@", error);
    }
}

- (void)modelUpdatedViaSubscription:(XivelyModel *)model
{
    NSLog (@"modelUpdatedViaSubscription");
    [self updateModel:model];
}

#pragma mark - Xively Model Delegate Methods

- (void)modelDidFetch:(XivelyModel *)model
{
    NSLog (@"modelDidFetch");
    [self updateModel:model];
    [Port queueToPebble:self];
}

- (void)modelFailedToFetch:(XivelyModel *)model withError:(NSError *)error json:(id)JSON
{
    NSLog (@"modelFailedToFetch: %@", error);
    [Port queueToPebble:self];
}

@end
