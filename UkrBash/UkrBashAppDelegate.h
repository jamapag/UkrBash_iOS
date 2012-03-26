//
//  UkrBashAppDelegate.h
//  UkrBash
//
//  Created by Maks Markovets on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UBNavigationController.h"
#import "FBConnect.h"

@interface UkrBashAppDelegate : NSObject <UIApplicationDelegate> {
    UBNavigationController *navigationController;
    Facebook *facebook;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) Facebook *facebook;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
