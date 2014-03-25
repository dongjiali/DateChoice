//
//  HNADatePIckerHeaderView.h
//  HNACalendar
//
//  Created by curry on 14-3-7.
//  Copyright (c) 2014年 HNACalendar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HNADatePIckerHeaderView : UICollectionReusableView
//显示月、年
@property (nonatomic, strong) UILabel *titleLabel;
//文本颜色显示
@property (nonatomic, strong) UIColor *textColor;
//分隔符之间的颜色名称和日期
@property (nonatomic, strong) UIColor *separatorColor;
@end
