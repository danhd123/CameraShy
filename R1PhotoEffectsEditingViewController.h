//
//  R1PhotoEffectsEditingViewController.h
//  EffectsSDK
//
//  Created by Drew Colace on 3/8/13.
//  Copyright (c) 2013 RadiumOne, Inc. All rights reserved.
//

@class R1PhotoEffectsEditingViewController;

@protocol R1PhotoEffectsEditingViewControllerDelegate <NSObject>

@required

- (void)photoEffectsEditingViewController:(R1PhotoEffectsEditingViewController *)controller didFinishWithImage:(UIImage *)image;

- (void)photoEffectsEditingViewControllerDidCancel:(R1PhotoEffectsEditingViewController *)controller;

@end


@interface R1PhotoEffectsEditingViewController : UIViewController
{
  UIImage *_sourceImage;
}

@property (nonatomic, assign) id<R1PhotoEffectsEditingViewControllerDelegate> delegate;
@property (nonatomic, retain) UIImage *sourceImage;

@end
