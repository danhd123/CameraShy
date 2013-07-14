//
//  SYMainViewController.h
//  CameraShy
//
//  Created by Daniel DeCovnick on 9/14/12.
//  Copyright (c) 2012 Softyards Software. All rights reserved.
//

#import "SYFlipsideViewController.h"

@interface SYMainViewController : UIViewController <SYFlipsideViewControllerDelegate, UIPopoverControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, R1PhotoEffectsEditingViewControllerDelegate>
@property (assign, nonatomic, readonly) int timeMultiplierFromMinutes;
@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;
@property (weak, nonatomic) IBOutlet UITextField *timeField;
@property (weak, nonatomic) IBOutlet UIButton *timeUnitButton;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *encryptButton;
@property (weak, nonatomic) IBOutlet UITextView *urlView;
- (IBAction)encryptAndUpload:(id)sender;
- (IBAction)changeTimeUnit:(id)sender;
- (IBAction)showCameraUI;
@end
