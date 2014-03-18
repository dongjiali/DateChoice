//
//  HNADatePickerCell.m
//  HNACalendar
//
//  Created by 董家力 on 14-3-7.
//  Copyright (c) 2014年 HNACalendar. All rights reserved.
//

#import "HNADatePickerCell.h"
#import "deploymember.h"
#import <QuartzCore/QuartzCore.h>
const CGFloat labelCircleSize = 32.0f;

@implementation HNADatePickerCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _date = nil;
        _isToday = NO;
        _dayLabel = [[UILabel alloc] init];
        [self.dayLabel setTextAlignment:NSTextAlignmentCenter];
        [self.contentView addSubview:self.dayLabel];
        [self.dayLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.dayLabel setBackgroundColor:[UIColor clearColor]];
        self.dayLabel.layer.cornerRadius = labelCircleSize/2;
        self.dayLabel.layer.masksToBounds = YES;
        
        //添加约束 自动适配
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.dayLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.dayLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.dayLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:labelCircleSize]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.dayLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:labelCircleSize]];
        
        [self setCircleColor:NO selected:NO earlier:NO];
    }
    
    return self;
}

- (void)setDate:(NSDate *)date calendar:(NSCalendar *)calendar
{
    NSString* day = @"";
    if (date && calendar) {
        self.date = date;
        NSDateComponents *dateComponents = [calendar components:NSDayCalendarUnit|NSMonthCalendarUnit fromDate:self.date];
        day = [NSString stringWithFormat:@"%@", @(dateComponents.day)];
    }
    self.dayLabel.text = day;
}

- (void)setIsToday:(BOOL)isToday
{
    _isToday = isToday;
    [self setCircleColor:isToday selected:self.selected earlier:self.isEarlier];
}

- (void)setIsEarlier:(BOOL)isEarlier
{
    _isEarlier = isEarlier;
    [self setCircleColor:self.isToday selected:self.selected earlier:self.isEarlier];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (self.choiceDaysTag) {
        [self setCircleColor:self.isToday selected:selected earlier:self.isEarlier];
    }else
    {
        [self setCircleColorselected:selected];
//        [self start:self.dayLabel];
    }
    
}


- (void)setCircleColorselected:(BOOL)selected
{
    if (selected && !self.isEarlier) {
        [self.dayLabel setBackgroundColor:[self circleSelectedColor]];
        [self.dayLabel setTextColor:[self textSelectedColor]];
    }
}

- (void)setCircleColor:(BOOL)today selected:(BOOL)selected earlier:(BOOL)earlier
{
    UIColor *circleColor = (today) ? [self circleTodayColor] : earlier?[self circleteEearlierColor]:[self circleDefaultColor];
    UIColor *labelColor = (today) ? [self textTodayColor] : earlier?[self textEearlierColor]:[self textDefaultColor];
    
    if (self.date && self.delegate) {
        if ([self.delegate respondsToSelector:@selector(DatePickerCell:shouldUseCustomColorsForDate:)] && [self.delegate DatePickerCell:self shouldUseCustomColorsForDate:self.date]) {
            
            if ([self.delegate respondsToSelector:@selector(DatePickerCell:textColorForDate:)] && [self.delegate DatePickerCell:self textColorForDate:self.date]) {
                labelColor = [self.delegate DatePickerCell:self textColorForDate:self.date];
            }
            
            if ([self.delegate respondsToSelector:@selector(DatePickerCell:circleColorForDate:)] && [self.delegate DatePickerCell:self circleColorForDate:self.date]) {
                circleColor = [self.delegate DatePickerCell:self circleColorForDate:self.date];
            }
        }
    }
    
    if (selected) {
        circleColor = [self circleSelectedColor];
        labelColor = [self textSelectedColor];
    }

    [self.dayLabel setBackgroundColor:circleColor];
    [self.dayLabel setTextColor:labelColor];
}


- (void)refreshCellColors
{
    [self setCircleColor:self.isToday selected:self.isSelected earlier:self.isEarlier];
}

#pragma mark - Animation
//添加边框 开始动画
- (void)start:(UILabel *)dayLabel
{
    //给label添加边框
    CGRect pathFrame = CGRectMake(-CGRectGetMidX(self.dayLabel.bounds), -CGRectGetMidY(self.dayLabel.bounds), self.dayLabel.bounds.size.width, self.dayLabel.bounds.size.height);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:pathFrame cornerRadius:self.dayLabel.layer.cornerRadius];
    
    // accounts for left/right offset and contentOffset of scroll view
    CGPoint shapePosition = [self convertPoint:self.dayLabel.center fromView:self.contentView];
    
    CAShapeLayer *circleShape = [CAShapeLayer layer];
    circleShape.path = path.CGPath;
    circleShape.position = shapePosition;
    circleShape.fillColor = [UIColor clearColor].CGColor;
    circleShape.opacity = 0;
    circleShape.strokeColor = [UIColor blueColor].CGColor;
    circleShape.lineWidth = 1;
    [self.dayLabel.layer addSublayer:circleShape];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(2.5, 2.5, 1)];
    
    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaAnimation.fromValue = @1;
    alphaAnimation.toValue = @0;
    
    CAAnimationGroup *animation = [CAAnimationGroup animation];
    animation.animations = @[scaleAnimation, alphaAnimation];
    animation.duration = 0.5f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [circleShape addAnimation:animation forKey:nil];
}

#pragma mark - Prepare for Reuse

- (void)prepareForReuse
{
    [super prepareForReuse];
    _date = nil;
    _isToday = NO;
    [self.dayLabel setText:@""];
    [self.dayLabel setBackgroundColor:[self circleDefaultColor]];
    [self.dayLabel setTextColor:[self textDefaultColor]];
}

#pragma mark - Circle Color Customization Methods

- (UIColor *)circleDefaultColor
{
    if(_circleDefaultColor == nil) {
        _circleDefaultColor = [[[self class] appearance] circleDefaultColor];
    }
    
    if(_circleDefaultColor != nil) {
        return _circleDefaultColor;
    }
    
    return CircleDefaultColor;
}

- (UIColor *)circleteEearlierColor
{
    if(_circleEearlierColor == nil) {
        _circleEearlierColor = [[[self class] appearance] circleDefaultColor];
    }
    
    if(_circleEearlierColor != nil) {
        return _circleEearlierColor;
    }
    
    return CircleEearlierColor;
}

- (UIColor *)circleTodayColor
{
    if(_circleTodayColor == nil) {
        _circleTodayColor = [[[self class] appearance] circleTodayColor];
    }
    
    if(_circleTodayColor != nil) {
        return _circleTodayColor;
    }
    
    return CircleTodayColor;
}

- (UIColor *)circleSelectedColor
{
    if(_circleSelectedColor == nil) {
        _circleSelectedColor = [[[self class] appearance] circleSelectedColor];
    }
    
    if(_circleSelectedColor != nil) {
        return _circleSelectedColor;
    }
    
    return CircleSelectedColor;
}

#pragma mark - Text Label Customizations Color

- (UIColor *)textDefaultColor
{
    if(_textDefaultColor == nil) {
        _textDefaultColor = [[[self class] appearance] textDefaultColor];
    }
    
    if(_textDefaultColor != nil) {
        return _textDefaultColor;
    }
    
    return TextDefaultColor;
}

- (UIColor *)textEearlierColor
{
    if(_textEearlierColor == nil) {
        _textEearlierColor = [[[self class] appearance] textDefaultColor];
    }
    
    if(_textEearlierColor != nil) {
        return _textEearlierColor;
    }
    return TextEearlierColor;
}

- (UIColor *)textTodayColor
{
    if(_textTodayColor == nil) {
        _textTodayColor = [[[self class] appearance] textTodayColor];
    }
    
    if(_textTodayColor != nil) {
        return _textTodayColor;
    }
    
    return TextTodayColor;
}

- (UIColor *)textSelectedColor
{
    if(_textSelectedColor == nil) {
        _textSelectedColor = [[[self class] appearance] textSelectedColor];
    }
    
    if(_textSelectedColor != nil) {
        return _textSelectedColor;
    }
    
    return TextSelectedColor;
}

@end
