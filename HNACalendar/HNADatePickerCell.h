//
//  HNADatePickerCell.h
//  HNACalendar
//
//  Created by curry on 14-3-7.
//  Copyright (c) 2014年 HNACalendar. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HNADatePickerCell;

@protocol HNADatePickerCellDelegate <NSObject>

@optional
//
- (BOOL)DatePickerCell:(HNADatePickerCell *)cell shouldUseCustomColorsForDate:(NSDate *)date;
//
- (UIColor *)DatePickerCell:(HNADatePickerCell *)cell textColorForDate:(NSDate *)date;
//
- (UIColor *)DatePickerCell:(HNADatePickerCell *)cell circleColorForDate:(NSDate *)date;
@end


@interface HNADatePickerCell : UICollectionViewCell
/**
 *  delegate委托
 **/
@property (nonatomic, weak) id<HNADatePickerCellDelegate> delegate;

/**
 *  给每cell设置日期
 **/
- (void) setDate:(NSDate*)date calendar:(NSCalendar*)calendar;

/**
 *  刷新label背景颜色和文本
 **/
- (void)refreshCellColors;

/**
 *  日期的label和label上的日期
**/
@property (nonatomic, strong) UILabel *dayLabel;

@property (nonatomic, strong) NSDate *date;
/**
 *  今天，先择的天数标签 过去的天
**/
@property (nonatomic, assign) BOOL isToday;

@property (nonatomic, assign) BOOL isEarlier;

@property (nonatomic, assign) BOOL choiceDaysTag;

/**
 *  label的背景色
**/
@property (nonatomic, strong) UIColor *circleDefaultColor;

@property (nonatomic, strong) UIColor *circleEearlierColor;

@property (nonatomic, strong) UIColor *circleTodayColor;

@property (nonatomic, strong) UIColor *circleSelectedColor;
/**
 *  label文字景色
**/
@property (nonatomic, strong) UIColor *textDefaultColor;

@property (nonatomic, strong) UIColor *textEearlierColor;

@property (nonatomic, strong) UIColor *textTodayColor;

@property (nonatomic, strong) UIColor *textSelectedColor;


@end
