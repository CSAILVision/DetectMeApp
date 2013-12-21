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
#import "Detector+Server.h"
#import "UIViewController+ShowAlert.h"
#import "WaitingView.h"

@interface MenuViewContoller()
{
    User *_currentUser;
    UIManagedDocument *_database;
    WaitingView *_waitingView;
}

@end


@implementation MenuViewContoller


- (void) initializeWaitingView
{
    _waitingView = [[WaitingView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:_waitingView];
}

- (void) initializeDataBase
{
    if(!_database){
        _database = [ManagedDocumentHelper sharedDatabaseUsingBlock:^(UIManagedDocument *document){}];
        _currentUser = [User getCurrentUserInManagedObjectContext:_database.managedObjectContext];
    }
}

- (void) initializeTitle
{
    UIImageView *titleView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    titleView.image = [UIImage imageNamed:@"detectmeTitle.png"];
    titleView.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = titleView;
}



- (void) viewDidLoad
{
    [super viewDidLoad];
    [self initializeDataBase];
    [self initializeTitle];
}

- (void) initializeUserProfile
{
    self.usernameLabel.text = _currentUser.username;
    if(_currentUser.image)
        self.profileImage.image = [UIImage imageWithData:_currentUser.image];
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadDataOnTable];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:171.0/255 green:30.0/255 blue:52.0/255 alpha:1];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.barTintColor = nil;
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
#pragma mark DetectorFetcherDelegate

- (void) obtainedDetectors:(NSArray *)detectorsJSON
{
    for(NSDictionary *detectorInfo in detectorsJSON){
        //start creating objects in document's context
        [Detector detectorWithDictionaryInfo:detectorInfo inManagedObjectContext:_database.managedObjectContext];
    }
    
    // when finished, present them on the screen and stop the activity indicator
    [self setNumberOfDetectors];
    [_waitingView stopWatingViewWithMessage:@"Detectors Downloaded!"];
}

- (void) downloadError:(NSString *)error
{
    [_waitingView stopWatingViewWithMessage:[NSString stringWithFormat:@"Error:%@",error]];
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
    if (number==0) {
        [self downloadDetectors];
    }
    
    [self.tableView reloadData];
}


- (int) resultsForRequest:(NSFetchRequest *)request
{
    [request setIncludesSubentities:NO];
    
    NSError *error;
    NSUInteger count = [_database.managedObjectContext countForFetchRequest:request error:&error];
    
    return count;
}

- (void) downloadDetectors
{
    //prepare waiting view
    [self initializeWaitingView];
    [_waitingView startWaitingViewWithMessage:@"Updating from server..."];
    
    DetectorFetcher *df = [[DetectorFetcher alloc] init];
    df.delegate = self;
    [df fetchDetectorsASync];
}



//- (void) fetchDetectorsFromServerIntoDocument:(UIManagedDocument *) document
//{
//    // Populate the table if it was not.
//    // |document| as an argument for thread safe: someone could change the propertie in parallel
//    dispatch_queue_t fetchQ = dispatch_queue_create("Detectors Fetcher", NULL);
//    dispatch_async(fetchQ, ^{
//        NSArray *detectors = [DetectorFetcher fetchDetectorsSync];
//        
//        if(!detectors){
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self showAlertWithTitle:@"Error downloading server detectors" andDescription:@"Check that the wifi is enabled"];
//                [_activityIndicator stopAnimating];
//            });
//            
//        }else{
//            [document.managedObjectContext performBlock:^{
//                for(NSDictionary *detectorInfo in detectors){
//                    //start creating objects in document's context
//                    [Detector detectorWithDictionaryInfo:detectorInfo inManagedObjectContext:document.managedObjectContext];
//                }
//                
//                // when finished, present them on the screen and stop the activity indicator
//                [self performSelectorOnMainThread:@selector(setNumberOfDetectors) withObject:nil waitUntilDone:NO];
//                [self performSelectorOnMainThread:@selector(stopActivityIndicator) withObject:nil waitUntilDone:NO];
//            }];
//        }
//    });
//}


@end
