//
//  BBLDataModel.h
//  Playbook
//
//  Created by Erin Hoops on 7/21/16.
//  Copyright © 2016 Erin Hoops. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BBLMarkerView;

#pragma mark markerData

@interface BBLMarkerData : NSObject

@property (nonatomic, strong) BBLMarkerView *view;
@property (nonatomic, assign) CGPoint markerPosition;
@property (nonatomic, assign) CGPoint markerPositionDelta;
@property (nonatomic, assign) CGSize markerSize;
@property (nonatomic, copy) UIColor *color;
@property (nonatomic, assign) int team;

@end


@interface BBLSnapshot : NSObject <NSCoding>

@property (nonatomic, copy) NSArray *snapPositions;
@property (nonatomic, copy) NSArray *snapPath;

@end



@interface BBLPlay : NSObject <NSCoding>

@property (nonatomic, copy) NSArray<BBLSnapshot *> *playSteps;

@end