//
//  WJBaseCV.h
//  WJBlueLists
//
//  Created by wenjuan on 16/5/4.
//  Copyright © 2016年 wenjuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WJBaseCV : UIViewController

/**
 * 父类中的tableview
 */
@property (nonatomic, strong) UITableView *baseTableVC;

/**
 * 父类中的tableview 放数据源的数组
 */
@property (nonatomic, strong) NSMutableArray *tableDataArray;

/**
 *  tableView 的大小
 * @param  frame        tableview的大小
 * 
 */
- (void)tableViewFrame:(CGRect)frame;

@end
