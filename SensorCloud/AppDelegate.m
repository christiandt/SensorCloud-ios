//
//  AppDelegate.m
//  SensorCloud
//
//  Created by Christian Brunner on 5/18/13.
//  Copyright (c) 2013 Christian Brunner. All rights reserved.
//

#import "AppDelegate.h"
#import "MasterViewController.h"
#import "XivelyAPI.h"
#import "Port.h"
#import <ExternalAccessory/ExternalAccessory.h>

#define XIVELY_UUID { 0x11, 0x91, 0xB6, 0x2B, 0xBA, 0x19, 0x99, 0x8F, 0xC1, 0x37, 0x14, 0x8F, 0x29, 0xA1, 0x44, 0xAC }

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize pebbleWatch = _pebbleWatch;
@synthesize messagesAddReceiveUpdateHandler = _messagesAddReceiveUpdateHandler;
@synthesize fetchedResultsController = _fetchedResultsController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog (@"didFinishLaunchingWithOptions");
    // Override point for customization after application launch.
    /*UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    MasterViewController *controller = (MasterViewController *)navigationController.topViewController;
    controller.managedObjectContext = self.managedObjectContext;*/
    
    // We'd like to get called when Pebbles connect and disconnect, so become the delegate of PBPebbleCentral:
    [[PBPebbleCentral defaultCentral] setDelegate:self];
    
    // Initialize with the last connected watch:
    [self setTargetWatch:[[PBPebbleCentral defaultCentral] lastConnectedWatch]];
    
    // set the API key for Xively
    NSString* xivelyApiKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"XivelyApiKey"];
    if (xivelyApiKey == nil)
        xivelyApiKey = @"txvM3AzitVGjBZCHJZgRsTHANCYOkDmkWEUTqOCnuGGSdxwe";
    
    [[XivelyAPI defaultAPI] setApiKey:xivelyApiKey];
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog (@"applicationWillResignActive");
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog (@"applicationDidEnterBackground");
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog (@"applicationWillEnterForeground");
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    // Initialize with the last connected watch:

    [self setTargetWatch:[[PBPebbleCentral defaultCentral] lastConnectedWatch]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog (@"applicationDidBecomeActive");
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog (@"applicationWillTerminate");
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

/*
 *  PBPebbleCentral delegate methods
 */

- (void)pebbleCentral:(PBPebbleCentral*)central watchDidConnect:(PBWatch*)watch isNew:(BOOL)isNew
{
    NSLog(@"watch connected.");

    [self setTargetWatch:watch];
}

- (void)pebbleCentral:(PBPebbleCentral*)central watchDidDisconnect:(PBWatch*)watch
{
    NSLog(@"watch disconnected.");

    [[[UIAlertView alloc] initWithTitle:@"Disconnected!" message:[watch name] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    if (_pebbleWatch == watch || [watch isEqual:_pebbleWatch])
    {
        [self setTargetWatch:nil];
    }
}

- (BOOL)handleWatch:(PBWatch *)watch message:(NSDictionary *)message
{
    NSLog(@"Message received.");

    if (self.fetchedResultsController)
    {
        for (int idx = 0; idx < [self.fetchedResultsController.fetchedObjects count]; idx++)
        {
            Port* port = [self.fetchedResultsController.fetchedObjects objectAtIndex:idx];
            [port fetch];
        }
    }
    
    return YES;
}

- (void)setTargetWatch:(PBWatch*)watch
{
    NSLog(@"set target watch.");

    _pebbleWatch = watch;
    
    // NOTE:
    // For demonstration purposes, we start communicating with the watch immediately upon connection,
    // because we are calling -appMessagesGetIsSupported: here, which implicitely opens the communication session.
    // Real world apps should communicate only if the user is actively using the app, because there
    // is one communication session that is shared between all 3rd party iOS apps.
    
    uint8_t uuid[] = XIVELY_UUID;
    [watch appMessagesSetUUID:[NSData dataWithBytes:uuid length:sizeof(uuid)]];

    // Test if the Pebble's firmware supports AppMessages / Sports:
    [watch appMessagesGetIsSupported:^(PBWatch *watch, BOOL isAppMessagesSupported)
    {
        if (isAppMessagesSupported)
        {
            
            if(_pebbleWatch && _messagesAddReceiveUpdateHandler)
                [_pebbleWatch appMessagesRemoveUpdateHandler:_messagesAddReceiveUpdateHandler];
            
            _messagesAddReceiveUpdateHandler = [watch appMessagesAddReceiveUpdateHandler:^BOOL(PBWatch *watch, NSDictionary *update)
            {
                return [self handleWatch:watch message:update];
            }];
            
            NSLog(@"Yay! %@ supports AppMessages :D", [watch name]);
            //[[[UIAlertView alloc] initWithTitle:@"Connected!" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        else
        {
            NSLog(@"Blegh... %@ does NOT support AppMessages :'(", [watch name]);
            //[[[UIAlertView alloc] initWithTitle:@"Connected..." message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SensorCloud" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"SensorCloud.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
