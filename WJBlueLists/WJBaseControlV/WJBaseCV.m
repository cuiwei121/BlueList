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
        _baseTableVC = [[UITableView alloc]initWithFrame:CGRectZero style: UITableViewStyleGrouped];
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

-(void)setBarItem {
    //设置左侧返回按钮
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(11, 11, 22, 22)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    backButton.tag = -1;
//    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backItem];
}

//导航栏上的BarButtonItem的响应事件
-(void)onClick:(id)sender {
    UIButton * btn = (UIButton*)sender;
    if (btn.tag ==-1)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
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
