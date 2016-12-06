//
//  LFlowListView.h
//  LFlowView
//
//  Created by 李姝睿 on 2016/12/5.
//  Copyright © 2016年 李姝睿. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LFlowListView;

// 协议
@protocol LFlowListViewDataSource <NSObject>
@required
- (NSInteger)numberOfFlowListView:(LFlowListView *)flowListView;

@end

@protocol LFlowListViewDelegate <NSObject>
@optional
- (void)flowListViewDidSelected:(LFlowListView *)flowListView atIndex:(NSInteger)index;

@end

@interface LFlowListView : UIView<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (nonatomic, assign) NSInteger currentIndex;
// 父流程数组
@property (nonatomic, strong) NSMutableArray *superFlowDataArray;
// 子流程数组
@property (nonatomic, strong) NSMutableArray *subFlowDataArray;

// 代理
@property (nonatomic, weak) id<LFlowListViewDataSource> dataSource;
@property (nonatomic, weak) id<LFlowListViewDelegate> delegate;

- (void)scrollToNextCell;
- (void)scrollToLastCell;
- (void)didScrollToCurrentCell;

@end
