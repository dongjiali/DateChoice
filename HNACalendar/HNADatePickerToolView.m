//
//  HNADatePickerToolView.m
//  HNACalendar
//
//  Created by curry on 14-3-8.
//  Copyright (c) 2014年 HNACalendar. All rights reserved.
//

#import "HNADatePickerToolView.h"

@interface HNADatePickerToolView()
{
    NSString *beginstring;
    NSString *endstring;
}
@end

@implementation HNADatePickerToolView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code//
    
        //添加起始日期label
        _beginDateLabel = [[UILabel alloc]init];
        [_beginDateLabel setTextAlignment:NSTextAlignmentCenter];
        _beginDateLabel.font = [UIFont systemFontOfSize:13];
        [self addSubview:_beginDateLabel];
        [_beginDateLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_beginDateLabel setBackgroundColor:[UIColor whiteColor]];
        
        //    //添加约束 自动适配
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_beginDateLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_beginDateLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_beginDateLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:0.3 constant:0]];
        [_beginDateLabel addConstraint:[NSLayoutConstraint constraintWithItem:_beginDateLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:44]];
        
        //添加终止日期label
        _endDateLabel = [[UILabel alloc]init];
        [_endDateLabel setTextAlignment:NSTextAlignmentLeft];
        _endDateLabel.font = [UIFont systemFontOfSize:13];
        [self addSubview:_endDateLabel];
        [_endDateLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_endDateLabel setBackgroundColor:[UIColor whiteColor]];
        
        [self  addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[_beginDateLabel(==0)]-0-[_endDateLabel(==0)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_beginDateLabel,_endDateLabel)]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_endDateLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_endDateLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:0.3 constant:0]];
        [_endDateLabel addConstraint:[NSLayoutConstraint constraintWithItem:_endDateLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:44]];
        
        //添加确定按键
        _DoneDateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_DoneDateButton setTitle:@"确    定" forState:0];
        [_DoneDateButton setTitleColor:[UIColor blackColor] forState:0];
        _DoneDateButton.backgroundColor = [UIColor whiteColor];
        [self addSubview:_DoneDateButton];
        [_DoneDateButton addTarget:self action:@selector(selectisDone) forControlEvents:UIControlEventTouchUpInside];
        [_DoneDateButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_DoneDateButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_DoneDateButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_DoneDateButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:0.4 constant:0]];
        [_DoneDateButton addConstraint:[NSLayoutConstraint constraintWithItem:_DoneDateButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:44]];
    }
    return self;
}

- (void)selectisDone
{
    _blockdate();
}

- (void)setDateValue:(NSMutableArray *)selectAllDates
{
    int count = selectAllDates.count ;
    if (count >0 ) {
        if (count >1) {
            beginstring = [self dateFormatterString:selectAllDates.firstObject];
            endstring = [NSString stringWithFormat:@"-  %@",[self dateFormatterString:selectAllDates.lastObject]];
        }
        else{
            beginstring =  [self dateFormatterString:selectAllDates.firstObject];
            endstring = @"";
        }
    }
    else
    {
        beginstring = @"";
        endstring = @"";
    }
    
    _beginDateLabel.text = beginstring;
    _endDateLabel.text = endstring;
}
//日期转换
- (NSString *)dateFormatterString:(NSDate *)date
{
        NSDateFormatter *DateFormatter = [[NSDateFormatter alloc] init];
    //中美时间转换
//        [_headerDateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
//        [_headerDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [DateFormatter setDateFormat:@"EEE"];
        NSString *weekString = [DateFormatter stringFromDate:date];
        [DateFormatter setDateFormat:@"MM月dd"];//设定时间格式,这里可以设置成自己需要的格式
        NSString *dateFormat = [DateFormatter stringFromDate:date];
    return [NSString stringWithFormat:@"%@ %@",weekString,dateFormat];
}

//block
-(void)selectDoneblock:(blockDateDnoe)block
{
    _blockdate = [block copy];
}

@end
