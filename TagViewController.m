//
//  AnnotationToolViewController.m
//  AnnotationTool
//
//  Created by Dolores Blanco Almazán on 31/03/12.
//  Updated by Josep Marc Mingot.
//  Copyright 2012 CSAIL. All rights reserved.
//

#import "TagViewController.h"

#define kLabelsViewRowHeight 30
#define kTipWidth 250

@interface TagViewController()
{

    BOOL _isBoxSelected;
    BOOL _isZoomIn;
    
    NSMutableSet *_recentLabels; //buffer with the recent labels for keyboard word suggestion
}



// Save thumbnail and boxes
// Notify the delegate to reload
- (void) saveStateOnDisk;

// Just enable the scroll of pages in the infinite loop if: (1) no box selected and (2) not zoom in
- (void) updateScrollPersmission;

@end


@implementation TagViewController

#pragma mark -
#pragma mark Initialization

- (void) initializeBottomToolbar
{
    [self.bottomToolbar setBarStyle:UIBarStyleBlackOpaque];
    
    UIButton *addButtonView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.bottomToolbar.frame.size.height,  self.bottomToolbar.frame.size.height)];
    [addButtonView setImage:[UIImage imageNamed:@"newLabel.png"] forState:UIControlStateNormal];
    //[addButtonView addTarget:self action:@selector(addAction:) forControlEvents:UIControlEventTouchUpInside];
    self.addButton.customView = addButtonView;
    
    UIButton *deleteButtonView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.bottomToolbar.frame.size.height,  self.bottomToolbar.frame.size.height)];
    [deleteButtonView setImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal];
    //[deleteButtonView addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
    self.deleteButton.customView = deleteButtonView;
    [self.deleteButton setEnabled:NO];
    [self.deleteButton setStyle:UIBarButtonItemStyleBordered];
    
    UIButton *sendButtonView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.bottomToolbar.frame.size.height,self.bottomToolbar.frame.size.height)];
    [sendButtonView setImage:[UIImage imageNamed:@"send.png"] forState:UIControlStateNormal];
    //[sendButtonView addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchUpInside];
    self.sendButton.customView = sendButtonView;
}




- (void) initializeLabelsSet
{
//    _recentLabels = [NSMutableSet setWithArray:[_labelsResourceHandler getClassesNames]];
    if(_recentLabels==nil) _recentLabels = [[NSMutableSet alloc] init];
}

#pragma mark -
#pragma mark View Life Cycle



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //load and setup other window views
    [self initializeBottomToolbar];
    self.infiniteLoopView.delegate = self;
    self.infiniteLoopView.dataSource = self;
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    //register for notifications if box is selected
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isBoxSelected:) name:@"isBoxSelected" object:nil];

    //scroll initialization
    dispatch_async(dispatch_get_main_queue(), ^{
        [self initializeLabelsSet];
        [self.infiniteLoopView initializeAtIndex:self.currentIndex];
    });
}


- (void) viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
    //save thumbnail and dictionary
    [self saveStateOnDisk];
    
    [self.infiniteLoopView reset];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



#pragma mark -
#pragma mark TagViewDelegate Methods

-(void)objectModified
{
//    // if the box was sent, update 
//    Box *selectedBox = [self.tagImageView.tagView getSelectedBox];
//    [_recentLabels addObject:selectedBox.label];
//    if(selectedBox && selectedBox.sent){
//        selectedBox.sent = NO;
//        self.labelsResourceHandler.boxesNotSent ++;
//    }
//    
//    [self saveStateOnDisk];
}


#pragma mark -
#pragma mark NSNotificationCenter Messages

-(void)isBoxSelected:(NSNotification *) notification
{
    
    NSNumber *isSelected = [notification object];

    _isBoxSelected = isSelected.boolValue;
    [self updateScrollPersmission];
    
//    [self.labelsView reloadData];
}



#pragma mark -
#pragma mark InfiniteLoopDelegate & InfiniteLoopDataSource

- (UIView *) viewForIndex:(int)index
{
    //construct the view
    TagImageView *requestedView = [[TagImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
    requestedView.image = [self.images objectAtIndex:index];
    requestedView.tagView.box = [self.boxes objectAtIndex:index];
    
    return requestedView;
}

- (int) numberOfViews
{
    return self.images.count;
}

- (void) didShowView:(UIView *)view forIndex:(int)currentIndex;
{    
    //title
    self.title = [NSString stringWithFormat:@"%d of %d", currentIndex + 1, self.images.count];
    
    //hook current view with the delegate
    self.tagImageView = (TagImageView *)view;
    self.tagImageView.delegate = self;
    [self.tagImageView reloadForRotation];
    
    
    [self.view setNeedsDisplay];
}


#pragma mark -
#pragma mark KeyboardHandlerDataSource

- (NSArray *) arrayOfWords
{
    //returns the list of the recent labels buffered in this session
    return _recentLabels.allObjects;
}


#pragma mark -
#pragma mark TagImageViewDelegate

- (void) scrollDidEndZoomingAtScale:(float) scale
{
    _isZoomIn = scale!=1 ? YES:NO;
    [self updateScrollPersmission];
}

#pragma mark -
#pragma mark Rotation

- (void)willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
    [self.tagImageView reloadForRotation];
    
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}


#pragma mark -
#pragma mark Private methods

- (void) saveStateOnDisk
{
    [self.delegate reloadTable];
}

- (void) updateScrollPersmission
{
    if(!_isBoxSelected && !_isZoomIn) [self.infiniteLoopView disableScrolling:NO];
    else [self.infiniteLoopView disableScrolling:YES];
}

-(void)barButtonsEnabled:(BOOL)value
{
    [self.addButton setEnabled:value];
    [self.sendButton setEnabled:value];
    [self.deleteButton setEnabled:value];
    [self.navigationItem setHidesBackButton:!value];
}


@end
