//
//  WJPeripheralVC.m
//  WJBlueLists
//
//  Created by wenjuan on 16/5/9.
//  Copyright © 2016年 wenjuan. All rights reserved.
//

#import "WJPeripheralVC.h"
#import "WJPeripheralCell.h"

@interface WJPeripheralVC ()

@end

@implementation WJPeripheralVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"首页";
    self.tableDataArray = [@[@"123",@"234",@"345",@"456"]mutableCopy];
    [self.baseTableVC reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}




#pragma mark - tableview 代理方法

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = @"peripheralCell";
    WJPeripheralCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[WJPeripheralCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.titleLabel.text = [self.tableDataArray objectAtIndex:indexPath.row];
    
    return cell;
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
