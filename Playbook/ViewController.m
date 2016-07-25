//
//  ViewController.m
//  Playbook
//
//  Created by Erin Hoops on 7/21/16.
//  Copyright © 2016 Erin Hoops. All rights reserved.
//

#import "ViewController.h"
#import "BBLPlayerView.h"

@interface BBLPlayerData : NSObject

@property (strong) BBLPlayerView *view;
@property (assign) CGPoint playerPosition;
@property (assign) CGPoint playerPositionDelta;
@property (copy) UIColor *color;

@end

@implementation BBLPlayerData

- (instancetype)init {
    if(self=[super init]) {
        _view = [[BBLPlayerView alloc] initWithFrame:CGRectZero];
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
    NSArray<BBLPlayerData *> *_players;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect bounds = self.view.bounds;
    NSMutableArray *players = [NSMutableArray new];
    for (int i=0; i < 5; i++) {
        BBLPlayerData *player = [self _createMarkerWithColor:[UIColor blueColor] position:CGPointMake(CGRectGetMidX(bounds) - i * 50 + 85, CGRectGetMidY(bounds) - 75)];
        [players addObject:player];
    }
    
    for (int i=0; i < 5; i++) {
        BBLPlayerData *player = [self _createMarkerWithColor:[UIColor redColor] position:CGPointMake(CGRectGetMidX(bounds) - i * 50 + 85, CGRectGetMidY(bounds) - 150)];
        [players addObject:player];
    }
    
    BBLPlayerData *player = [self _createMarkerWithColor:[UIColor brownColor] position:CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds))];
    [players addObject:player];

    
    _players = [players copy];
}

- (BBLPlayerData *)_createMarkerWithColor:(UIColor *)color position:(CGPoint)position{
    BBLPlayerData *player = [[BBLPlayerData alloc] init];
    [self.view addSubview:player.view];
    player.color = color;
    player.playerPosition = position;
    
    UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_onPan:)];
    [player.view addGestureRecognizer:panGR];
    return player;
}

- (void)viewWillLayoutSubviews {
    for (BBLPlayerData *player in _players) {
        player.view.frame = CGRectMake(player.playerPosition.x + player.playerPositionDelta.x,
                                       player.playerPosition.y + player.playerPositionDelta.y,
                                       25, 25);
    }

}

- (void)_onPan:(UIPanGestureRecognizer *)panGR {
    NSUInteger index = [_players indexOfObjectPassingTest:^BOOL(BBLPlayerData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return obj.view == panGR.view;
    }];
    
    if (index == NSNotFound) {
        return;
    }
    BBLPlayerData *player = _players[index];
    CGPoint p = [panGR translationInView:self.view];
    if (panGR.state == UIGestureRecognizerStateEnded) {
        player.playerPosition = CGPointMake(player.playerPosition.x + p.x, player.playerPosition.y + p.y);
        player.playerPositionDelta = CGPointZero;
    } else {
        player.playerPositionDelta = p;
    }
    [self.view setNeedsLayout];
}

@end
