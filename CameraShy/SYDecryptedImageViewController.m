//
//  SYDecryptedImageViewController.m
//  CameraShy
//
//  Created by Daniel DeCovnick on 7/14/13.
//  Copyright (c) 2013 Softyards Software. All rights reserved.
//

#import "SYDecryptedImageViewController.h"

@interface SYDecryptedImageViewController ()

@end

@implementation SYDecryptedImageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)done:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}
@end
