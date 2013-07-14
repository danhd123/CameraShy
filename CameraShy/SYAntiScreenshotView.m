//
//  SYAntiScreenshotView.m
//  CameraShy
//
//  Created by Daniel DeCovnick on 7/14/13.
//  Copyright (c) 2013 Softyards Software. All rights reserved.
//

#import "SYAntiScreenshotView.h"

@implementation SYAntiScreenshotView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self addSubview:self.imageView];
    [super touchesBegan:touches withEvent:event];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.imageView removeFromSuperview];
    [super touchesEnded:touches withEvent:event];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.imageView removeFromSuperview];
    [super touchesCancelled:touches withEvent:event];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
