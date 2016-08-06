//
//  BBLPlayerView.m
//  Playbook
//
//  Created by Erin Hoops on 7/21/16.
//  Copyright © 2016 Erin Hoops. All rights reserved.
//

#import "BBLMarkerView.h"

@implementation BBLMarkerView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect hitBox = self.bounds;
    CGFloat dx = hitBox.size.width * -.3;
    CGFloat dy = hitBox.size.height * -.3;
    hitBox = CGRectInset(hitBox, dx, dy);
    if (CGRectContainsPoint(hitBox, point)) {
        return self;
    }
    return nil;
}

@end
