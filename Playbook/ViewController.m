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

@interface BBLSnapshot : NSObject

@property (nonatomic, copy) NSArray *snapPositions;
@property (nonatomic, copy) NSArray *snapPath;

@end

@implementation BBLSnapshot

- (instancetype)init {
    if(self=[super init]) {
        _snapPositions = [[NSArray alloc] init];
    }
    return self;
}
@end

@interface BBLplay : NSObject

@property (nonatomic, copy) NSArray *playSteps;
@property (nonatomic) int stepCount;

@end

@implementation BBLplay

- (instancetype)init {
    if(self=[super init]) {
        _playSteps = @[];
        _stepCount = 0;
    }
    return self;
}

@end


@interface ViewController ()

@end

@implementation ViewController {
    // Court, markers and arrows
    UIImageView *_courtView;
    NSArray<BBLMarkerData *> *_markers;
    BBLArrowView *_arrowView;
    NSMutableArray *_pathPoints;
    
    // Buttons
    UIButton *_resetButton;
    UIButton *_recordButton;
    UIButton *_stepButton;
    
    // Recording
    BBLSnapshot *_snapshot;
    BOOL _recording;
    BBLplay *_play;
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

    
    // Reset Button
    _resetButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_resetButton setTitle:@"Reset" forState:UIControlStateNormal];
    [_resetButton.titleLabel setFont:[UIFont systemFontOfSize:48]];
    [_resetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _resetButton.backgroundColor = [UIColor grayColor];
    [_resetButton addTarget:self action:@selector(_resetButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_resetButton];
    
    // Record Button
    _recordButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_recordButton setTitle:@"Record" forState:UIControlStateNormal];
    [_recordButton.titleLabel setFont:[UIFont systemFontOfSize:48]];
    [_recordButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    _recordButton.backgroundColor = [UIColor grayColor];
    [_recordButton addTarget:self action:@selector(_recordButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_recordButton];
    
    // Reset Button
    _stepButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_stepButton setTitle:@"Reset" forState:UIControlStateNormal];
    [_stepButton.titleLabel setFont:[UIFont systemFontOfSize:48]];
    [_stepButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _stepButton.backgroundColor = [UIColor grayColor];
    [_stepButton addTarget:self action:@selector(_resetButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_stepButton];
    
    // TODO: why is _recording still nil?
    _recording = NO;
    _play = [BBLplay new];
    
    
    // Setup Player and Ball markers
    // Two teams of 5 and 1 ball
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

// Helper method to create a player or ball marker
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
    _recordButton.frame = CGRectMake(10, 290, backgroundSize.width - courtSize.width - 20, 100);

    
    _arrowView.frame = self.view.bounds;
    for (BBLMarkerData *marker in _markers) {
        marker.view.center = CGPointMake(marker.markerPosition.x + marker.markerPositionDelta.x,
                                         marker.markerPosition.y + marker.markerPositionDelta.y);
        marker.view.bounds = CGRectMake(0, 0, marker.markerSize.width, marker.markerSize.height);
    }
}

// Helper method to save the marker position and current arrow (pathPoints)
- (void)_saveSnapshot {
    BBLSnapshot *snapshot = [[BBLSnapshot alloc] init];
    NSMutableArray *tempPositions = [[NSMutableArray alloc] init];
    for (BBLMarkerData *marker in _markers) {
        [tempPositions addObject:[NSValue valueWithCGPoint:marker.markerPosition]];
    }
    snapshot.snapPositions = tempPositions;
    _snapshot = snapshot;
}

// Helper method to save the current snapshot to the play series
- (void) _addPlayStep {
    [self _saveSnapshot];
    NSMutableArray *currentPlaySteps = [_play.playSteps mutableCopy];
    [currentPlaySteps addObject:_snapshot];
    _play.playSteps = currentPlaySteps;
}

// Gesture and button click methods
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
        if (_recording) {
            [self _addPlayStep];
        }
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

// Button Click Methods
- (void)_resetButtonAction
{
    BBLSnapshot *start = [BBLSnapshot new];
    if ([_play.playSteps count] > 0) {
        start = _play.playSteps[0];
    } else {
        start = _snapshot;
    }
    for (int i = 0; i < _markers.count; i++) {
        NSValue *resetPosition = start.snapPositions[i];
        [_markers[i] setMarkerPosition:resetPosition.CGPointValue];
    }
    _arrowView.pathPoints = @[];
    [self.view setNeedsLayout];

}

- (void)_recordButtonAction
{
    if (!_recording) {
        _play.playSteps = @[];
        [self _addPlayStep];
        [_recordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _recordButton.backgroundColor = [UIColor redColor];
        _recording = YES;
    } else {
        [_recordButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        _recordButton.backgroundColor = [UIColor grayColor];
        _recording = NO;
    }
}

@end
