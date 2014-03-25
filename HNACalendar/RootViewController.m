//
//  RootViewController.m
//  HNACalendar
//
//  Created by curry on 14-3-5.
//  Copyright (c) 2014年 HNACalendar. All rights reserved.
//

#import "RootViewController.h"
#import "HNADatePicker.h"
@interface RootViewController ()
{
    UILabel *firstlabel;
    UILabel *secondlabel;
}
@end

@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //适配ios7
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
    }
    UIButton *button = [[UIButton alloc]init];
    [button setTitle:@"选择日期" forState:0];
    button.frame = CGRectMake(110, 110, 100, 100);
    button.backgroundColor = [UIColor blueColor];
    [button addTarget:self action:@selector(pushCalendar) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    
    firstlabel = [[UILabel alloc]initWithFrame:CGRectMake(100, 230, 200, 20)];
        [self.view addSubview:firstlabel];
    
    secondlabel = [[UILabel alloc]initWithFrame:CGRectMake(100, 270, 200, 20)];
        [self.view addSubview:secondlabel];
}

- (void)pushCalendar
{
    HNADatePicker *datepicker = [[HNADatePicker alloc]init];
//    datepicker.backgroundColor = [UIColor blueColor];
    [datepicker requestDates:nil block:^(NSString *firstDate, NSString *secondDate) {
//        NSLog(@"%@%@",firstDate,secondDate);
        firstlabel.text =firstDate ;
        secondlabel.text = secondDate;
    }];
    [self presentViewController:datepicker animated:YES completion:^{
        printf("yes");
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
