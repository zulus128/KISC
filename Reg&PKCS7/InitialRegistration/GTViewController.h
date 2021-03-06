//
//  GTViewController.h
//  PKCS7
//
//  Created by renat.karimov on 2/14/13.
//  Copyright (c) 2013 Gamma Technologies Research Laboratory LLP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface GTViewController : UIViewController <MFMailComposeViewControllerDelegate>

@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;

@property (retain, nonatomic) IBOutlet UITextView *textViewTask;

@property (retain, nonatomic) IBOutlet UISegmentedControl *segmentedControlSignatureType;

@property (retain, nonatomic) IBOutlet UITextField *textFieldDataForPKCS7;

@property (retain, nonatomic) IBOutlet UIButton *buttonExecute;
@property (retain, nonatomic) IBOutlet UIButton *buttonClose;
@property (retain, nonatomic) IBOutlet UIButton *buttonSend;

- (IBAction)execute:(id)sender;

@property (retain, nonatomic) IBOutlet UITextView *textViewLog;

- (void)keyboardDidShow:(NSNotification *)note;

- (void)keyboardDidHide:(NSNotification *)note;

@end
