//
//  ViewController.m
//  Playbook
//
//  Created by Erin Hoops on 7/21/16.
//  Copyright © 2016 Erin Hoops. All rights reserved.
//

#import "ViewController.h"
#import "BBLMarkerView.h"
#import "BBLArrowView.h"

@interface BBLMarkerData : NSObject

@property (nonatomic, strong) BBLMarkerView *view;
@property (nonatomic, assign) CGPoint markerPosition;
@property (nonatomic, assign) CGPoint markerPositionDelta;
@property (nonatomic, assign) CGSize markerSize;
@property (nonatomic, copy) UIColor *color;

@end

@interface BBLSnapshot : NSObject

@property (nonatomic, copy) NSArray *resetPositions;

@end

@implementation BBLSnapshot

- (instancetype)init {
    if(self=[super init]) {
        _resetPositions = [[NSArray alloc] init];
    }
    return self;
}
@end


@implementation BBLMarkerData

- (instancetype)init {
    if(self=[super init]) {
        _view = [[BBLMarkerView alloc] initWithFrame:CGRectZero];
    }
    return self;
}

- (void)setColor:(UIColor *)color {
    _view.backgroundColor = color;
}

- (UIColor *)color {
    return _view.backgroundColor;
}

@end

@interface ViewController ()

@end

@implementation ViewController {
    UIImageView *_courtView;
    NSArray<BBLMarkerData *> *_markers;
    BBLArrowView *_arrowView;
    NSMutableArray *_pathPoints;
    BBLSnapshot *_snapshot;
    UIButton *_resetButton;
    UIButton *_saveStartButton;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Setup background
    _courtView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"court"]];
    _courtView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_courtView];
    self.view.backgroundColor = [UIColor whiteColor];

    // Setup Arrow layer
    CGRect bounds = self.view.bounds;
    _pathPoints = [NSMutableArray new];
    _arrowView = [[BBLArrowView alloc] initWithFrame:bounds];
    [self.view addSubview:_arrowView];
    
    // Setup buttons
    // Reset Button
    _resetButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_resetButton setTitle:@"Reset" forState:UIControlStateNormal];
    [_resetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_resetButton.titleLabel setFont:[UIFont systemFontOfSize:48]];
    _resetButton.backgroundColor = [UIColor grayColor];
    [_resetButton addTarget:self action:@selector(_resetButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_resetButton];
    
    // Save Starting Position Button
    _saveStartButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_saveStartButton setTitle:@"Save" forState:UIControlStateNormal];
    [_saveStartButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_saveStartButton.titleLabel setFont:[UIFont systemFontOfSize:48]];
    _saveStartButton.backgroundColor = [UIColor grayColor];
    [_saveStartButton addTarget:self action:@selector(_saveStartButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_saveStartButton];
    
    
    // Setup Player and Ball markers
    NSMutableArray *markers = [NSMutableArray new];
    
    for (int i=0; i < 5; i++) {
        BBLMarkerData *marker = [self _createMarkerWithColor:[UIColor redColor] position:CGPointMake(CGRectGetMidX(bounds) - i * 50 + 100, CGRectGetMidY(bounds) - 150) size:CGSizeMake(35, 35)];
        [markers addObject:marker];
    }
    for (int i=0; i < 5; i++) {
        BBLMarkerData *marker = [self _createMarkerWithColor:[UIColor blueColor] position:CGPointMake(CGRectGetMidX(bounds) - i * 50 + 100, CGRectGetMidY(bounds) - 75) size:CGSizeMake(35, 35)];
        [markers addObject:marker];
    }
    
    BBLMarkerData *marker = [self _createMarkerWithColor:[UIColor brownColor] position:CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds)) size:CGSizeMake(25, 25)];
    [markers addObject:marker];

    _markers = [markers copy];
    
    [self _saveSnapshot];
}

- (BBLMarkerData *)_createMarkerWithColor:(UIColor *)color position:(CGPoint)position size:(CGSize)size {
    BBLMarkerData *marker = [[BBLMarkerData alloc] init];
    [self.view addSubview:marker.view];
    marker.color = color;
    marker.markerPosition = position;
    marker.markerSize = size;
    
    UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_onPan:)];
    [marker.view addGestureRecognizer:panGR];
    return marker;
}

- (void)_saveSnapshot {
    BBLSnapshot *snapshot = [[BBLSnapshot alloc] init];
    NSMutableArray *tempPositions = [[NSMutableArray alloc] init];
    for (BBLMarkerData *marker in _markers) {
        [tempPositions addObject:[NSValue valueWithCGPoint:marker.markerPosition]];
    }
    snapshot.resetPositions = tempPositions;
    _snapshot = snapshot;
}

- (void)viewWillLayoutSubviews {
    CGSize backgroundSize = self.view.bounds.size;
    CGSize courtSize = backgroundSize;
    courtSize.height -= 15;
    CGSize imageSize = _courtView.image.size;
    courtSize.width = courtSize.height * imageSize.width / imageSize.height;
    _courtView.frame = CGRectMake(backgroundSize.width - courtSize.width,
                                  backgroundSize.height - courtSize.height,
                                  courtSize.width, courtSize.height);
    
    _resetButton.frame = CGRectMake(10, 170, backgroundSize.width - courtSize.width - 20, 100);
    _saveStartButton.frame = CGRectMake(10, 50, backgroundSize.width - courtSize.width - 20,100);
    
    _arrowView.frame = self.view.bounds;
    for (BBLMarkerData *marker in _markers) {
        marker.view.center = CGPointMake(marker.markerPosition.x + marker.markerPositionDelta.x,
                                         marker.markerPosition.y + marker.markerPositionDelta.y);
        marker.view.bounds = CGRectMake(0, 0, marker.markerSize.width, marker.markerSize.height);
    }
}

- (void)_onPan:(UIPanGestureRecognizer *)panGR {
    NSUInteger index = [_markers indexOfObjectPassingTest:^BOOL(BBLMarkerData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return obj.view == panGR.view;
    }];
    
    if (index == NSNotFound) {
        return;
    }
    BBLMarkerData *marker = _markers[index];
    CGPoint p = [panGR translationInView:self.view];
    
    if (panGR.state == UIGestureRecognizerStateBegan) {
        [_pathPoints removeAllObjects];
        [_pathPoints addObject:[NSValue valueWithCGPoint:CGPointMake(marker.markerPosition.x,
                                                                     marker.markerPosition.y)]];
    } else if (panGR.state == UIGestureRecognizerStateEnded) {
        marker.markerPosition = CGPointMake(marker.markerPosition.x + p.x,
                                            marker.markerPosition.y + p.y);
        marker.markerPositionDelta = CGPointZero;
    } else {
        marker.markerPositionDelta = p;
        [_pathPoints addObject:[NSValue valueWithCGPoint:CGPointMake(marker.markerPosition.x + p.x, marker.markerPosition.y + p.y)]];
    }
    _arrowView.pathPoints = _pathPoints;
    [self.view setNeedsLayout];
}

- (void)_resetButtonAction
{
    for (int i = 0; i < _markers.count; i++) {
        NSValue *newPosition = _snapshot.resetPositions[i];
        [_markers[i] setMarkerPosition:newPosition.CGPointValue];
    }
    _arrowView.pathPoints = @[];
    [self.view setNeedsLayout];

}

- (void)_saveStartButtonAction
{
    [self _saveSnapshot];
}

@end
