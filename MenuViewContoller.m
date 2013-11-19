//
//  MenuViewContoller.m
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 07/11/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "MenuViewContoller.h"
#import "GalleryViewController.h"
#import "ManagedDocumentHelper.h"
#import "UserProfileViewController.h"
#import "User+Create.h"
#import "DetectorFetcher.h"
#import "Detector+Server.h"

@interface MenuViewContoller()
{
    User *_currentUser;
    UIManagedDocument *_database;
}

@end


@implementation MenuViewContoller


- (void) initializeDataBase
{
    if(!_database){
        _database = [ManagedDocumentHelper sharedDatabaseUsingBlock:^(UIManagedDocument *document){
            _currentUser = [User getCurrentUserInManagedObjectContext:document.managedObjectContext];
            [self performSelectorOnMainThread:@selector(loadDataOnTable) withObject:nil waitUntilDone:NO];
        }];
    }
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    [self initializeDataBase];
}

- (void) initializeUserProfile
{
    self.usernameLabel.text = _currentUser.username;
    self.profileImage.image = [UIImage imageWithData:_currentUser.image];
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadDataOnTable];
}

- (void) loadDataOnTable
{
    [self initializeUserProfile];
    [self setNumberOfDetectors];
}


#pragma mark -
#pragma mark Segue


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if([[segue identifier] isEqualToString:@"Profile"]){
        UserProfileViewController *userProfileVC = (UserProfileViewController *) segue.destinationViewController;
        userProfileVC.currentUser = _currentUser;
        
    }else{
        GalleryViewController *galleryVC = (GalleryViewController *) segue.destinationViewController;
        galleryVC.filter = segue.identifier;
        galleryVC.detectorDatabase = _database;
    }
}


#pragma mark -
#pragma mark Private Methods

- (void) setNumberOfDetectors
{
    int number;
    NSFetchRequest *request;
    
    // single
    request = [NSFetchRequest fetchRequestWithEntityName:@"Detector"];
    request.predicate = [NSPredicate predicateWithFormat:@"user.username == %@", _currentUser.username];
    number = [self resultsForRequest:request];
    self.numSingle.text = [NSString stringWithFormat:@"%d", number];

    // multiple
    request = [NSFetchRequest fetchRequestWithEntityName:@"MultipleDetector"];
    number = [self resultsForRequest:request];
    self.numMultiple.text = [NSString stringWithFormat:@"%d", number];

    // server
    request = [NSFetchRequest fetchRequestWithEntityName:@"Detector"];
    number = [self resultsForRequest:request];
    self.numServer.text = [NSString stringWithFormat:@"%d", number];
    
    [self.tableView reloadData];
}


- (int) resultsForRequest:(NSFetchRequest *)request
{
    NSError *error;
    NSArray *matches = [_database.managedObjectContext executeFetchRequest:request error:&error];
    
    return matches.count;
}



@end
