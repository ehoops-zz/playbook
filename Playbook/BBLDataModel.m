#import "BBLDataModel.h"
#import "BBLMarkerView.h"


@implementation BBLSnapshot

- (instancetype)init {
    if (self=[super init]) {
        _snapPositions = [[NSArray alloc] init];
        _snapPath = [[NSArray alloc] init];
    }
    return self;
}
@end

@implementation BBLMarkerData

- (instancetype)init {
    if (self=[super init]) {
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

@implementation BBLPlay

- (instancetype)init {
    if (self=[super init]) {
        _playSteps = @[];
        _stepCount = -1;
    }
    return self;
}

@end