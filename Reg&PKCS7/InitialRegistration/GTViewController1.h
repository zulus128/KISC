//
//  GTViewController.h
//  InitialRegistration
//
//  Created by renat.karimov on 2/14/13.
//  Copyright (c) 2013 Gamma Technologies Research Laboratory LLP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GTViewController1 : UIViewController

@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;

@property (retain, nonatomic) IBOutlet UITextView *textViewTask;

@property (retain, nonatomic) IBOutlet UITextField *textFieldUserIdentifier;

@property (retain, nonatomic) IBOutlet UITextField *textFieldSecret;

@property (retain, nonatomic) IBOutlet UIButton *buttonExecute;
@property (retain, nonatomic) IBOutlet UIButton *buttonClose;

- (IBAction)execute:(id)sender;

@property (retain, nonatomic) IBOutlet UITextView *textViewLog;

- (void)keyboardDidShow:(NSNotification *)note;

- (void)keyboardDidHide:(NSNotification *)note;

@end
