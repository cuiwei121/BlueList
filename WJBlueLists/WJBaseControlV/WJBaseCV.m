//
//  WJBaseCV.m
//  WJBlueLists
//
//  Created by wenjuan on 16/5/4.
//  Copyright © 2016年 wenjuan. All rights reserved.
//

#import "WJBaseCV.h"
#import "WJBaseCell.h"

@interface WJBaseCV ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation WJBaseCV

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self tableViewFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    
    
}

#pragma mark - 属相 懒加载
- (UITableView *)baseTableVC {

    if (!_baseTableVC) {
        _baseTableVC = [[UITableView alloc]init];
        _baseTableVC.dataSource = self;
        _baseTableVC.delegate = self;
        _baseTableVC.separatorStyle = UITableViewCellAccessoryNone;
      
    }
    return _baseTableVC;
}


- (NSMutableArray *)tableDataArray {

    if (!_tableDataArray) {
        _tableDataArray = [NSMutableArray array];
    }
    return _tableDataArray;
}



#pragma mark - 本类的方法

- (void)tableViewFrame:(CGRect)frame {
    self.baseTableVC.frame = frame;
    [self.view addSubview:_baseTableVC];
}


#pragma mark - tableview 代理方法
 
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableDataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = @"baseCell";
    WJBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[WJBaseCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
