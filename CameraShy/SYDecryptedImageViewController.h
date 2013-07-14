//
//  SYDecryptedImageViewController.h
//  CameraShy
//
//  Created by Daniel DeCovnick on 7/14/13.
//  Copyright (c) 2013 Softyards Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYDecryptedImageViewController : UIViewController
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
- (IBAction)done:(id)sender;
@end
