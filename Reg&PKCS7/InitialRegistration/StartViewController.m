//
//  StartViewController.m
//  Reg&PKCS7
//
//  Created by VADIM KASSIN on 2/3/16.
//  Copyright © 2016 Gamma Technologies Research Laboratory LLP. All rights reserved.
//

#import "StartViewController.h"
#import "GTViewController1.h"
#import "GTViewController.h"

@interface StartViewController () {
    
    GTViewController1 *aViewController;
    GTViewController *bViewController;
}

@property (retain, nonatomic) IBOutlet UIButton *firstButton;

@end

@implementation StartViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self.firstButton.titleLabel setTextAlignment: NSTextAlignmentCenter];
    
    aViewController = [[GTViewController1 alloc] initWithNibName:@"GTViewController1" bundle:nil];
    bViewController = [[GTViewController alloc] initWithNibName:@"GTViewController" bundle:nil];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)firstButtonClicked:(id)sender {

    [self.view addSubview:aViewController.view];
}

- (IBAction)secondButtonClicked:(id)sender {
    
    [self.view addSubview:bViewController.view];
}

- (void)dealloc {
    
    [_firstButton release];
    [aViewController release];
    [bViewController release];

    [super dealloc];
}
@end
