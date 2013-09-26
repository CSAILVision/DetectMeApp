//
//  KeyboardHandler.m
//  LabelMe
//
//  Created by Josep Marc Mingot Hidalgo on 01/08/13.
//  Copyright (c) 2013 CSAIL. All rights reserved.
//

#import "KeyboardHandler.h"

#define kOFFSET_FOR_KEYBOARD 10.0
#define kToolbarWidth 44


@interface KeyboardHandler()
{
    UITextField *_textField;
    BOOL _moved;
    int _difference;
    UIToolbar *_toolbar; //word suggestion
}

@end


@implementation KeyboardHandler

#pragma mark -
#pragma mark Initialization

- (id)initWithTextField:(UITextField *)textField;
{
    if (self = [super init]) {
        _textField = textField;
        
        //toolbar for word suggestion
        _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kToolbarWidth)];
        _toolbar.barStyle = UIBarStyleBlackOpaque;
        _textField.inputAccessoryView = _toolbar;

        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(keyPressed:) name: UITextFieldTextDidChangeNotification object: nil];
    }
    return self;
}


- (void) setTextField:(UITextField *)textField
{
    _textField = textField;
    _textField.inputAccessoryView = _toolbar;
}

- (void)dealloc
{
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark -
#pragma mark Moving view

-(void)keyboardWillShow:(NSNotification *)notification
{
    // get the coordinates of the keyboard
    CGRect keyboardRect =[[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    
    // get the absolute coordinates of the view (inside UIWindow)
    CGRect absoluteOriginRect = [_textField convertRect:_textField.bounds toView:nil];
    
    CGSize windowSize = [UIScreen mainScreen].bounds.size;
    CGFloat keyboardOrigin = windowSize.height - keyboardRect.size.height;
    CGFloat labelEnd = absoluteOriginRect.origin.y + absoluteOriginRect.size.height;
    
    // when rotating, the coordinate system also rotates!
    if (UIInterfaceOrientationIsLandscape([[UIDevice currentDevice] orientation])){
        keyboardOrigin = windowSize.width - keyboardRect.size.width;
        labelEnd = windowSize.width - absoluteOriginRect.origin.x;
    }
    
    //    NSLog(@"*******************************************");
    //    NSLog(@"window size: %@", NSStringFromCGSize(windowSize));
    //    NSLog(@"keyboard rect: %@", NSStringFromCGRect(keyboardRect));
    //    NSLog(@"label rect: %@", NSStringFromCGRect(absoluteOriginRect));
    //    NSLog(@"computed keyboardOrigin: %f", keyboardOrigin);
    //    NSLog(@"computed labelEnd: %f", labelEnd);
    
    _difference = keyboardOrigin - labelEnd - kOFFSET_FOR_KEYBOARD;
    
    if (_difference < 0)
    {
        [self moveUp:YES];
        _moved = YES;
    }
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    // undo the move it the keyboard was hiding
    if (_moved) [self moveUp:NO];
}

- (void) moveUp:(BOOL)moveup
{
    // animate the sequence
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    CGRect rect = _textField.frame;
    if(moveup) rect.origin.y += _difference;
    else rect.origin.y -= _difference;
    
    _textField.frame = rect;
    [UIView commitAnimations];
}


#pragma mark -
#pragma mark Word suggestion

-(void) keyPressed:(NSNotification *) notification
{
    
    UITextField *t = (UITextField *)[notification object];
    
    NSArray *words = [self.dataSource arrayOfWords];
    NSMutableArray *toolbarSuggestions = [[NSMutableArray alloc] initWithCapacity:words.count];
    
    for (NSString* word in words)
        if ([word hasPrefix:t.text])
            [toolbarSuggestions addObject:[[UIBarButtonItem alloc]initWithTitle:word style:UIBarButtonItemStyleBordered target:self action:@selector(setTextFieldText:)]];
    
    _toolbar.items = [NSArray arrayWithArray:toolbarSuggestions];
}

- (IBAction)setTextFieldText:(id)sender
{
    _textField.text = [(UIBarButtonItem *)sender title];
    
}


@end




