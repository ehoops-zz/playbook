//
//  BBLArrowView.m
//  Playbook
//
//  Created by Erin Hoops on 7/25/16.
//  Copyright © 2016 Erin Hoops. All rights reserved.
//

#import "BBLArrowView.h"

@implementation BBLArrowView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
    }
    return self;
}

- (void)setPathPoints:(NSArray *)pathPoints {
    _pathPoints = [pathPoints copy];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    //Get the CGContext from this view
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //Set the stroke (pen) color
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    //Set the width of the pen mark
    CGContextSetLineWidth(context, 5.0);
    
    if (_pathPoints.count == 0) {
        return;
    }
    
    // Draw a line
    //Start at this point
    CGPoint start = [_pathPoints[0] CGPointValue];
    CGContextMoveToPoint(context, start.x, start.y);
    
    //Give instructions to the CGContext
    //(move "pen" around the screen)
    for (NSUInteger i = 1; i < _pathPoints.count; i++) {
        CGPoint point = [_pathPoints[i] CGPointValue];
        CGContextAddLineToPoint(context, point.x, point.y);
    }
    
    //Draw it
    CGContextStrokePath(context);
}


@end
