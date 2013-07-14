//
//  SYFlipsideViewController.m
//  CameraShy
//
//  Created by Daniel DeCovnick on 9/14/12.
//  Copyright (c) 2012 Softyards Software. All rights reserved.
//

#import "SYFlipsideViewController.h"
#import "NSData+Encryption.h"
#import "SYDecryptedImageViewController.h"

@interface SYFlipsideViewController ()

@end

@implementation SYFlipsideViewController

@synthesize delegate = _delegate;

- (void)awakeFromNib
{
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 480.0);
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}

#pragma mark - storyboard
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (![[segue identifier] isEqualToString:@"decryptAndView"])
    {
        return;
    }
    [self.passwordField resignFirstResponder];
    [self.urlField resignFirstResponder];
    NSURL *url = [NSURL URLWithString:[self.urlField text]];
    NSData *dataToDecrypt = [NSData dataWithContentsOfURL:url];
    //horrible evilness. never do this
    NSString *path = [url path];
    NSString *ivString = [path substringWithRange:NSMakeRange(1, [path length] - 5)];
    CFUUIDRef uuid = CFUUIDCreateFromString(NULL, (__bridge CFStringRef)ivString);
    CFUUIDBytes uuidBytes = CFUUIDGetUUIDBytes(uuid);
    NSData *iv = [NSData dataWithBytesNoCopy:&uuidBytes length:16 freeWhenDone:NO];
    NSData *salt = [NSData dataWithBytes:"CamraShy" length:8];
    NSString *password = [self.passwordField text];
    NSError *error = nil;
    NSData *decryptedData = [NSData decryptedDataForData:dataToDecrypt password:password iv:iv salt:salt error:&error];
    if (error != nil)
    {
        NSLog(@"Error decrypting: %@", error);
    }
    UIImage *decryptedImage = [UIImage imageWithData:decryptedData];
    SYDecryptedImageViewController *vc = [segue destinationViewController];
    (void)vc.view;
    vc.imageView.image = decryptedImage;
    
}
@end
