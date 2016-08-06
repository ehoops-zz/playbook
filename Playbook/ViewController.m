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
@property (nonatomic) int team;

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
        _snapPath = [[NSArray alloc] init];
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
        _stepCount = -1;
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
    UIButton *_defenseButton;
    
    // Button controls
    BOOL _recording;
    BOOL _showDefense;
    
    // Recording
    BBLSnapshot *_snapshot;
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
    
    // Step Button
    _stepButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_stepButton setTitle:@"Step" forState:UIControlStateNormal];
    [_stepButton.titleLabel setFont:[UIFont systemFontOfSize:48]];
    [_stepButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _stepButton.backgroundColor = [UIColor grayColor];
    [_stepButton addTarget:self action:@selector(_stepButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_stepButton];
    
    // Show Defense Button
    _defenseButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_defenseButton setTitle:@"Defense" forState:UIControlStateNormal];
    [_defenseButton.titleLabel setFont:[UIFont systemFontOfSize:48]];
    [_defenseButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _defenseButton.backgroundColor = [UIColor grayColor];
    [_defenseButton addTarget:self action:@selector(_defenseButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_defenseButton];
    
    _showDefense = YES;
    _recording = NO;
    _play = [BBLplay new];
    
    
    // Setup Player and Ball markers
    // Two teams of 5 and 1 ball
    NSMutableArray *markers = [NSMutableArray new];
    // Create Ball Marker - markers[0]
    BBLMarkerData *marker = [self _createMarkerWithColor:[UIColor brownColor] position:CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds)) size:CGSizeMake(25, 25) team:0];
    [markers addObject:marker];
    // Create Offense Markers - markers[1-5]
    for (int i=0; i < 5; i++) {
        BBLMarkerData *marker = [self _createMarkerWithColor:[UIColor blueColor] position:CGPointMake(CGRectGetMidX(bounds) - i * 50 + 100, CGRectGetMidY(bounds) - 150) size:CGSizeMake(35, 35) team:1];
        [markers addObject:marker];
    }
    // Create Defense Markers - markers[6-10]
    for (int i=0; i < 5; i++) {
        BBLMarkerData *marker = [self _createMarkerWithColor:[UIColor redColor] position:CGPointMake(CGRectGetMidX(bounds) - i * 50 + 100, CGRectGetMidY(bounds) - 75) size:CGSizeMake(35, 35) team:2];
        [markers addObject:marker];
    }
    _markers = [markers copy];
    
    [self _saveSnapshot];
}

- (void)viewWillLayoutSubviews {
    // Layout court
    CGSize backgroundSize = self.view.bounds.size;
    CGSize courtSize = backgroundSize;
    courtSize.height -= 15;
    CGSize imageSize = _courtView.image.size;
    courtSize.width = courtSize.height * imageSize.width / imageSize.height;
    _courtView.frame = CGRectMake(backgroundSize.width - courtSize.width,
                                  backgroundSize.height - courtSize.height,
                                  courtSize.width, courtSize.height);
    _arrowView.frame = self.view.bounds;
    
    // Layout buttons
    _resetButton.frame = CGRectMake(10, 160, backgroundSize.width - courtSize.width - 20, 100);
    _recordButton.frame = CGRectMake(10, 280, backgroundSize.width - courtSize.width - 20, 100);
    _stepButton.frame = CGRectMake(10, 400, backgroundSize.width - courtSize.width - 20, 100);
    _defenseButton.frame = CGRectMake(10, 520, backgroundSize.width - courtSize.width - 20, 100);

    // Update marker positions and lay them out
    for (BBLMarkerData *marker in _markers) {
        if (!_showDefense && marker.team == 2) {
            marker.view.hidden = YES;
        } else {
            marker.view.hidden = NO;
        }
        marker.view.center = CGPointMake(marker.markerPosition.x + marker.markerPositionDelta.x,
                                         marker.markerPosition.y + marker.markerPositionDelta.y);
        marker.view.bounds = CGRectMake(0, 0, marker.markerSize.width, marker.markerSize.height);
    }
}

// Helper method to create a player or ball marker
- (BBLMarkerData *)_createMarkerWithColor:(UIColor *)color position:(CGPoint)position size:(CGSize)size team:(int)team {
    BBLMarkerData *marker = [[BBLMarkerData alloc] init];
    [self.view addSubview:marker.view];
    marker.color = color;
    marker.markerPosition = position;
    marker.markerSize = size;
    marker.team = team;
    
    UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_onPan:)];
    [marker.view addGestureRecognizer:panGR];
    return marker;
}

// Helper method to save the marker position and current arrow (pathPoints)
- (void)_saveSnapshot {
    BBLSnapshot *snapshot = [[BBLSnapshot alloc] init];
    NSMutableArray *tempPositions = [[NSMutableArray alloc] init];
    for (BBLMarkerData *marker in _markers) {
        [tempPositions addObject:[NSValue valueWithCGPoint:marker.markerPosition]];
    }
    snapshot.snapPositions = tempPositions;
    snapshot.snapPath = _arrowView.pathPoints;
    _snapshot = snapshot;
}

// Helper method to save the current snapshot to the play series
- (void) _addPlayStep {
    [self _saveSnapshot];
    NSMutableArray *currentPlaySteps = [_play.playSteps mutableCopy];
    [currentPlaySteps addObject:_snapshot];
    _play.playSteps = currentPlaySteps;
}

// Helper method for reset marker positions
- (void) _setMarkersWithSnapshot:(BBLSnapshot *)snap {
    _arrowView.pathPoints = @[];
    for (int i = 0; i < _markers.count; i++) {
        NSValue *resetPosition = snap.snapPositions[i];
        [_markers[i] setMarkerPosition:resetPosition.CGPointValue];
    }
    return;
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
        marker.markerPosition = CGPointMake(marker.markerPosition.x + p.x,
                                            marker.markerPosition.y + p.y);
        marker.markerPositionDelta = CGPointZero;
        // Need to record step after positions are updated
        if (_recording) {
            [self _addPlayStep];
        }
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
    if (_recording) {
        [self _recordButtonAction];
    }
    BBLSnapshot *start = [BBLSnapshot new];
    if ([_play.playSteps count] > 0) {
        start = _play.playSteps[0];
    } else {
        start = _snapshot;
    }
    [self _setMarkersWithSnapshot:start];
    _play.stepCount = 1;
    [self.view setNeedsLayout];

}

- (void)_recordButtonAction
{
    if (!_recording) {
        _play.playSteps = @[];
        _play.stepCount = 0;
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

- (void)_stepButtonAction
{
    if (_recording) {
        [self _recordButtonAction];
    }
    if (_play.stepCount == -1) {
        return;
    } else if (_play.stepCount == 0) {
        [self _setMarkersWithSnapshot:_play.playSteps[0]];
    } else if (_play.stepCount >= [_play.playSteps count]) {
        _play.stepCount = 0;
        [self _setMarkersWithSnapshot:_play.playSteps[0]];
    } else {
        BBLSnapshot *step = _play.playSteps[_play.stepCount];
        [self _setMarkersWithSnapshot:step];
        _arrowView.pathPoints = step.snapPath;
    }
    _play.stepCount += 1;
    [self.view setNeedsLayout];
}

- (void)_defenseButtonAction
{
    if (!_showDefense) {
        [_defenseButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _defenseButton.backgroundColor = [UIColor blueColor];
        _showDefense = YES;
    } else {
        [_defenseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _defenseButton.backgroundColor = [UIColor grayColor];
        _showDefense = NO;
    }
    // Clicking the show defense button clears the most recent arrow
    // Non-optimal solution, but avoids showing an orphan arrow if the
    // defense moves last before hiding
    _arrowView.pathPoints = @[];
    [self.view setNeedsLayout];
}

@end
