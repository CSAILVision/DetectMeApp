//
//  DetailViewController.m
//  DetectTube
//
//  Created by Josep Marc Mingot Hidalgo on 25/09/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "DetailViewController.h"
#import "ExecuteDetectorViewController.h"
#import "TrainingImagesCollectionViewController.h"
#import "AnnotatedImage.h"
#import "Box.h"

@interface DetailViewController ()
{
}

@end

@implementation DetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.detector.name;
    self.imageView.image =[UIImage imageWithData:self.detector.image];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ExecuteDetector"]) {
        [(ExecuteDetectorViewController *)segue.destinationViewController setDetector:self.detector];
        
    }else if([[segue identifier] isEqualToString:@"Retrain"]){
        TrainingImagesCollectionViewController *vc = (TrainingImagesCollectionViewController *)segue.destinationViewController;
        vc.detector = self.detector;
    }
}

#pragma mark -
#pragma mark IBActions

- (IBAction)deleteAction:(id)sender
{
    [self.delegate deleteDetector:self.detector];
    [self.navigationController popViewControllerAnimated:YES];
}


@end
