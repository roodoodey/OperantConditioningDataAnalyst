//
//  MAXLineChartView.m
//  ReusableComponentsApp
//
//  Created by Mathieu Grettir Skulason on 8/17/16.
//  Copyright © 2016 Konta ehf. All rights reserved.
//

#import "MAXLineChartView.h"

@interface MAXLineChartView ()

@property (nonatomic, strong) NSArray <NSArray <NSNumber *> *> *chartData;

@property (nonatomic, strong) NSMutableArray <CAShapeLayer *> *lineShapeLayers;

@property (nonatomic, strong) NSArray <NSArray <UIView *> *> *lineDecorationViews;

////////// Border views

@property (nonatomic, strong) UIView *leftBorderView;

@property (nonatomic, strong) UIView *rightBorderView;

@property (nonatomic, strong) UIView *upperBorderView;

@property (nonatomic, strong) UIView *lowerBorderView;

////////// Border decoration views

@property (nonatomic, strong) NSArray <UIView *> *leftBorderDecorationViews;

@property (nonatomic, strong) NSArray <UIView *> *rightBorderDecorationViews;

@property (nonatomic, strong) NSArray <UIView *> *upperBorderDecorationViews;

@property (nonatomic, strong) NSArray <UIView *> *lowerBorderDecorationViews;

////////// Axis decoration views

@property (nonatomic, strong) NSArray <UIView *> *leftMarginDecorationViews;

@property (nonatomic, strong) NSArray <UIView *> *rightMarginDecorationViews;

@property (nonatomic, strong) NSArray <UIView *> *upperMarginDecorationViews;

@property (nonatomic, strong) NSArray <UIView *> *lowerMarginDecorationViews;

@end

@implementation MAXLineChartView

-(id)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame: frame]) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        _lineShapeLayers = [NSMutableArray array];
        
        _leftBorderView = [[UIView alloc] init];
        [self addSubview: _leftBorderView];
        
        _rightBorderView = [[UIView alloc] init];
        [self addSubview: _rightBorderView];
        
        _upperBorderView = [[UIView alloc] init];
        [self addSubview: _upperBorderView];
        
        _lowerBorderView = [[UIView alloc] init];
        [self addSubview: _lowerBorderView];
    
        self.layer.masksToBounds = YES;
    }
    
    return self;
}

-(id)init {
    return [self initWithFrame: CGRectZero];
}

-(void)reloadData {
    
    _chartData = [self p_fetchChartData];
    [self p_removeShapeLayers: _lineShapeLayers];
    [self p_drawLinesWithChartData: _chartData lineShapeLayers: _lineShapeLayers maxYValue: [self p_highestYValueForChart] maxXValue: [self p_highestXValueForChart]];
    [self p_drawChartLineBorders];
    [self p_drawLineDecorationViewsWithChartData: _chartData];
    [self p_bringBordersToFront];
    [self p_createBorderAndAxisDecorationViews];
}

#pragma mark - Fetching Line Chart Data

-(NSArray <NSArray <NSNumber *> *> *)p_fetchChartData {
    
    NSMutableArray *lines = [NSMutableArray array];
    
    NSUInteger numLines = [self.datasource MAXNumberOfLinesForChart: self];
    
    for (int line = 0; line < numLines; line++) {
        
        NSUInteger numValuesForLine = [self.datasource MAXLineChart: self numberOfXValuesForLine: line];
        
        NSMutableArray *verticalValuesForLine = [NSMutableArray array];
        
        for (int horizontalValue = 0; horizontalValue < numValuesForLine; horizontalValue++) {
            
            double verticalValue = [self.datasource MAXLineChart: self YValueAtX: horizontalValue line: line];
            [verticalValuesForLine addObject: [NSNumber numberWithDouble: verticalValue] ];
            
        }
        
        [lines addObject: verticalValuesForLine];
        
    }
    
    return lines;
}


#pragma mark - Drawing The Line Chart

-(void)p_drawLinesWithChartData:(NSArray <NSArray <NSNumber *> *> *)theChartData lineShapeLayers:(NSMutableArray *)theLineShapeLayers maxYValue:(double)maxYValue maxXValue:(NSUInteger)maxXValue {
    
    CGFloat horizontalStep = [self p_chartWidth] / (maxXValue - 1);
    CGFloat height = [self p_chartHeight];
    
    NSUInteger lineNumber = 0;
    for (NSArray *line in theChartData) {
        
        UIBezierPath *path = [[UIBezierPath alloc] init];
        path.lineWidth = 2;
        
        for (int x = 0; x < line.count; x++) {
            
            double y = [[line objectAtIndex: x] doubleValue] / maxYValue;
            double yHeight = [self p_chartHeight] - y * height;
            
            if (x == 0) {
                CGPoint point = CGPointMake([self p_totalLeftMarginAndBorderWidth], yHeight + [self p_totalUpperMarginAndBorderHeight]);
                [path moveToPoint: point];
            }
            else {
                CGPoint point = CGPointMake(x * horizontalStep + [self p_totalLeftMarginAndBorderWidth],  yHeight + [self p_totalUpperMarginAndBorderHeight]);
                [path addLineToPoint: point];
            }
            
        }
        
        CAShapeLayer *layer = [self p_createLayerWithPath: path forLine: lineNumber];
        [theLineShapeLayers addObject: layer];
        [self.layer insertSublayer: layer below: _leftBorderView.layer];
        
        // increase the line number as we go through the line data
        lineNumber++;
    }
    
}

-(void)p_removeShapeLayers:(NSMutableArray *)theShapeLayers {
    
    for (CAShapeLayer *shapeLayer in theShapeLayers) {
        [shapeLayer removeFromSuperlayer];
    }
    
    [theShapeLayers removeAllObjects];
    
}

-(CAShapeLayer *)p_createLayerWithPath:(UIBezierPath *)thePath forLine:(NSUInteger)theLine {
    
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.path = thePath.CGPath;
    layer.strokeColor = [self p_strokeColorForLine: theLine];
    layer.lineWidth = [self p_widthForLine: theLine];
    layer.lineCap = [self p_lineCapForLine: theLine];
    layer.lineDashPhase = [self p_lineDashPhaseForLine: theLine];
    layer.lineDashPattern = [self p_lineDashPatthernForLine: theLine];
    layer.allowsEdgeAntialiasing = [self p_allowsEdgeAntialiasingForLine: theLine];

    layer.fillColor = [UIColor clearColor].CGColor;
    
    return layer;
}

#pragma mark - Getter helpers

-(BOOL)p_allowsEdgeAntialiasingForLine:(NSUInteger)theLine {
    
    if ([self.delegate respondsToSelector: @selector(MAXLineChart:allowsEdgeAntialiasingForLine:)] == YES) {
        return [self.delegate MAXLineChart: self allowsEdgeAntialiasingForLine: theLine];
    }
    
    return YES;
    
}

-(NSString *)p_lineJoinForLine:(NSUInteger)theLine {
    
    MAXLineJoinStyle lineJoin = [self p_lineJoinStyleForLine: theLine];
    
    if (lineJoin == kMAXLineJoinStyleMiter) {
        
        return kCALineJoinMiter;
    }
    else if(lineJoin == kMAXLineJoinStyleRound) {
        
        return kCALineJoinRound;
    }
    else if(lineJoin == kMAXLineJoinStyleBevel) {
        
        return kCALineJoinBevel;
    }
    
    return kCALineJoinRound;
    
}

-(MAXLineJoinStyle)p_lineJoinStyleForLine:(NSUInteger)theLine {
    
    if ([self.delegate respondsToSelector:@selector(MAXLineChart:lineJoinStyleForLine:)] == YES) {
        return [self.delegate MAXLineChart: self lineJoinStyleForLine: theLine];
    }
    else {
        return kMAXLineJoinStyleRound;
    }
    
}

-(NSString *)p_lineCapForLine:(NSUInteger)theLine {
    
    MAXLineCapStyle style = [self p_lineCapStyleForLine: theLine];
    
    if (style == kMAXLineCapStyleButt) {
        
        return kCALineCapRound;
    }
    else if(style == kMAXLineCapStyleRound) {
        
        return kCALineCapRound;
    }
    else if(style == kMAXLineCapStyleSquare) {
        
        return kCALineCapSquare;
    }
    
    return kCALineCapRound;
}

-(MAXLineCapStyle)p_lineCapStyleForLine:(NSUInteger)theLine {
    
    if ([self.delegate respondsToSelector:@selector(MAXLineChart:lineCapStyelForLine:)] == YES) {
        return [self.delegate MAXLineChart: self lineCapStyelForLine: theLine];
    }
    else {
        return kMAXLineCapStyleRound;
    }
    
}

-(CGFloat)p_lineDashPhaseForLine:(NSUInteger)theLine {
    
    if ([self.delegate respondsToSelector:@selector(MAXLineChart:lineDashPhaseForLine:)] == YES) {
        return [self.delegate MAXLineChart: self lineDashPhaseForLine: theLine];
    }
    
    return 0;
}

-(NSArray <NSNumber *> *)p_lineDashPatthernForLine:(NSUInteger)theLine {
    
    if ([self.delegate respondsToSelector: @selector(MAXLineChart:lineDashPatternForLine:)] == YES) {
        return  [self.delegate MAXLineChart: self lineDashPatternForLine: theLine];
    }
    else {
        
        return nil;
    }
    
}

-(CGFloat)p_widthForLine:(NSUInteger)theLine {
    
    if ([self.delegate respondsToSelector: @selector(MAXLineChart:widthForLine:)] == YES) {
        
        return [self.delegate MAXLineChart: self widthForLine: theLine];
    }
    else {
        
        return 2.0;
    }
    
}

-(CGColorRef)p_strokeColorForLine:(NSUInteger)theLine {
    
    if ([self.delegate respondsToSelector: @selector(MAXLineChart:strokeColorForLine:)] == YES) {
        
        return [self.delegate MAXLineChart: self strokeColorForLine: theLine].CGColor;
    }
    else {
        
        return [UIColor blackColor].CGColor;
    }
    
}

-(NSUInteger)p_highestXValueForChart {
    
    if ([self.delegate respondsToSelector: @selector(MAXHighestXValueForLineChart:)] == YES) {
        
        return [self.delegate MAXHighestXValueForLineChart: self];
    }
    else {
        
        NSInteger highestXValue = 0;
        
        for (NSArray *line in _chartData) {
            
            if (line.count > highestXValue) {
                
                highestXValue = line.count;
            }
            
        }
        
        return highestXValue;
        
    }
    
}


-(double)p_highestYValueForChart {
    
    // check if the user wants to provide his own value or if we exrtact it from the data
    if ([self.delegate respondsToSelector:@selector(MAXhighestYValueForLineChart:)] == YES) {
        
        return [self.delegate MAXhighestYValueForLineChart: self];
    }
    else {
        return [self p_findHighestYValue: _chartData];
    }
    
}

#pragma mark - Line Decoration Views

-(void)p_drawLineDecorationViewsWithChartData:(NSArray <NSArray <NSNumber *> *> *)theChartData {
    
    if ([self.datasource respondsToSelector:@selector(MAXLineChart:numDecorationViewsForLine:)] == YES || [self.datasource respondsToSelector:@selector(MAXLineChart:xValueForDecorationViewForLine:atIndex:)] == YES || [self.datasource respondsToSelector:@selector(MAXLineChart:decorationViewForLine:atIndex:decorationViewPosition:)] == YES) {
        
        [self p_removeLineDecorationViews];
        _lineDecorationViews = [self p_fetchAndDrawLineDecorationViewsWithChartData: theChartData];
        
    }
    
}

-(NSArray <NSArray <UIView *> *> *)p_fetchAndDrawLineDecorationViewsWithChartData:(NSArray <NSArray <NSNumber *> *> *)theChartData {
    
    NSMutableArray *lineDecorationViews = [NSMutableArray array];
    
    for (int line = 0; line < theChartData.count; line++) {
        
        NSMutableArray *decorationViews = [NSMutableArray array];
        
        NSUInteger numDecorationViews = [self.datasource MAXLineChart: self numDecorationViewsForLine: line];
        NSArray *lineData = [theChartData objectAtIndex: line];
        
        for (int decorationIndex = 0; decorationIndex < numDecorationViews; decorationIndex++) {
            
            double posX = [self.datasource MAXLineChart: self xValueForDecorationViewForLine: line atIndex: decorationIndex];
            
            int lowPosX = floor(posX);
            int highPosX = ceil(posX);
            
            double highestYValueForChart = [self p_highestYValueForChart];
            
            double lowPosY = [[lineData objectAtIndex: lowPosX] doubleValue] / highestYValueForChart;
            double highPosY = [[lineData objectAtIndex: highPosX] doubleValue] / highestYValueForChart;
            
            double slopeHeight = /* dstance x*/ (posX - lowPosX) * /* slope */ (highPosY - lowPosY) * [self p_chartHeight];
            double lowPosYViewCoord = (1 - lowPosY) * [self p_chartHeight];
            
            double horizontalStep = [self p_chartWidth] / ([self p_highestXValueForChart] - 1);

            CGPoint centerPointForDecorationView = CGPointMake([self p_totalLeftMarginAndBorderWidth] + horizontalStep * posX,  [self p_totalUpperMarginAndBorderHeight] + lowPosYViewCoord - slopeHeight);

            UIView *lineDecorationView = [self.datasource MAXLineChart: self decorationViewForLine: line atIndex: decorationIndex decorationViewPosition: centerPointForDecorationView];
            [self addSubview: lineDecorationView];
            
            [decorationViews addObject: lineDecorationView];
        }
        
        [lineDecorationViews addObject: decorationViews];
    }
    
    return lineDecorationViews;
}

-(void)p_removeLineDecorationViews {
    
    for (NSArray *lineDecorations in _lineDecorationViews) {
        
        for (UIView *decorationView in lineDecorations) {
            [decorationView removeFromSuperview];
        }
        
    }
    
}

#pragma mark - Line Border Drawing

-(void)p_drawChartLineBorders {
    
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    
    CGFloat heightWithBorders = [self p_upperBorderHeight] + [self p_chartHeight] + [self p_lowerBorderHeight];
    CGFloat widthWithBorders = [self p_leftBorderWidth] + [self p_chartWidth] + [self p_rightBorderWidth];
    
    _leftBorderView.frame = CGRectMake([self p_leftMarginWidth], [self p_upperMarginHeight], [self p_leftBorderWidth], heightWithBorders);
    _rightBorderView.frame = CGRectMake(width - [self p_totalRightMarginAndBorderWidth], [self p_upperMarginHeight], [self p_rightBorderWidth], heightWithBorders);
    
    _upperBorderView.frame = CGRectMake([self p_leftMarginWidth], [self p_upperMarginHeight], widthWithBorders, [self p_upperBorderHeight]);
    _lowerBorderView.frame = CGRectMake([self p_leftMarginWidth], height - [self p_lowerBorderHeight] - [self p_lowerMarginHeight], widthWithBorders, [self p_lowerBorderHeight]);
    
    [self p_reloadBorderColor];
    
}

-(void)p_reloadBorderColor {
    
    if ([self.delegate respondsToSelector:@selector(MAXLineChartColorsForBordersForChart:)] == YES) {
        
        UIColor *borderColor = [self.delegate MAXLineChartColorsForBordersForChart: self];
        
        [self p_setBordersColor: borderColor];
        
    }
    else {
        [self p_setBordersColor: [UIColor blackColor]];
    }
    
}

-(void)p_bringBordersToFront {
    
    [self bringSubviewToFront: _leftBorderView];
    [self bringSubviewToFront: _rightBorderView];
    [self bringSubviewToFront: _upperBorderView];
    [self bringSubviewToFront: _lowerBorderView];
    
}

-(void)p_setBordersColor:(UIColor *)theColor {
    
    _leftBorderView.backgroundColor = theColor;
    _rightBorderView.backgroundColor = theColor;
    _upperBorderView.backgroundColor = theColor;
    _lowerBorderView.backgroundColor = theColor;
    
}

#pragma mark - Border and Axis Decoration Views

-(void)p_createBorderAndAxisDecorationViews {
    
    NSArray <NSValue *> *leftBorderPositions = [self p_fetchLeftBorderDecorationPositions];
    NSArray <NSValue *> *rightBorderPositions = [self p_fetchRightBorderDecorationPositions];
    NSArray <NSValue *> *upperBorderPositions = [self p_fetchUpperBorderDecoartionPositions];
    NSArray <NSValue *> *lowerBorderPositions = [self p_fetchLowerBorderDecorationPositions];
    
    [self p_removeLineBorderDecorationViews];
    _leftBorderDecorationViews = [self p_fetchLeftBorderDecorationViewsWithPositions: leftBorderPositions];
    _rightBorderDecorationViews = [self p_fetchRightBorderDecorationViewsWithPositions: rightBorderPositions];
    _upperBorderDecorationViews = [self p_fetchUpperBorderDecorationViewsWithPositions: upperBorderPositions];
    _lowerBorderDecorationViews = [self p_fetchLowerBorderDecorationViewsWithPositions: lowerBorderPositions];
    
}

-(NSArray <NSValue *> *)p_fetchLeftBorderDecorationPositions {
    
    // these methods have to be defined in order to create the left decoration views
    if ([self.datasource respondsToSelector:@selector(MAXLineChartNumberOfDecorationViewsForLeftBorder:)] == YES && [self.datasource respondsToSelector:@selector(MAXLineChart:yValueForLeftBorderDecorationViewAtIndex:)] == YES && [self.datasource respondsToSelector:@selector(MAXLineChart:leftBorderDecorationViewAxisCenterPoint:atIndex:)] == YES) {
        
        NSMutableArray *leftBorderDecorationPositions = [NSMutableArray array];
        
        NSUInteger numberOfDecorationViews = [self.datasource MAXLineChartNumberOfDecorationViewsForLeftBorder: self];
        
        for (int decorationIndex = 0; decorationIndex < numberOfDecorationViews; decorationIndex++) {
            
            double yValue = [self.datasource MAXLineChart: self yValueForLeftBorderDecorationViewAtIndex: decorationIndex];
            
            CGPoint centerPoint = CGPointMake([self p_leftMarginWidth] + [self p_leftBorderWidth] / 2.0, [self p_totalUpperMarginAndBorderHeight] + (1 - yValue / [self p_highestYValueForChart]) * [self p_chartHeight]);
            
            [leftBorderDecorationPositions addObject: [NSValue valueWithCGPoint: centerPoint]];
            
        }
        
        return leftBorderDecorationPositions;
    }
    
    return nil;
    
}

-(NSArray <NSValue *> *)p_fetchRightBorderDecorationPositions {
    
    // these methods have to be defined in order to create the right decoration views
    if ([self.datasource respondsToSelector:@selector(MAXLineChartNumberOfDecorationViewsForRightBorder:)] == YES && [self.datasource respondsToSelector:@selector(MAXLineChart:yValueForRightBorderDecorationViewAtIndex:)] == YES && [self.datasource respondsToSelector:@selector(MAXLineChart:rightBorderDecorationViewAxisCenterPoint:atIndex:)] == YES) {
        
        NSMutableArray *rightBorderDecorationPositions = [NSMutableArray array];
        
        NSUInteger numberOfDecorationViews = [self.datasource MAXLineChartNumberOfDecorationViewsForRightBorder: self];
        
        for (int decorationIndex = 0; decorationIndex < numberOfDecorationViews; decorationIndex++) {
            
            double yValue = [self.datasource MAXLineChart: self yValueForRightBorderDecorationViewAtIndex: decorationIndex];
            
            CGPoint centerPoint = CGPointMake( [self p_totalLeftMarginAndBorderWidth] + [self p_chartWidth] + [self p_rightBorderWidth] / 2.0, [self p_totalUpperMarginAndBorderHeight] + (1 - yValue / [self p_highestYValueForChart]) * [self p_chartHeight]);
            
            [rightBorderDecorationPositions addObject: [NSValue valueWithCGPoint: centerPoint]];
        }
        
        return rightBorderDecorationPositions;
    }
    
    return nil;
    
}

-(NSArray <NSValue *> *)p_fetchUpperBorderDecoartionPositions {
    
    // these methods have to be defined in order to create the upper decoration view
    if ([self.datasource respondsToSelector:@selector(MAXLineChartNumberOfDecorationViewsForUpperBorder:)] == YES && [self.datasource respondsToSelector:@selector(MAXLineChart:xValueForUpperBorderDecorationViewAtIndex:)] == YES && [self.datasource respondsToSelector:@selector(MAXLineChart:upperBorderDecorationViewAxisCenterPoint:atIndex:)] == YES) {
        
        NSMutableArray *upperBorderDecorationPositions = [NSMutableArray array];
        
        NSUInteger numberOfDecorationViews = [self.datasource MAXLineChartNumberOfDecorationViewsForUpperBorder: self];
        
        for (int decorationIndex = 0; decorationIndex < numberOfDecorationViews; decorationIndex++) {
            
            double upperBorderValue = [self.datasource MAXLineChart: self xValueForUpperBorderDecorationViewAtIndex: decorationIndex];
            
            CGPoint centerPoint = CGPointMake([self p_totalLeftMarginAndBorderWidth] + upperBorderValue / [self p_highestXValueForChart] * [self p_chartWidth], [self p_upperMarginHeight] + [self p_upperBorderHeight] / 2.0);
            
            [upperBorderDecorationPositions addObject: [NSValue valueWithCGPoint: centerPoint]];
        }
        
        return upperBorderDecorationPositions;
    }
    
    return nil;
    
}

-(NSArray <NSValue *> *)p_fetchLowerBorderDecorationPositions {
    
    if ([self.datasource respondsToSelector:@selector(MAXLineChartNumberOfDecorationViewsForLowerBorder:)] == YES && [self.datasource respondsToSelector:@selector(MAXLineChart:xValueForLowerBorderDecorationViewAtIndex:)] == YES && [self.datasource respondsToSelector:@selector(MAXLineChart:lowerBorderDecorationViewAxisCenterPoint:atIndex:)] == YES) {
        
        NSMutableArray *lowerBorderDecorationPositions = [NSMutableArray array];
        
        NSUInteger numberOfDecorationViews = [self.datasource MAXLineChartNumberOfDecorationViewsForLowerBorder: self];
        
        for (int decorationIndex = 0; decorationIndex < numberOfDecorationViews; decorationIndex++) {
            
            double lowerBorderValue = [self.datasource MAXLineChart: self xValueForLowerBorderDecorationViewAtIndex: decorationIndex];
            
            CGPoint centerPoint = CGPointMake([self p_totalLeftMarginAndBorderWidth] + lowerBorderValue / [self p_highestXValueForChart] * [self p_chartWidth], [self p_totalUpperMarginAndBorderHeight] + [self p_chartHeight] + [self p_lowerBorderHeight] / 2.0);
            
            [lowerBorderDecorationPositions addObject: [NSValue valueWithCGPoint: centerPoint]];
        }
        
        return lowerBorderDecorationPositions;
    }
    
    return nil;
    
}

#pragma mark - Border Line Decoration Views


-(void)p_removeLineBorderDecorationViews {
    
    [self p_removeLineDecorationViewsWithDecorationViews: _leftBorderDecorationViews];
    [self p_removeLineDecorationViewsWithDecorationViews: _rightBorderDecorationViews];
    [self p_removeLineDecorationViewsWithDecorationViews: _upperBorderDecorationViews];
    [self p_removeLineDecorationViewsWithDecorationViews: _lowerBorderDecorationViews];
    
}

-(void)p_removeLineDecorationViewsWithDecorationViews:(NSArray <UIView *> *)decorationViews {
    
    for (UIView *view in decorationViews) {
        
        [view removeFromSuperview];
        
    }
    
}

-(NSArray <UIView *> *)p_fetchLeftBorderDecorationViewsWithPositions:(NSArray <NSValue *> *)thePoints {
    
    // these methods have to be defined in order to create the left decoration views
    if (thePoints.count != 0) {
        
        NSMutableArray *leftBorderDecorationViews = [NSMutableArray array];
        
        int index = 0;
        for (NSValue *centerPointValue in thePoints) {
            
            CGPoint centerPoint = [centerPointValue CGPointValue];
            UIView *axisDecorationView = [self.datasource MAXLineChart: self leftBorderDecorationViewAxisCenterPoint: centerPoint atIndex: index];
            [self addSubview: axisDecorationView];
            
            [leftBorderDecorationViews addObject: axisDecorationView];
            
            index ++;
            
        }
        
        
        return leftBorderDecorationViews;
    }
    
    return nil;
}

-(NSArray <UIView *> *)p_fetchRightBorderDecorationViewsWithPositions:(NSArray <NSValue *> *)thePoints {
    
    // these methods have to be defined in order to create the right decoration views
    if (thePoints.count != 0) {
        
        NSMutableArray *rightBorderDecorationViews = [NSMutableArray array];
        
        int index = 0;
        for (NSValue *centerPointValue in thePoints) {
            
            CGPoint centerPoint = [centerPointValue CGPointValue];
            UIView *axisDecorationView = [self.datasource MAXLineChart: self rightBorderDecorationViewAxisCenterPoint: centerPoint atIndex: index];
            [self addSubview: axisDecorationView];
            
            [rightBorderDecorationViews addObject: axisDecorationView];
            
            index ++;
            
        }
        
        
        return rightBorderDecorationViews;
    }
    
    return nil;
}

-(NSArray <UIView *> *)p_fetchUpperBorderDecorationViewsWithPositions:(NSArray <NSValue *> *)thePoints {
    
    // these methods have to be defined in order to create the upper decoration view
    if (thePoints.count != 0) {
        
        NSMutableArray *upperBorderDecorationViews = [NSMutableArray array];
        
        int index = 0;
        for (NSValue *centerPointValue in thePoints) {
            
            CGPoint centerPoint = [centerPointValue CGPointValue];
            UIView *axisDecorationView = [self.datasource MAXLineChart: self upperBorderDecorationViewAxisCenterPoint: centerPoint atIndex: index];
            [self addSubview: axisDecorationView];
            
            [upperBorderDecorationViews addObject: axisDecorationView];
            
            index ++;
        }
        
        return upperBorderDecorationViews;
    }
    
    return nil;
}

-(NSArray <UIView *> *)p_fetchLowerBorderDecorationViewsWithPositions:(NSArray <NSValue *> *)thePoints {
    
    
    if (thePoints.count != 0) {
        
        NSMutableArray *lowerBorderDecorationViews = [NSMutableArray array];
        
        int index = 0;
        for (NSValue *centerPointValue in thePoints) {
            
            CGPoint centerPoint = [centerPointValue CGPointValue];
            
            UIView *axisDecorationViews = [self.datasource MAXLineChart: self lowerBorderDecorationViewAxisCenterPoint: centerPoint atIndex: index];
            [self addSubview: axisDecorationViews];
            
            [lowerBorderDecorationViews addObject: axisDecorationViews];
            
            index += 1;
        }
        
        
        return lowerBorderDecorationViews;
    }
    
    return nil;
    
}


#pragma mark - Chart Size Helpers

-(CGFloat)p_chartHeight {
    
    double height = CGRectGetHeight(self.frame);
    
    return height - [self p_totalUpperMarginAndBorderHeight] - [self p_totalLowerMarginAndBorderHeight];
}

-(CGFloat)p_chartWidth {
    
    double width = CGRectGetWidth(self.frame);
    
    return width - [self p_totalLeftMarginAndBorderWidth] - [self p_totalRightMarginAndBorderWidth];
}

-(CGFloat)p_totalLeftMarginAndBorderWidth {
    
    return [self p_leftMarginWidth] + [self p_leftBorderWidth];
}

-(CGFloat)p_totalRightMarginAndBorderWidth {
    
    return [self p_rightMarginWidth] + [self p_rightBorderWidth];
}

-(CGFloat)p_totalUpperMarginAndBorderHeight {
    
    return [self p_upperMarginHeight] + [self p_upperBorderHeight];
}

-(CGFloat)p_totalLowerMarginAndBorderHeight {
    
    return [self p_lowerMarginHeight] + [self p_lowerBorderHeight];
}

#pragma mark - Line Chart Margin Getters

-(CGFloat)p_leftMarginWidth {
    
    if ([self.delegate respondsToSelector:@selector(MAXLineChartLeftMarginWidth:)] == YES) {
        return [self.delegate MAXLineChartLeftMarginWidth: self];
    }
    
    return 0;
}

-(CGFloat)p_rightMarginWidth {
    
    if ([self.delegate respondsToSelector:@selector(MAXLineChartRightMarginWidth:)] == YES) {
        return [self.delegate MAXLineChartRightMarginWidth: self];
    }
    
    return 0;
}

-(CGFloat)p_upperMarginHeight {
    
    if ([self.delegate respondsToSelector:@selector(MAXLineChartUpperMarginHeight:)] == YES) {
        return [self.delegate MAXLineChartUpperMarginHeight: self];
    }
    
    return 0;
}

-(CGFloat)p_lowerMarginHeight {
    
    if ([self.delegate respondsToSelector:@selector(MAXLineChartLowerMarginHeight:)] == YES) {
        return [self.delegate MAXLineChartLowerMarginHeight: self];
    }
    
    return 0;
}

#pragma mark - Line Chart Border Getters

-(CGFloat)p_leftBorderWidth {
    
    if ([self.delegate respondsToSelector:@selector(MAXLineChartLeftBorderWidthForChart:)] == YES) {
        return [self.delegate MAXLineChartLeftBorderWidthForChart: self];
    }
    
    return 0;
}

-(CGFloat)p_rightBorderWidth {
    
    if ([self.delegate respondsToSelector:@selector(MAXLineChartRightBorderWidthForChart:)] == YES) {
        
        return [self.delegate MAXLineChartRightBorderWidthForChart: self];
    }
    
    return 0;
}

-(CGFloat)p_upperBorderHeight {
    
    if ([self.delegate respondsToSelector:@selector(MAXLineChartUpperBorderHeightForChart:)] == YES) {
        
        return [self.delegate MAXLineChartUpperBorderHeightForChart: self];
    }
    
    return 0;
}

-(CGFloat)p_lowerBorderHeight {
    
    if ([self.delegate respondsToSelector:@selector(MAXLineChartLowerBorderHeightForChart:)] == YES) {
        
        return [self.delegate MAXLineChartLowerBorderHeightForChart: self];
    }
    
    return 0;
}


#pragma mark - Helpers


-(double)p_findHighestYValue:(NSArray <NSArray <NSNumber *> *> *)theChartData {
    
    double highestValue = 0;
    
    for (NSArray *line in theChartData) {
        
        for (NSNumber *yValue in line) {
        
            if ([yValue doubleValue] > highestValue) {
                highestValue = [yValue doubleValue];
            }
        
        }
    
    }
    
    return highestValue;
}

@end
