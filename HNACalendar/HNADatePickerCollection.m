//
//  HNADatePickerCollection.m
//  HNACalendar
//
//  Created by curry on 14-3-7.
//  Copyright (c) 2014年 HNACalendar. All rights reserved.
//

#import "HNADatePickerCollection.h"
#import "HNADatePickerCell.h"
#import "HNADatePIckerHeaderView.h"
#import "HNADatePickerFlowLayout.h"
#import "HNADatePickerToolView.h"
#import "deploymember.h"
@interface HNADatePickerCollection ()

@end

const NSUInteger DatePickerDaysPerWeek = 7;
const CGFloat DatePickerOverlaySize = 14.0f;

static NSString *HNADatePickerCellIdentifier = @"com.producteev.collection.cell.identifier";
static NSString *HNADatePIckerHeaderViewIdentifier = @"com.producteev.collection.header.identifier";


@interface HNADatePickerCollection () <HNADatePickerCellDelegate>

@property (nonatomic, strong) UILabel *overlayView;
@property (nonatomic, strong) UIView *weekView;
@property (nonatomic, strong) UILabel *dayOfWeekLabel;
@property (nonatomic, strong) HNADatePickerToolView *datePickerToolView;
@property (nonatomic, strong) NSDateFormatter *headerDateFormatter; //Will be used to format date in header view and on scroll.

@end


@implementation HNADatePickerCollection

//Explicitely @synthesize the var (it will create the iVar for us automatically as we redefine both getter and setter)
@synthesize firstDate = _firstDate;
@synthesize lastDate = _lastDate;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    //Force the creation of the view with the pre-defined Flow Layout.
    //Still possible to define a custom Flow Layout, if needed by using initWithCollectionViewLayout:
    self = [super initWithCollectionViewLayout:[[HNADatePickerFlowLayout alloc] init]];
    if (self) {
        // Custom initialization
        [self simpleCalendarCommonInit];
    }
    return self;
}

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        [self simpleCalendarCommonInit];
    }
    return self;
}

- (void)simpleCalendarCommonInit
{
    self.overlayView = [[UILabel alloc] init];
    self.weekView = [[UIView alloc]init];
    self.backgroundColor = [UIColor whiteColor];
    self.overlayTextColor = [UIColor blackColor];
}

#pragma mark - Accessors

- (NSDateFormatter *)headerDateFormatter;
{
    if (!_headerDateFormatter) {
        _headerDateFormatter = [[NSDateFormatter alloc] init];
        _headerDateFormatter.calendar = self.calendar;
        _headerDateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"yyyyLLLL" options:0 locale:[NSLocale currentLocale]];
    }
    return _headerDateFormatter;
}

- (NSCalendar *)calendar
{
    if (!_calendar) {
        _calendar = [NSCalendar currentCalendar];
    }
    return _calendar;
}

- (NSDate *)firstDate
{
    if (!_firstDate) {
        [self setFirstDate:[NSDate date]];
    }
    
    return _firstDate;
}

- (void)setFirstDate:(NSDate *)firstDate
{
    NSDateComponents *components = [self.calendar components:NSMonthCalendarUnit|NSYearCalendarUnit fromDate:firstDate];
    _firstDate = [self.calendar dateFromComponents:components];
}

- (NSDate *)lastDate
{
    if (!_lastDate) {
        NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
        offsetComponents.year = 1;
        [self setLastDate:[self.calendar dateByAddingComponents:offsetComponents toDate:self.firstDate options:0]];
    }
    return _lastDate;
}

- (void)setLastDate:(NSDate *)lastDate
{
    NSDateComponents *components = [self.calendar components:NSMonthCalendarUnit|NSYearCalendarUnit fromDate:lastDate];
    NSDate *firstOfMonth = [self.calendar dateFromComponents:components];
    
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    offsetComponents.month = 1;
    offsetComponents.day = -1;
    _lastDate = [self.calendar dateByAddingComponents:offsetComponents toDate:firstOfMonth options:0];
}

- (void)setSelectedDate:(NSDate *)newSelectedDate
{
    [self setSelectedDate:newSelectedDate animated:NO];
}

- (void)setSelectedDate:(NSDate *)newSelectedDate animated:(BOOL)animated
{
    //Test if selectedDate between first & last date
    NSDate *startOfDay = [self clampDate:newSelectedDate toComponents:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit];
    if (([startOfDay compare:self.firstDate] == NSOrderedAscending) || ([startOfDay compare:self.lastDate] == NSOrderedDescending)) {
        return;
    }
    
    [[self cellForItemAtDate:_selectedDate] setSelected:NO];
    [[self cellForItemAtDate:startOfDay] setSelected:YES];
    
    _selectedDate = startOfDay;
    
    NSIndexPath *indexPath = [self indexPathForCellAtDate:_selectedDate];
    [self.collectionView reloadItemsAtIndexPaths:@[ indexPath ]];
    
    [self scrollToDate:_selectedDate animated:animated];
    
    if ([self.delegate respondsToSelector:@selector(DatepickerDidSelectDate:)]) {
        [self.delegate DatepickerDidSelectDate:self.selectedDate];
    }
}

- (void)scrollToDate:(NSDate *)date animated:(BOOL)animated
{
    @try {
        NSIndexPath *selectedDateIndexPath = [self indexPathForCellAtDate:date];
        
        if (![[self.collectionView indexPathsForVisibleItems] containsObject:selectedDateIndexPath]) {
            
            NSIndexPath *sectionIndexPath = [NSIndexPath indexPathForItem:0 inSection:selectedDateIndexPath.section];
            UICollectionViewLayoutAttributes *sectionLayoutAttributes = [self.collectionView layoutAttributesForItemAtIndexPath:sectionIndexPath];
            CGPoint origin = sectionLayoutAttributes.frame.origin;
            origin.x = 0;
            origin.y -= (DateFlowLayoutHeaderHeight + DateFlowLayoutInsetTop);
            [self.collectionView setContentOffset:origin animated:animated];
        }
    }
    @catch (NSException *exception) {
        NSInteger section = [self sectionForDate:date];
        NSIndexPath *sectionIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
        [self.collectionView scrollToItemAtIndexPath:sectionIndexPath atScrollPosition:UICollectionViewScrollPositionTop animated:animated];
    }
}

- (void)setOverlayTextColor:(UIColor *)overlayTextColor
{
    _overlayTextColor = overlayTextColor;
    if (self.overlayView) {
        [self.overlayView setTextColor:self.overlayTextColor];
    }
}

#pragma mark - View LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.selectedAllDate = [NSMutableArray array];
    self.collectioncells = [NSMutableArray array];
    
    //添加周视图
    [self.weekView setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:0.1]];
    [self.view addSubview:self.weekView];
    //禁止自动转换AutoresizingMask
    [self.weekView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSDictionary *weekViewDictionary = @{@"weekView": self.weekView};
    NSDictionary *weekmetricsDictionary = @{@"oweekViewHeight": [NSNumber numberWithFloat:20]};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[weekView]|" options:NSLayoutFormatAlignAllTop metrics:nil views:weekViewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[weekView(==oweekViewHeight)]" options:NSLayoutFormatAlignAllTop metrics:weekmetricsDictionary views:weekViewDictionary]];    
    [self addWeekViewtoSelfView];

    
    //添加日历视图
    self.collectionView.frame = CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height - 64);
    [self.collectionView registerClass:[HNADatePickerCell class] forCellWithReuseIdentifier:HNADatePickerCellIdentifier];
    [self.collectionView registerClass:[HNADatePIckerHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HNADatePIckerHeaderViewIdentifier];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView setBackgroundColor:self.backgroundColor];
    
    
    //添加导航view
    [self.overlayView setBackgroundColor:[UIColor whiteColor]];
    [self.overlayView setFont:[UIFont boldSystemFontOfSize:DatePickerOverlaySize]];
    [self.overlayView setTextColor:self.overlayTextColor];
    [self.overlayView setAlpha:0.0];
    [self.overlayView setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:self.overlayView];
    self.overlayView.hidden = YES;
    [self.overlayView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSDictionary *viewsDictionary = @{@"overlayView": self.overlayView};
    NSDictionary *metricsDictionary = @{@"overlayViewHeight": [NSNumber numberWithFloat:DateFlowLayoutHeaderHeight]};
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[overlayView]|" options:NSLayoutFormatAlignAllTop metrics:nil views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[overlayView(==overlayViewHeight)]" options:NSLayoutFormatAlignAllTop metrics:metricsDictionary views:viewsDictionary]];
    
    //添加toolbar视图
    self.datePickerToolView = [[HNADatePickerToolView alloc]init];
    [self.view addSubview:self.datePickerToolView];
    [self.datePickerToolView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.datePickerToolView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.datePickerToolView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.datePickerToolView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    //设置最小高度为
    [self.datePickerToolView addConstraint:[NSLayoutConstraint constraintWithItem:self.datePickerToolView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:44]];
    [self.datePickerToolView selectDoneblock:^{
        //日期确定按钮完成，保存数据
        if ([self.delegate respondsToSelector:@selector(DatepickerSelectDoneBack:)]) {
            [self.delegate DatepickerSelectDoneBack:self.selectedAllDate];
        }
    }];

    //添加手势
    UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [self.view addGestureRecognizer:gestureRecognizer];
    [gestureRecognizer setMinimumNumberOfTouches:1];
    [gestureRecognizer setMaximumNumberOfTouches:1];
    
    //iOS7 Only: We don't want the calendar to go below the status bar (&navbar if there is one).
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

- (void)addWeekViewtoSelfView
{
    //获取星期周label
    NSMutableArray *labels = [NSMutableArray array];
    for (NSString *day in [self getDaysOfTheWeek]) {
        UILabel *lastWeekLabel = [[UILabel alloc] init];
        lastWeekLabel.text = [day uppercaseString];
        lastWeekLabel.textColor = [UIColor redColor];
        [lastWeekLabel setTextAlignment:NSTextAlignmentCenter];
        lastWeekLabel.shadowColor = [UIColor whiteColor];
        lastWeekLabel.shadowOffset = CGSizeMake(0, 1);
        [lastWeekLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
         [self.weekView addConstraint:[NSLayoutConstraint constraintWithItem:lastWeekLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_dayOfWeekLabel attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
        [self.weekView addConstraint:[NSLayoutConstraint constraintWithItem:lastWeekLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.weekView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        [self.weekView addConstraint:[NSLayoutConstraint constraintWithItem:lastWeekLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.weekView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        [self.weekView addConstraint:[NSLayoutConstraint constraintWithItem:lastWeekLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.weekView attribute:NSLayoutAttributeWidth multiplier:1/7.0 constant:0]];
        [lastWeekLabel addConstraint:[NSLayoutConstraint constraintWithItem:lastWeekLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:20]];
        [self.weekView  addSubview:lastWeekLabel];
        _dayOfWeekLabel = lastWeekLabel;
        [labels addObject:lastWeekLabel];
    }
}

#pragma mark - slect allcells
- (void) handleGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    float pointerX = [gestureRecognizer locationInView:self.collectionView].x;
    float pointerY = [gestureRecognizer locationInView:self.collectionView].y;
    
    for (HNADatePickerCell *cell in self.collectionView.visibleCells) {
        float cellSX = cell.frame.origin.x;
        float cellEX = cell.frame.origin.x + cell.frame.size.width;
        float cellSY = cell.frame.origin.y;
        float cellEY = cell.frame.origin.y + cell.frame.size.height;
        
        if (pointerX > cellSX && pointerX < cellEX && pointerY > cellSY && pointerY < cellEY)
        {
            NSIndexPath *touchOver = [self.collectionView indexPathForCell:cell];
            
            if (self.lastAccessed != touchOver)
            {
                if ([self.selectedAllDate containsObject:cell.date]){
                    [self selectCellForCollectionView:self.collectionView atIndexPath:touchOver];
                }else{
                    if (cell.dayLabel.text.length > 0) {
                    [self selectCellForCollectionView:self.collectionView atIndexPath:touchOver];
                    }
                }
            }
            self.lastAccessed = touchOver;
        }
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        self.lastAccessed = nil;
        self.collectionView.scrollEnabled = YES;
    }
}
//选择滑动到cell
- (void) selectCellForCollectionView:(UICollectionView *)collection atIndexPath:(NSIndexPath *)indexPath
{
    [collection selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    [self collectionView:collection didSelectItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.selected = NO;
}
#pragma mark - Rotation Handling

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.collectionView.collectionViewLayout invalidateLayout];
}

#pragma mark - Collection View Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.calendar components:NSMonthCalendarUnit fromDate:self.firstDate toDate:self.lastDate options:0].month + 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSDate *firstOfMonth = [self firstOfMonthForSection:section];
    NSRange rangeOfWeeks = [self.calendar rangeOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:firstOfMonth];
    return (rangeOfWeeks.length * DatePickerDaysPerWeek);
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HNADatePickerCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:HNADatePickerCellIdentifier
                                                                                     forIndexPath:indexPath];
    cell.delegate = self;
    cell.choiceDaysTag = self.selectDaysTag;
    NSDate *firstOfMonth = [self firstOfMonthForSection:indexPath.section];
    NSDate *cellDate = [self dateForCellAtIndexPath:indexPath];
    
    NSDateComponents *cellDateComponents = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit fromDate:cellDate];
    NSDateComponents *firstOfMonthsComponents = [self.calendar components:NSMonthCalendarUnit fromDate:firstOfMonth];
    
    BOOL isToday = NO;
    BOOL isSelected = NO;
    BOOL isCustomDate = NO;
    BOOL isearlier = NO;
    
    if (cellDateComponents.month == firstOfMonthsComponents.month) {
        isSelected = ([self isSelectedDate:cellDate] && (indexPath.section == [self sectionForDate:cellDate]) && !self.clearDateTag);
        isToday = [self isTodayDate:cellDate];
        isearlier = [self isEarlierDate:cellDate];
        [cell setDate:cellDate calendar:self.calendar];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(DatepickerTextColorForDate:)]) {
            isCustomDate = [self.delegate DatepickerShouldUseCustomColorsForDate:cellDate];
        }
    } else {
        [cell setDate:nil calendar:nil];
    }
    
    if (isearlier) {
        [cell setIsEarlier:isearlier];
    }
    
    if (isToday) {
        [cell setIsToday:isToday];
    }
    
    if (isSelected) {
        [cell setSelected:isSelected];
//        [self.collectioncells addObject:cell];
    }
    
    if (isCustomDate) {
        [cell refreshCellColors];
    }
    
    
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *firstOfMonth = [self firstOfMonthForSection:indexPath.section];
    NSDate *cellDate = [self dateForCellAtIndexPath:indexPath];
    
    NSDateComponents *cellDateComponents = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit fromDate:cellDate];
    NSDateComponents *firstOfMonthsComponents = [self.calendar components:NSMonthCalendarUnit fromDate:firstOfMonth];
    
    return (cellDateComponents.month == firstOfMonthsComponents.month);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  
    self.selectedDate = [self dateForCellAtIndexPath:indexPath];
    
    self.clearDateTag = NO;
    if (!self.selectDaysTag && ![self isEarlierDate: self.selectedDate]) {
        if (self.selectedAllDate.count > 0) {
            if ([self getSelectDateSiteInDatelist] == EarlierDate) {
                [self.selectedAllDate removeAllObjects];
                [self.selectedAllDate addObject:self.selectedDate];
            }
            else [self getDateBetween:[self.selectedAllDate firstObject] endDate:self.selectedDate];
        }
        else [self.selectedAllDate addObject:self.selectedDate];
        //刷新UI
        [self resetSelectedCells];
    }
    //设置label日期
    [self setSelectDateLabelText:self.selectedAllDate];
}

//刷新view 显示出选择的日期
- (void)resetSelectedCells
{
    for (HNADatePickerCell *cell in self.collectionView.visibleCells)
    {
            if ([self.selectedAllDate containsObject:cell.date])
            {
                cell.dayLabel.backgroundColor = CircleSelectedColor;
                cell.dayLabel.textColor = TextSelectedColor;
            }
            else
                [self setTodaycolordata:cell];
    }
}

//清空所有选择的日期
- (void)clearAllDatePick
{
    for (HNADatePickerCell *cell in self.collectionView.visibleCells)
    [self setTodaycolordata:cell];
    self.selectedDate = nil;
    self.clearDateTag = YES;
    [self.collectioncells removeAllObjects];
    [self.selectedAllDate removeAllObjects];
    //设置label日期
    [self setSelectDateLabelText:self.selectedAllDate];
}

//设置label日期
- (void)setSelectDateLabelText:(NSMutableArray *)array
{
    [self.datePickerToolView setDateValue:array];
}

//刷新后设置今天的颜色
- (void)setTodaycolordata:(HNADatePickerCell *)cell
{
    if ([self isTodayDate:cell.date]) {
        cell.dayLabel.backgroundColor = CircleTodayColor;
        cell.dayLabel.textColor = TextTodayColor;
    }else
    if ([self isEarlierDate:cell.date]) {
            cell.dayLabel.backgroundColor = CircleEearlierColor;
            cell.dayLabel.textColor = TextEearlierColor;
        }else
        {
        cell.dayLabel.backgroundColor = CircleDefaultColor;
        cell.dayLabel.textColor = TextDefaultColor;
        }
}

// 获取选择日期在全部日期列表中的位置
- (NSInteger)getSelectDateSiteInDatelist
{
    NSDate *begin = [self.selectedAllDate firstObject];
    NSDate *select = self.selectedDate;
    NSDate *end = [self.selectedAllDate lastObject];
    
    if ([[select earlierDate:begin] isEqualToDate:select] && [[select laterDate:end] isEqualToDate:end]) {
        return EarlierDate; //以前
    }
    
    if ([[select earlierDate:begin] isEqualToDate:begin] && [[select laterDate:end] isEqualToDate:end]) {
        return MiddleDate; //中间
    }
    
    if ([[select earlierDate:begin] isEqualToDate:begin] && [[select laterDate:end] isEqualToDate:select]) {
        return LaterDate; //以后
    }
    return -1;
}


// 校验选择日期是否在整个日期列表中
- (BOOL)beginDate:(NSDate *)begin endDate:(NSDate *)end selectDate:(NSDate *)date
{
    return ([[date earlierDate:begin] isEqualToDate:begin] && [[date laterDate:end] isEqualToDate:end]);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        HNADatePIckerHeaderView *headerView = [self.collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HNADatePIckerHeaderViewIdentifier forIndexPath:indexPath];
        
        headerView.titleLabel.text = [self.headerDateFormatter stringFromDate:[self firstOfMonthForSection:indexPath.section]].uppercaseString;
        
        headerView.layer.shouldRasterize = YES;
        headerView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        
        return headerView;
    }
    
    return nil;
}

#pragma mark - Animation



#pragma mark - getDatebetween
- (void)getDateBetween:(NSDate *)begindate endDate:(NSDate *)enddate
{
    [self.selectedAllDate  removeAllObjects];
    
    [self.selectedAllDate  addObject:begindate];
    NSTimeInterval a_day = 24*60*60;
    NSDate *nextDay = begindate;
    while (1) {
        nextDay = [NSDate dateWithTimeInterval:a_day sinceDate:nextDay];
        //添加数组中
        if ([[nextDay laterDate:enddate] isEqualToDate:enddate]) {
            [self.selectedAllDate addObject:nextDay];
        }else break;
    }
}

#pragma mark - UICollectionViewFlowLayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat itemWidth = floorf(CGRectGetWidth(self.collectionView.bounds) / DatePickerDaysPerWeek);
    
    return CGSizeMake(itemWidth, itemWidth);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    //We only display the overlay view if there is a vertical velocity
    if ( fabsf(velocity.y) > 0.0f) {
        if (self.overlayView.alpha < 1.0) {
            [UIView animateWithDuration:0.1 animations:^{
                [self.overlayView setAlpha:1.0];
            }];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSTimeInterval delay = (decelerate) ? 1.5 : 0.0;
    [self performSelector:@selector(hideOverlayView) withObject:nil afterDelay:delay];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //Update Content of the Overlay View
    NSArray *indexPaths = [self.collectionView indexPathsForVisibleItems];
    //indexPaths is not sorted
    NSArray *sortedIndexPaths = [indexPaths sortedArrayUsingSelector:@selector(compare:)];
    NSIndexPath *firstIndexPath = [sortedIndexPaths firstObject];
    
    self.overlayView.text = [self.headerDateFormatter stringFromDate:[self firstOfMonthForSection:firstIndexPath.section]];
}

- (void)hideOverlayView
{
    [UIView animateWithDuration:0.1 animations:^{
        [self.overlayView setAlpha:0.0];
    }];
}

#pragma mark -
#pragma mark - Calendar calculations

- (NSDate *)clampDate:(NSDate *)date toComponents:(NSUInteger)unitFlags
{
    NSDateComponents *components = [self.calendar components:unitFlags fromDate:date];
    return [self.calendar dateFromComponents:components];
}

- (BOOL)isTodayDate:(NSDate *)date
{
    return [self clampAndCompareDate:date withReferenceDate:[NSDate date]];
}

- (BOOL)isEarlierDate:(NSDate *)date
{
    if ([self isTodayDate:date]) {
        return NO;
    }
    return [date compare:[NSDate date]] == NSOrderedAscending;
}

- (BOOL)isSelectedDate:(NSDate *)date
{
    if ([self.selectedAllDate containsObject:date]) {
        return YES;
    }
    if (!self.selectedDate) {
        return NO;
    }
    return [self clampAndCompareDate:date withReferenceDate:self.selectedDate];
}

- (BOOL)clampAndCompareDate:(NSDate *)date withReferenceDate:(NSDate *)referenceDate
{
    NSDate *refDate = [self clampDate:referenceDate toComponents:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit)];
    NSDate *clampedDate = [self clampDate:date toComponents:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit)];
    
    return [refDate isEqualToDate:clampedDate];
}

#pragma mark - Collection View / Calendar Methods

- (NSDate *)firstOfMonthForSection:(NSInteger)section
{
    NSDateComponents *offset = [NSDateComponents new];
    offset.month = section;
    
    return [self.calendar dateByAddingComponents:offset toDate:self.firstDate options:0];
}

- (NSInteger)sectionForDate:(NSDate *)date
{
    return [self.calendar components:NSMonthCalendarUnit fromDate:self.firstDate toDate:date options:0].month;
}


- (NSDate *)dateForCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *firstOfMonth = [self firstOfMonthForSection:indexPath.section];
    NSInteger ordinalityOfFirstDay = [self.calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSWeekCalendarUnit forDate:firstOfMonth];
    NSDateComponents *dateComponents = [NSDateComponents new];
    dateComponents.day = (1 - ordinalityOfFirstDay) + indexPath.item;
    
    return [self.calendar dateByAddingComponents:dateComponents toDate:firstOfMonth options:0];
}


- (NSIndexPath *)indexPathForCellAtDate:(NSDate *)date
{
    if (!date) {
        return nil;
    }
    NSInteger section = [self sectionForDate:date];
    
    NSDate *firstOfMonth = [self firstOfMonthForSection:section];
    NSInteger ordinalityOfFirstDay = [self.calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSWeekCalendarUnit forDate:firstOfMonth];
    NSDateComponents *dateComponents = [self.calendar components:NSDayCalendarUnit fromDate:date];
    NSDateComponents *firstOfMonthComponents = [self.calendar components:NSDayCalendarUnit fromDate:firstOfMonth];
    NSInteger item = (dateComponents.day - firstOfMonthComponents.day) - (1 - ordinalityOfFirstDay);

    return [NSIndexPath indexPathForItem:item inSection:section];
}

- (HNADatePickerCell *)cellForItemAtDate:(NSDate *)date
{
    return (HNADatePickerCell *)[self.collectionView cellForItemAtIndexPath:[self indexPathForCellAtDate:date]];
}

#pragma mark - Calendar helpers

- (NSDate *)firstDayOfMonthContainingDate:(NSDate *)date {
    NSDateComponents *comps = [self.calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:date];
    [comps setDay:1];
    return [self.calendar dateFromComponents:comps];
}

- (NSArray *)getDaysOfTheWeek {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    // adjust array depending on which weekday should be first
    NSArray *weekdays = [dateFormatter shortWeekdaySymbols];
    NSUInteger firstWeekdayIndex = [self.calendar firstWeekday] -1;
    if (firstWeekdayIndex > 0)
    {
        weekdays = [[weekdays subarrayWithRange:NSMakeRange(firstWeekdayIndex, 7-firstWeekdayIndex)]
                    arrayByAddingObjectsFromArray:[weekdays subarrayWithRange:NSMakeRange(0,firstWeekdayIndex)]];
    }
    return weekdays;
}

#pragma mark HNADatePickerCellDelegate

- (BOOL)DatePickerCell:(HNADatePickerCell *)cell shouldUseCustomColorsForDate:(NSDate *)date
{
    if ([self.delegate respondsToSelector:@selector(DatepickerShouldUseCustomColorsForDate:)]) {
        return [self.delegate DatepickerShouldUseCustomColorsForDate:date];
    }
    return NO;
}

- (UIColor *)DatePickerCell:(HNADatePickerCell *)cell circleColorForDate:(NSDate *)date
{
    if ([self.delegate respondsToSelector:@selector(DatepickerCircleColorForDate:)]) {
        return [self.delegate DatepickerCircleColorForDate:date];
    }
    return nil;
}

- (UIColor *)DatePickerCell:(HNADatePickerCell *)cell textColorForDate:(NSDate *)date
{
    if ([self.delegate respondsToSelector:@selector(DatepickerTextColorForDate:)]) {
        return [self.delegate DatepickerTextColorForDate:date];
    }
    return nil;
}
@end
