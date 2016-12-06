//
//  ViewController.m
//  LFlowView
//
//  Created by 李姝睿 on 2016/12/5.
//  Copyright © 2016年 李姝睿. All rights reserved.
//

#import "ViewController.h"
#import "LFlowListView.h"

@interface ViewController ()<LFlowListViewDelegate, LFlowListViewDataSource>

@property (nonatomic, strong) LFlowListView *flowListView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _flowListView = [[LFlowListView alloc] initWithFrame:CGRectMake(0, 50, self.view.bounds.size.width, self.view.bounds.size.height - 50)];
    _flowListView.dataSource = self;
    _flowListView.delegate = self;
    _flowListView.currentIndex = 2;
    [_flowListView didScrollToCurrentCell];
    [self.view addSubview:_flowListView];
}

- (NSInteger)numberOfFlowListView:(LFlowListView *)flowListView {
    return 5;
}

- (void)flowListViewDidSelected:(LFlowListView *)flowListView atIndex:(NSInteger)index {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
