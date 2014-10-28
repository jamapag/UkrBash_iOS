//
//  UkrBashAppDelegate.m
//  UkrBash
//
//  Created by Maks Markovets on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UkrBashAppDelegate.h"
#import "UBQuotesContainerController.h"
#import "UBPicturesCollectionViewController.h"
#import "UBMenuViewController.h"
#import "UBNavigationController.h"
#import "UBPublishedQuotesDataSource.h"
#import "UBPublishedPicturesDataSource.h"
#import "UBFetchedPicturesDataSource.h"
#import "UBFavoritePicturesDataSource.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import "ApiKey.h"
#import "SharingController.h"
#import "FacebookSharingController.h"
#import "Reachability.h"
#import "Quote.h"
#import "UBQuotesController.h"
#import "UBPicturesController.h"
#import "UBMainViewController.h"
#import <sys/sysctl.h>


@implementation UkrBashAppDelegate


@synthesize window=_window;

@synthesize managedObjectContext=__managedObjectContext;

@synthesize managedObjectModel=__managedObjectModel;

@synthesize persistentStoreCoordinator=__persistentStoreCoordinator;

-(NSString *)deviceType {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);

    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 CDMA";
    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5C";
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5C CDMA";
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5S";
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5S CDMA";
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad-3G (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad-3G (GSM)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad-3G (CDMA)";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad4Wifi";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad4GSM";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad4CDMA";
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";

    return platform;
}

- (UBCenterViewController *)containerWithType:(NSString*)type dataSource:(NSString*)dataSource
{
    if (!type) {
        return [[[UBQuotesContainerController alloc] initWithDataSourceClass:[UBPublishedQuotesDataSource class]] autorelease];
    } else if ([type isEqualToString:UBContainerTypeQuotes]) {
        if (!dataSource) {
            dataSource = NSStringFromClass([UBPublishedQuotesDataSource class]);
        }
        if ([dataSource isEqualToString:@"UBFavoriteQuotesDataSource"]) {
            return [[[UBQuotesController alloc] initWithDataSourceClass:NSClassFromString(dataSource)] autorelease];
        }
        return [[[UBQuotesContainerController alloc] initWithDataSourceClass:NSClassFromString(dataSource)] autorelease];
    } else if ([type isEqualToString:UBContainerTypePictures]) {
        if (!dataSource) {
            dataSource = NSStringFromClass([UBPublishedPicturesDataSource class]);
        }
        if ([dataSource isEqualToString:@"UBFavoritePicturesDataSource"]) {
            return [[[UBPicturesController alloc] initWithDataSourceClass:NSClassFromString(dataSource)] autorelease];
        }
        return [[[UBPicturesCollectionViewController alloc] initWithDataSourceClass:NSClassFromString(dataSource)] autorelease];
    }
    return nil;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#if TARGET_IPHONE_SIMULATOR
    [[GAI sharedInstance].logger setLogLevel:kGAILogLevelVerbose];
#endif
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:kGANAccountID];
    [tracker set:[GAIFields customDimensionForIndex:1] value:[self deviceType]];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"copying"
                                                          action:@"quotes"
                                                           label:@"quote"
                                                           value:@(-1)] build]];
    
    [self.window makeKeyAndVisible];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *containerType = [userDefaults stringForKey:UBContainerTypeKey];
    NSString *containerTitle = [userDefaults stringForKey:UBContainerTitleKey];
    NSString *containerDataSource = [userDefaults stringForKey:UBContainerDataSourceKey];
    if (!containerTitle) {
        containerTitle = @"Опубліковане";
    }
    
    UBCenterViewController *containerController = [self containerWithType:containerType dataSource:containerDataSource];
    containerController.title = containerTitle;
    UBMainViewController *mainViewController = [[UBMainViewController alloc] initWithContainerController:containerController];
    self.window.rootViewController = mainViewController;
    [self.window addSubview:mainViewController.view];
    
    Reachability *reach = [Reachability reachabilityWithHostname:@"www.ukrbash.com"];
    reach.unreachableBlock = ^(Reachability *reach) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *titles = @[@"Невдача!", @"От халепа!"];
            NSArray *messages = @[@"Щось не так зі зв`язком. Або з Інтернетом. Або із сайтом UkrBash. Або з телефоном.",
                                  @"Не вдається вийти на зв`язок. Треба перевірити налаштування інтернетів."];
            NSArray *buttons = @[@"Ну добре", @"OK", @"Зараз перевірю"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[titles objectAtIndex:arc4random_uniform((u_int32_t)titles.count)]
                                                            message:[messages objectAtIndex:arc4random_uniform((u_int32_t)messages.count)]
                                                           delegate:nil
                                                  cancelButtonTitle:[buttons objectAtIndex:arc4random_uniform((u_int32_t)buttons.count)]
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        });
    };
    [reach startNotifier];
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)dealloc
{
    [_window release];
    [__managedObjectContext release];
    [__managedObjectModel release];
    [__persistentStoreCoordinator release];
    [navigationController release];
    [super dealloc];
}

- (void)awakeFromNib
{
    /*
     Typically you should set up the Core Data stack here, usually by passing the managed object context to the first view controller.
     self.<#View controller#>.managedObjectContext = self.managedObjectContext;
    */
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"UkrBash" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"UkrBash.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
