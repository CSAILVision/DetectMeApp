//
//  InputDetailsViewController.m
//  DetectTube
//
//  Created by Josep Marc Mingot Hidalgo on 20/09/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "InputDetailsViewController.h"
#import "TrainingViewController.h"


#define kIsPublic 0


@implementation InputDetailsViewController


- (void) viewDidAppear:(BOOL)animated
{
    // default initial value
    self.detectorTrainer.isPublic = NO;
    [self displayExplanatoryText];
}


- (void) displayExplanatoryText
{
    if(self.detectorTrainer.isPublic){
        self.textView.text = @"Public: this detector will be visible for all the other DetectMe users. They will be able to execute it and retrain it.";
    }else{
        self.textView.text = @"Private: you will be the only one with access to the detector.";
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Disable keyboard when the background is touched
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}


#pragma mark -
#pragma mark IBActions

- (IBAction)isPublicAction:(UISegmentedControl *)sender
{
    self.detectorTrainer.isPublic = sender.selectedSegmentIndex == kIsPublic ? YES : NO;
    [self displayExplanatoryText];
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
    // Add suggestion of a detector name to go faster training
    self.detectorTrainer.targetClass = textField.text;
    self.detectorTrainer.name = textField.text;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self performSegueWithIdentifier:@"showTraining" sender:self];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // limit the number of characters
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 25) ? NO : YES;
}

@end
