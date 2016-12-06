//
//  LFlowListView.m
//  LFlowView
//
//  Created by 李姝睿 on 2016/12/5.
//  Copyright © 2016年 李姝睿. All rights reserved.
//

#define kHeaderViewHeight 40.f
#define kButtonWidth 25.f
#define kLeftAndRightOffSet 10.f
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#import "LFlowListView.h"
#import "LFlowCollectionViewCell.h"


@interface LFlowListView ()

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *selectedBgView;

@property (nonatomic, assign) CGFloat space; // 按钮间的间距
@property (nonatomic, assign) NSInteger count; // 按钮总数
@property (nonatomic, assign) CGFloat contentOffSetX;
@property (nonatomic, assign) BOOL isPressButton;

@end
@implementation LFlowListView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initData];
        [self createCollectionView];
    }
    return self;
}

- (void)initData {
    _isPressButton = NO;
    _subFlowDataArray = [NSMutableArray array];
}

- (void)createCollectionView {
    self.backgroundColor = [UIColor whiteColor];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height - kHeaderViewHeight);
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, kHeaderViewHeight, self.bounds.size.width, self.bounds.size.height - kHeaderViewHeight) collectionViewLayout:flowLayout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_collectionView];
    
    [_collectionView registerClass:[LFlowCollectionViewCell class] forCellWithReuseIdentifier:@"LFlowCollectionViewCell"];
}

- (void)setDataSource:(id<LFlowListViewDataSource>)dataSource {
    _dataSource = dataSource;
    [self loadHeaderData];
}

- (void)loadHeaderData {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, kHeaderViewHeight)];
    headerView.backgroundColor = [UIColor whiteColor];
    [self addSubview:headerView];
    
    _count = [_dataSource numberOfFlowListView:self];
    // count为1时_space算出来为负值导致崩溃
    if (_count == 1) {
        _space = 0;
    } else {
        _space = (SCREEN_WIDTH - kLeftAndRightOffSet * 2 - (_count * kButtonWidth)) / (_count - 1);
    }
    
    UIBezierPath *maskPath = [UIBezierPath bezierPath];
    for (NSInteger i = 0; i < _count; i ++) {
        // 画圆圈
        [maskPath addArcWithCenter:CGPointMake(kLeftAndRightOffSet + kButtonWidth / 2 + (i * (_space + kButtonWidth)), kHeaderViewHeight / 2) radius:kButtonWidth / 2 startAngle:0.f endAngle:M_PI * 2 clockwise:YES];
        if (i < _count - 1) {
            // 画矩形
            CGFloat x = kLeftAndRightOffSet + kButtonWidth + (kButtonWidth + _space) * i;
            [maskPath moveToPoint:CGPointMake(x, kHeaderViewHeight / 2 - 3)];
            [maskPath addLineToPoint:CGPointMake(x + _space, kHeaderViewHeight / 2 - 3)];
            [maskPath addLineToPoint:CGPointMake(x + _space, kHeaderViewHeight / 2 + 3)];
            [maskPath addLineToPoint:CGPointMake(x, kHeaderViewHeight / 2 + 3)];
            [maskPath closePath];
        }
    }
    // 遮盖层
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = maskPath.CGPath;
    maskLayer.frame = headerView.bounds;
    maskLayer.backgroundColor = [UIColor clearColor].CGColor;
    headerView.layer.mask = maskLayer;
    // 背景层
    CAShapeLayer *bgLayer = [CAShapeLayer layer];
    bgLayer.path = maskPath.CGPath;
    bgLayer.frame = headerView.bounds;
    bgLayer.fillColor = [UIColor lightGrayColor].CGColor;
    [headerView.layer addSublayer:bgLayer];
    
    _selectedBgView = [[UIView alloc] initWithFrame:CGRectMake(10 + (_currentIndex * (kButtonWidth + _space)), (kHeaderViewHeight - kButtonWidth) / 2, kButtonWidth, kButtonWidth)];
    _selectedBgView.backgroundColor = [UIColor redColor];
    [headerView addSubview:_selectedBgView];
    
    for (NSInteger i = 0; i < _count; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor = [UIColor clearColor];
        btn.frame = CGRectMake(10 + (kButtonWidth + _space) * i, (kHeaderViewHeight - kButtonWidth) / 2, kButtonWidth, kButtonWidth);
        [btn setTitle:[NSString stringWithFormat:@"%zd",i + 1] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.tag = i + 100;
        [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:btn];
    }
}

- (void)btnClicked:(UIButton *)btn {
    _currentIndex = btn.tag - 100;
    [self didScrollToCurrentCell];
    [self didSelected];
}

- (void)didScrollToCurrentCell {
    _isPressButton = YES;
    [UIView animateWithDuration:0.5f animations:^{
        CGRect frame = _selectedBgView.frame;
        frame.origin.x = 10 + _currentIndex * (kButtonWidth + _space);
        _selectedBgView.frame = frame;
    }];
    _collectionView.contentOffset = CGPointMake(_currentIndex * self.bounds.size.width, 0);
    _isPressButton = NO;
}

- (void)didSelected {
    if ([_delegate respondsToSelector:@selector(flowListViewDidSelected:atIndex:)]) {
        [_delegate flowListViewDidSelected:self atIndex:_currentIndex];
    }
}
#pragma mark UICollectionView Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LFlowCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LFlowCollectionViewCell" forIndexPath:indexPath];
    if (cell) {
        cell.contentView.backgroundColor = [UIColor colorWithRed:(arc4random()%256)/255.0 green:(arc4random()%256)/255.0 blue:(arc4random()%256)/255.0 alpha:1];
    }
    return cell;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _contentOffSetX = scrollView.contentOffset.x;
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (! _isPressButton) {
        CGFloat scale = scrollView.contentOffset.x / (scrollView.contentSize.width - self.bounds.size.width);
        CGRect frame = _selectedBgView.frame;
        frame.origin.x = 10 + (self.bounds.size.width - kButtonWidth - 10 * 2) * scale;
        _selectedBgView.frame = frame;
        
        CGFloat index = scrollView.contentOffset.x / scrollView.frame.size.width;
        NSInteger temp = 0;
        BOOL isScrollLeft;
        // 向右滚动
        if (scrollView.contentOffset.x > _contentOffSetX) {
            isScrollLeft = NO;
            temp = scrollView.contentOffset.x - _contentOffSetX;
        } else { // 向左滚动
            isScrollLeft = YES;
            temp = _contentOffSetX - scrollView.contentOffset.x;
        }
        
        if (temp >= self.bounds.size.width - 70) {
            _contentOffSetX = self.bounds.size.width * index;
            if (isScrollLeft) {
                _currentIndex = index;
            } else {
                _currentIndex = index + 1;
            }
            [self didSelected];
        }
    }
}

- (void)scrollToNextCell {
    if (_currentIndex < _count - 1) {
        _currentIndex ++;
        [self didScrollToCurrentCell];
    }
}

- (void)scrollToLastCell {
    if (_currentIndex > 0) {
        _currentIndex --;
        [self didScrollToCurrentCell];
    }
}

- (void)setSuperFlowDataArray:(NSMutableArray *)superFlowDataArray {
    _superFlowDataArray = superFlowDataArray;
    
}

@end
