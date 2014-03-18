//
//  HNADatePicker.m
//  HNACalendar
//
//  Created by 董家力 on 14-3-7.
//  Copyright (c) 2014年 HNACalendar. All rights reserved.
//

#import "HNADatePicker.h"
#import "HNADatePickerCollection.h"

@interface HNADatePicker()<DatepickerViewDelegate>
{
    HNADatePickerCollection *DatePicker;
}
@end

@implementation HNADatePicker

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init
{
    DatePicker = [[HNADatePickerCollection alloc]init];
    DatePicker.delegate = self;
    DatePicker.selectDaysTag = NO;
    if (self = [super initWithRootViewController:DatePicker]) {
        DatePicker.title = @"日期选择";
        //返回按钮
        UIBarButtonItem *backController = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(backController)];
        backController.tintColor = [UIColor redColor];
        DatePicker.navigationItem.leftBarButtonItem = backController;
        //清空按钮
        UIBarButtonItem *clearDates = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(clearDatepick)];
        clearDates.tintColor = [UIColor redColor];
        DatePicker.navigationItem.rightBarButtonItem = clearDates;
    }
    return self;
}

- (void)backController
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)clearDatepick
{
    // clear
    [DatePicker clearAllDatePick];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)DatepickerSelectDoneBack:(NSMutableArray *)dateArray
{
    NSString *str1 = [self dateFormatterString:[dateArray firstObject]];
    NSString *str2 = [self dateFormatterString:[dateArray lastObject]];
    _dateBlock(str1,str2);
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (NSString *)dateFormatterString:(NSDate *)date
{
    NSDateFormatter *DateFormatter = [[NSDateFormatter alloc] init];
    //中美时间转换
    //        [_headerDateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    //        [_headerDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [DateFormatter setDateFormat:@"EEE"];
    NSString *weekString = [DateFormatter stringFromDate:date];
    [DateFormatter setDateFormat:@"YYYY-MM-dd"];//设定时间格式,这里可以设置成自己需要的格式
    NSString *dateFormat = [DateFormatter stringFromDate:date];
    return [NSString stringWithFormat:@"%@ %@",weekString,dateFormat];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
        self.navigationBar.barTintColor = backgroundColor;
}


- (void)requestDates:(NSArray *)datearray block:(blockDates)dateblock
{
    _dateBlock = [dateblock copy];
//    self.collectionDats = [NSMutableArray arrayWithObject:datearray];
}

@end
