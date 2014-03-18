//
//  HNADatePickerCollection.h
//  HNACalendar
//
//  Created by 董家力 on 14-3-7.
//  Copyright (c) 2014年 HNACalendar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DatepickerViewDelegate;
/**
 *  定义一周7天
 */
extern const NSUInteger DatePickerDaysPerWeek;

typedef enum SelectDateSite
{
    EarlierDate = 0,
    MiddleDate,
    LaterDate,
} SelectDateSite;

@interface HNADatePickerCollection : UICollectionViewController
// 创建日历试图的数据
@property (nonatomic, strong) NSCalendar *calendar;

//当前月份的第一天。
@property (nonatomic, strong) NSDate *firstDate;

//去年当月的第一天
@property (nonatomic, strong) NSDate *lastDate;

//选择日期显示的日历
@property (nonatomic, strong) NSDate *selectedDate;

//选择日期显示的日历列表
@property (nonatomic, strong) NSMutableArray *selectedAllDate;

//初如日期显示的日历列表
@property (nonatomic, strong) NSMutableArray *collectioncells;

//cellr路径
@property (nonatomic, strong) NSIndexPath *lastAccessed;

//单选与多选标志
@property (nonatomic, assign) BOOL selectDaysTag;

//背景颜色的日历
@property (nonatomic, strong) UIColor *backgroundColor;

//文本颜色
@property (nonatomic, strong) UIColor *overlayTextColor;

@property (nonatomic, weak) id<DatepickerViewDelegate> delegate;

//滚动到更改所选日期的日历,
- (void)setSelectedDate:(NSDate *)newSelectedDate animated:(BOOL)animated;

//滚动到某一日期的日历。
- (void)scrollToDate:(NSDate *)date animated:(BOOL)animated;

//清空所选的日期
- (void)clearAllDatePick;
//清空标志
@property (nonatomic, assign) BOOL clearDateTag;

@end

//允许委托通知当用户与之交互的日历。
@protocol DatepickerViewDelegate <NSObject>

@optional

//日期是由用户选定。
- (void)DatepickerDidSelectDate:(NSDate *)date;

//如果指定日期的日历应该使用自定义颜色
- (BOOL)DatepickerShouldUseCustomColorsForDate:(NSDate *)date;

//label自定义颜色添加日期
- (UIColor *)DatepickerCircleColorForDate:(NSDate *)date;

//一个自定义添加日期的文本颜色
- (UIColor *)DatepickerTextColorForDate:(NSDate *)date;
//完成选择返回
- (void )DatepickerSelectDoneBack:(NSMutableArray *)dateArray;
@end
