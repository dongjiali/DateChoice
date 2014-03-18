//
//  HNADatePickerToolView.h
//  HNACalendar
//
//  Created by 董家力 on 14-3-8.
//  Copyright (c) 2014年 HNACalendar. All rights reserved.
//

#import <UIKit/UIKit.h>
//添加block 委托
typedef void (^blockDateDnoe)();

@interface HNADatePickerToolView : UIView
{
    blockDateDnoe _blockdate;
}

//起始日期、结束日期、提示语标
@property (nonatomic, strong) UILabel *beginDateLabel;
@property (nonatomic, strong) UILabel *endDateLabel;
@property (nonatomic, strong) UILabel *promptDateLabel;

//确认
@property (nonatomic, strong) UIButton *DoneDateButton;
//分隔符之间的颜色名称和日期
@property (nonatomic, strong) UIColor *separatorColor;
- (void)setDateValue:(NSMutableArray *)selectAllDates;
//注册
-(void)selectDoneblock:(blockDateDnoe)block;
@end
