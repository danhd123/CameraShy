//
//  SYMainViewController.m
//  CameraShy
//
//  Created by Daniel DeCovnick on 9/14/12.
//  Copyright (c) 2012 Softyards Software. All rights reserved.
//

#import "SYMainViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <Security/Security.h>
#import <CommonCrypto/CommonCryptor.h>
#import "NSData+Encryption.h"
#import <AWSS3/AWSS3.h>
#import <AWSRuntime/AWSRuntime.h>
#import "NSString+UUID.h"
#import "SYUserDefaults.h"

// Constants used to represent your AWS Credentials.

@interface SYMainViewController ()
@property (nonatomic, assign) BOOL isShowingCamera;
@property (assign, nonatomic, readwrite) int timeMultiplierFromMinutes;
@property (nonatomic, strong) UIViewController *r1Controller;
@property (nonatomic, strong) UIImage *pictureTook;
@property (nonatomic, strong) NSData *encryptedData;
@property (nonatomic, strong) AmazonS3Client *s3;
@end

static unsigned char kIV[128] = {
    41,  27,  123, 220, 203, 208, 44,  226, 230, 251, 194, 78,  121, 210, 5,   153,
    24,  148, 186, 91,  146, 48,  218, 130, 137, 3,   160, 83,  254, 18,  226, 139,
    226, 186, 148, 233, 165, 37,  41,  40,  33,  70,  63,  241, 18,  206, 192, 0,
    254, 201, 161, 185, 118, 44,  99,  4,   151, 33,  196, 71,  184, 91,  42,  208,
    132, 56,  167, 1,   229, 105, 153, 175, 61,  221, 93,  121, 158, 193, 223, 138,
    99,  62,  231, 153, 201, 196, 214, 94,  156, 33,  116, 36,  135, 244, 198, 155,
    43,  60,  152, 43,  38,  50,  100, 164, 60,  175, 238, 147, 146, 98,  85,  118,
    37,  223, 227, 68,  52,  175, 11,  139, 164, 99,  175, 54,  157, 30,  227, 220 };

@implementation SYMainViewController

- (void)viewDidLoad
{
    if (self.s3 == nil)
    {
        // Initial the S3 Client.
        self.s3 = [[AmazonS3Client alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
        self.s3.endpoint = [AmazonEndpoints s3Endpoint:US_WEST_2];
        
        // Create the picture bucket.
        S3CreateBucketRequest *createBucketRequest = [[S3CreateBucketRequest alloc] initWithName:[[[NSUserDefaults standardUserDefaults] stringForKey:SYUserDefaultsBucketName] lowercaseString]andRegion:[S3Region USWest2]];
        S3CreateBucketResponse *createBucketResponse = [self.s3 createBucket:createBucketRequest];
        if(createBucketResponse.error != nil)
        {
            NSLog(@"Error: %@", createBucketResponse.error);
        }
    }
    self.timeMultiplierFromMinutes = 1;
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewDidAppear:(BOOL)animated
{
    if (!self.isShowingCamera)
    {
        [self showCameraUI];
        self.isShowingCamera = YES;
    }
    else
    {
        self.isShowingCamera = NO;

    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (BOOL)startCameraControllerFromViewController:(UIViewController*)controller
                                  usingDelegate:(id <UIImagePickerControllerDelegate, 
                                                     UINavigationControllerDelegate>)delegate 
{
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera] == NO)
        || (delegate == nil)
        || (controller == nil))
    {
        return NO;
    }
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    
    cameraUI.delegate = delegate;
    
    [controller presentModalViewController: cameraUI animated: YES];
    return YES;
}

- (IBAction)showCameraUI 
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO)
    {
        return;
    }
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    
    cameraUI.delegate = self;
    
    [self presentViewController:cameraUI animated:YES completion:^{}];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker 
{    
    [self dismissViewControllerAnimated:YES completion:^{}];
}
- (void)imagePickerController:(UIImagePickerController *)picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info 
{
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;
    
    // Handle a still image capture
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) 
    {
        
        editedImage = (UIImage *)[info objectForKey:
                                   UIImagePickerControllerEditedImage];
        originalImage = (UIImage *)[info objectForKey:
                                     UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            imageToSave = editedImage;
        } else {
            imageToSave = originalImage;
        }
        self.pictureTook = imageToSave;

        [self dismissViewControllerAnimated:YES completion:^{
            self.r1Controller = [[R1PhotoEffectsSDK sharedManager] photoEffectsControllerForImage:imageToSave delegate:self cropSupport:YES];
            [self presentViewController:self.r1Controller animated:YES completion:nil];

        }];
        // Save the new image (original or edited) to the Camera Roll
        //UIImageWriteToSavedPhotosAlbum (imageToSave, nil, nil , nil);
//        NSData *dataToEncrypt = UIImageJPEGRepresentation(imageToSave, 1.0);
//        NSString *password = @"My cat's breath smells like cat food"; // this is proof of concept 
//        NSData *iv = [NSData dataWithBytesNoCopy:kIV length:128 freeWhenDone:NO];
//        NSData *salt = nil;
//        NSError *error = nil;
//        NSData *encryptedData = [NSData encryptedDataForData:dataToEncrypt password:password iv:&iv salt:&salt error:&error];
//        NSLog(@"salt: %@", salt);
//        NSLog(@"iv: %@", iv);
        
    }    
    //[self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - R1PhotoEffectsViewControllerDelegate
- (void)photoEffectsEditingViewController:(R1PhotoEffectsEditingViewController *)controller didFinishWithImage:(UIImage *)image
{
    self.pictureTook = image;
    self.isShowingCamera = YES;
    

    //Dismiss the editor
    [self dismissViewControllerAnimated:YES completion:
     ^{
         self.r1Controller = nil;
     }];
}
- (void)photoEffectsEditingViewControllerDidCancel:(R1PhotoEffectsEditingViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Buttons
- (IBAction)encryptAndUpload:(id)sender
{
    [self.passwordField resignFirstResponder];
    [self.timeField resignFirstResponder];
    NSData *dataToEncrypt = UIImageJPEGRepresentation(self.pictureTook, 1.0);
    NSString *password = self.passwordField.text;
    NSData *iv = nil;
    NSString *fileName = nil;

    if ([NSUUID class] != nil)
    {
        NSUUID *uuid = [NSUUID UUID];
        uuid_t bytes;
        [uuid getUUIDBytes:bytes];
        iv = [NSData dataWithBytesNoCopy:bytes length:16 freeWhenDone:NO];
        //doesn't actually matter if this gets bigger - IV needs to be 128 bits.
        fileName = [[NSString stringWithFormat:@"%@.dat", uuid.UUIDString] lowercaseString];
    }
    else
    {
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        CFUUIDBytes bytesStruct = CFUUIDGetUUIDBytes(uuid);
        iv = [NSData dataWithBytesNoCopy:&bytesStruct length:16 freeWhenDone:NO];
        CFStringRef uuidStr = CFUUIDCreateString(NULL, uuid);
        fileName = [[NSString stringWithFormat:@"%@.dat", (__bridge NSString *)uuidStr] lowercaseString];
        CFRelease(uuidStr);
        CFRelease(uuid);
        
    }

    NSData *salt = [NSData dataWithBytes:"CamraShy" length:8];
    NSError *error = nil;
    self.encryptedData = [NSData encryptedDataForData:dataToEncrypt password:password iv:&iv salt:&salt error:&error];
    NSLog(@"salt: %@", salt);
    NSLog(@"iv: %@", iv);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue,
    ^{
        // Upload image data.  Remember to set the content type.
        S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:fileName
                                                                  inBucket:[[[NSUserDefaults standardUserDefaults] stringForKey:SYUserDefaultsBucketName] lowercaseString]];
        por.contentType = @"application/octet-stream";
        por.data        = self.encryptedData;
        
        // Put the image data into the specified s3 bucket and object.
        S3PutObjectResponse *putObjectResponse = [self.s3 putObject:por];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(putObjectResponse.error != nil)
            {
                NSLog(@"Error: %@", putObjectResponse.error);
                [self showAlertMessage:[putObjectResponse.error.userInfo objectForKey:@"message"] withTitle:@"Upload Error"];
            }
            else
            {
                [self fetchSignedURLForFile:fileName];
                [self showAlertMessage:@"The image was successfully uploaded. Your URL will appear shortly." withTitle:@"Upload Completed"];
                
            }
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
    });
}

- (IBAction)changeTimeUnit:(id)sender
{
    switch (self.timeMultiplierFromMinutes)
    {
        case 1:
            self.timeMultiplierFromMinutes = 60;
            [self.timeUnitButton setTitle:NSLocalizedString(@"Hours", 0) forState:UIControlStateNormal];
            [self.timeUnitButton setTitle:NSLocalizedString(@"Hours", 0) forState:UIControlStateHighlighted];
            break;
        case 60:
            self.timeMultiplierFromMinutes = 1440;
            [self.timeUnitButton setTitle:NSLocalizedString(@"Days", 0) forState:UIControlStateNormal];
            [self.timeUnitButton setTitle:NSLocalizedString(@"Days", 0) forState:UIControlStateHighlighted];
            break;
        case 1440:
            self.timeMultiplierFromMinutes = 10800;
            [self.timeUnitButton setTitle:NSLocalizedString(@"Weeks", 0) forState:UIControlStateNormal];
            [self.timeUnitButton setTitle:NSLocalizedString(@"Weeks", 0) forState:UIControlStateHighlighted];
            break;
        case 10800:
            self.timeMultiplierFromMinutes = 525600;
            [self.timeUnitButton setTitle:NSLocalizedString(@"Years", 0) forState:UIControlStateNormal];
            [self.timeUnitButton setTitle:NSLocalizedString(@"Years", 0) forState:UIControlStateHighlighted];
            break;
        case 525600:
        default:
            self.timeMultiplierFromMinutes = 1;
            [self.timeUnitButton setTitle:NSLocalizedString(@"Minutes", 0) forState:UIControlStateNormal];
            [self.timeUnitButton setTitle:NSLocalizedString(@"Minutes", 0) forState:UIControlStateHighlighted];
            break;
    }
}

#pragma mark - helper
- (void)showAlertMessage:(NSString *)message withTitle:(NSString *)title
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                         message:message
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
    [alertView show];
}
- (void)fetchSignedURLForFile:(NSString *)fileName
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue,
    ^{
        
        S3ResponseHeaderOverrides *override = [[S3ResponseHeaderOverrides alloc] init];
        
        // Request a pre-signed URL to picture that has been uplaoded.
        S3GetPreSignedURLRequest *gpsur = [[S3GetPreSignedURLRequest alloc] init];
        gpsur.key = fileName;
        gpsur.bucket = [[[NSUserDefaults standardUserDefaults] stringForKey:SYUserDefaultsBucketName] lowercaseString]; //I should probably just have set this initially
        if ([self.timeField.text intValue] > 0)
        {
            gpsur.expires = [NSDate dateWithTimeIntervalSinceNow:[self.timeField.text intValue] * self.timeMultiplierFromMinutes * 60];
        }
        else
        {
            gpsur.expires = [NSDate distantFuture];
        }
        gpsur.responseHeaderOverrides = override;
        
        // Get the URL
        NSError *error;
        NSURL *url = [self.s3 getPreSignedURL:gpsur error:&error];
        
        if(url == nil)
        {
            if(error != nil)
            {
                dispatch_async(dispatch_get_main_queue(),
                ^{
                    
                    NSLog(@"Error: %@", error);
                    [self showAlertMessage:[error.userInfo objectForKey:@"message"] withTitle:@"Browser Error"];
                });
            }
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(),
            ^{
                // Display the URL in Safari
                self.urlView.text = [url absoluteString];
            });
        }
        
    });

}

#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(SYFlipsideViewController *)controller
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissModalViewControllerAnimated:YES];
    } else {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.flipsidePopoverController = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            UIPopoverController *popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
            self.flipsidePopoverController = popoverController;
            popoverController.delegate = self;
        }
    }
}

- (IBAction)togglePopover:(id)sender
{
    if (self.flipsidePopoverController) {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    } else {
        [self performSegueWithIdentifier:@"showAlternate" sender:sender];
    }
}

@end
