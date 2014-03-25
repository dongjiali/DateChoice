//
//  HNADatePickerFlowLayout.m
//  HNACalendar
//
//  Created by curry on 14-3-7.
//  Copyright (c) 2014年 HNACalendar. All rights reserved.
//

#import "HNADatePickerFlowLayout.h"
const CGFloat DateFlowLayoutMinInterItemSpacing = 0.0f;
const CGFloat DateFlowLayoutMinLineSpacing = 0.0f;
const CGFloat DateFlowLayoutInsetTop = 0.0f;
const CGFloat DateFlowLayoutInsetLeft = 0.0f;
const CGFloat DateFlowLayoutInsetBottom = 5.0f;
const CGFloat DateFlowLayoutInsetRight = 0.0f;
const CGFloat DateFlowLayoutHeaderHeight = 20.0f;

@implementation HNADatePickerFlowLayout

-(id)init
{
    self = [super init];
    if (self) {
        //定义自动布局 使全每个items自动适配屏幕大小
        self.minimumInteritemSpacing = DateFlowLayoutMinInterItemSpacing;
        self.minimumLineSpacing = DateFlowLayoutMinLineSpacing;
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.sectionInset = UIEdgeInsetsMake(DateFlowLayoutInsetTop,
                                             DateFlowLayoutInsetLeft,
                                             DateFlowLayoutInsetBottom,
                                             DateFlowLayoutInsetRight);
        self.headerReferenceSize = CGSizeMake(0, DateFlowLayoutHeaderHeight);
    }
    
    return self;
}

@end
