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

- (void)setStart:(CGPoint)start {
    _start = start;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    //Get the CGContext from this view
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //Set the stroke (pen) color
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    //Set the width of the pen mark
    CGContextSetLineWidth(context, 5.0);
    
    // Draw a line
    //Start at this point
    CGContextMoveToPoint(context, _start.x, _start.y);
    
    //Give instructions to the CGContext
    //(move "pen" around the screen)
    CGContextAddLineToPoint(context, 310.0, 30.0);
    CGContextAddLineToPoint(context, 310.0, 90.0);
    CGContextAddLineToPoint(context, 10.0, 90.0);
    
    //Draw it
    CGContextStrokePath(context);
}


@end
