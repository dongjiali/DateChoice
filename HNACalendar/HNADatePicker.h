//
//  HNADatePicker.h
//  HNACalendar
//
//  Created by curry on 14-3-7.
//  Copyright (c) 2014年 HNACalendar. All rights reserved.
//

#import <UIKit/UIKit.h>

//添加block 委托
typedef void (^blockDates)(NSString *firstDate,NSString *secondDate);

@interface HNADatePicker : UINavigationController
{
    blockDates _dateBlock;
}
@property (nonatomic,strong)UIColor *backgroundColor;
@property (nonatomic,strong)NSMutableArray *collectionDats;
- (void)requestDates:(NSArray *)datearray block:(blockDates)dateblock ;
@end
