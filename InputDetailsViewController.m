//
//  InputDetailsViewController.m
//  DetectTube
//
//  Created by Josep Marc Mingot Hidalgo on 20/09/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "InputDetailsViewController.h"
#import "TrainingViewController.h"


#define kClass @"Class"
#define kName @"Name"
#define kIsPublic 0


@implementation InputDetailsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Disable keyboard when the background is touched
    NSLog(@"touchesBegan:withEvent:");
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}


#pragma mark -
#pragma mark IBActions

- (IBAction)isPublicAction:(UISegmentedControl *)sender
{
    self.detectorTrainer.isPublic = sender.selectedSegmentIndex == kIsPublic ? YES : NO;
    NSLog(@"bullshit");
}

#pragma mark -
#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showTraining"]) {
        
        TrainingViewController *destinationVC = (TrainingViewController *)segue.destinationViewController;
        destinationVC.detectorTrainer = self.detectorTrainer;
    }
}

#pragma mark -
#pragma mark UITextFieldDelegate


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
    if ([textField.placeholder isEqualToString:kName])
        self.detectorTrainer.name = textField.text;
    else if([textField.placeholder isEqualToString:kClass])
        self.detectorTrainer.targetClass = textField.text;

}

@end
