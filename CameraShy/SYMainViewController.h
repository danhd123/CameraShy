//
//  SYMainViewController.h
//  CameraShy
//
//  Created by Daniel DeCovnick on 9/14/12.
//  Copyright (c) 2012 Softyards Software. All rights reserved.
//

#import "SYFlipsideViewController.h"

@interface SYMainViewController : UIViewController <SYFlipsideViewControllerDelegate, UIPopoverControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;

@end
