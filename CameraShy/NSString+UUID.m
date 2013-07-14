//
//  NSString+UUID.m
//  CameraShy
//
//  Created by Daniel DeCovnick on 7/14/13.
//  Copyright (c) 2013 Softyards Software. All rights reserved.
//

#import "NSString+UUID.h"

@implementation NSString (UUID)
+ (NSString *)generatedNewUUID;
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)string;
}
@end
