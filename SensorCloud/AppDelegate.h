//
//  AppDelegate.h
//  SensorCloud
//
//  Created by Christian Brunner on 5/18/13.
//  Copyright (c) 2013 Christian Brunner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PebbleKit/PebbleKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, PBPebbleCentralDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property PBWatch *pebbleWatch;
@property id messagesAddReceiveUpdateHandler;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (BOOL)handleWatch:(PBWatch*)watch message:(NSDictionary*)message;

@end
