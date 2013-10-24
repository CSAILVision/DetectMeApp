//
//  DetailMultipleViewController.m
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 23/10/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "DetailMultipleViewController.h"
#import "Detector.h"
#import "ManagedDocumentHelper.h"

@interface DetailMultipleViewController ()
{
    UIManagedDocument *_detectorDatabase;
}
@end

@implementation DetailMultipleViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    if(!_detectorDatabase)
        _detectorDatabase = [ManagedDocumentHelper sharedDatabaseUsingBlock:^(UIManagedDocument *document) {}];
    
    self.imageView.image = [UIImage imageWithData:self.multipleDetector.image];
    
    NSString *text = @"Detectors:";
    for(Detector *detector in self.multipleDetector.detectors)
        text = [text stringByAppendingString:[NSString stringWithFormat:@" - %@", detector.name]];
    
    self.textView.text = text;
}

#pragma mark -
#pragma mark IActions

- (IBAction)deleteAction:(id)sender
{
    [_detectorDatabase.managedObjectContext deleteObject:self.multipleDetector];
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Segue


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ExecuteDetectorMultiple"]) {
        NSArray *detectors = [self.multipleDetector.detectors allObjects];
        [(ExecuteDetectorViewController *)segue.destinationViewController setDetectors:detectors];
        
    }
}

@end
