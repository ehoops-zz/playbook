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

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self=[super init]) {
        _snapPositions = [aDecoder decodeObjectForKey:@"positions"];
        _snapPath = [aDecoder decodeObjectForKey:@"path"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_snapPositions forKey:@"positions"];
    [aCoder encodeObject:_snapPath forKey:@"path"];
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
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self=[super init]) {
        _playSteps = [aDecoder decodeObjectForKey:@"play"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_playSteps forKey:@"play"];
}

@end

















