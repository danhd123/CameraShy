//
//  R1PhotoEffectsSDK.h
//  EffectsSDK
//
//  Created by Drew Colace on 3/6/13.
//  Copyright (c) 2013 RadiumOne. All rights reserved.
//

#import "R1PhotoEffectsController.h"
#import <CoreLocation/CoreLocation.h>

@interface R1PhotoEffectsSDK : NSObject

+ (id)sharedManager;

- (void)enableWithClientID:(NSString *)clientID;

- (R1PhotoEffectsController *)photoEffectsControllerForImage:(UIImage *)image delegate:(id<R1PhotoEffectsEditingViewControllerDelegate>)delegate cropSupport:(BOOL)cropping;

- (void)pushPhotoEffectsControllerOnNavigationController:(UINavigationController *)navController forImage:(UIImage *)image delegate:(id<R1PhotoEffectsEditingViewControllerDelegate>)delegate cropSupport:(BOOL)cropping;


//Optionally report user location
- (void)setLocation:(CLLocationCoordinate2D)location;

//Optionaly report demographic data
- (void)setDemographicData:(NSDictionary *)demographicData;

- (NSString *)sdkVersion;

@end
