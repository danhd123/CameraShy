//
//  SYFlipsideViewController.h
//  CameraShy
//
//  Created by Daniel DeCovnick on 9/14/12.
//  Copyright (c) 2012 Softyards Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SYFlipsideViewController;

@protocol SYFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(SYFlipsideViewController *)controller;
@end

@interface SYFlipsideViewController : UIViewController

@property (weak, nonatomic) id <SYFlipsideViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;

@end
