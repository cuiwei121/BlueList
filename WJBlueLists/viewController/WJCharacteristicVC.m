//
//  WJCharacteristicVC.m
//  WJBlueLists
//
//  Created by wenjuan on 16/5/13.
//  Copyright © 2016年 wenjuan. All rights reserved.
//

#import "WJCharacteristicVC.h"
#import "OBDBluetooth.h"
#import "WJPeripheralCell.h"

@interface WJCharacteristicVC ()<OBDBluetoothDelegate>
@property (nonatomic, strong) NSMutableArray *sectionTitleArray;

@end

@implementation WJCharacteristicVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [OBDBluetooth shareOBDBluetooth].delegate = self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"特征";
    //创建头文件  tableview的头
    UIView * sectionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 320)];
    //    sectionView.backgroundColor = [UIColor orangeColor];
    UILabel * label = [[UILabel alloc]init];
    label.frame = CGRectMake(0, 0, SCREEN_WIDTH, 320);
    label.numberOfLines = 0;
    label.text = [NSString stringWithFormat:@"%@\n%@",[OBDBluetooth shareOBDBluetooth].peripheral.name,[OBDBluetooth shareOBDBluetooth].peripheral];
    
    [sectionView addSubview:label];
    [self.baseTableVC setTableHeaderView:sectionView];
}

#pragma mark - 属性 懒加载
- (NSMutableArray *)sectionTitleArray {
    if (!_sectionTitleArray) {
        _sectionTitleArray = [NSMutableArray array];
    }
    return _sectionTitleArray;
}





#pragma mark - tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
 
    [self.sectionTitleArray removeAllObjects];
    
    if (self.characteristic.properties & CBCharacteristicPropertyRead) {
        [self.sectionTitleArray addObject:@"读数据"];
    }
    if (self.characteristic.properties & CBCharacteristicPropertyWrite) {
       [self.sectionTitleArray addObject:@"写数据"];
    }
    if (self.characteristic.properties & CBCharacteristicPropertyWriteWithoutResponse) {
        [self.sectionTitleArray addObject:@"写无回复"];
    }
    if (self.characteristic.properties & CBCharacteristicPropertyNotify) {
        [self.sectionTitleArray addObject:@"notify"];
    }
    
    
    [self.sectionTitleArray addObject:@"特征属性值"];
    return  [self.sectionTitleArray count];
}

//每一个分区的头
- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *titleString = [self.sectionTitleArray objectAtIndex:section];
    return titleString;
}



- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 60;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    CBService *service = [self.sectonArray objectAtIndex:section];
//    return [service.characteristics count];
    
    if (section < [self.sectionTitleArray count] - 1) {
        if ([[self.sectionTitleArray objectAtIndex: section] isEqualToString:@"读数据"]) {
            
            NSMutableArray * mutalbeArray = [[OBDBluetooth shareOBDBluetooth].readDataDic objectForKey:self.characteristic.UUID];
            return [mutalbeArray count] + 1 ;
            
        }
        if ([[self.sectionTitleArray objectAtIndex: section] isEqualToString:@"写数据"]) {
            
            return 2;
        }
        
        return 2;
    }else {
        return [self.sectionTitleArray count] - 1;
    }
    
    

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = @"peripheralCell";
    WJPeripheralCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[WJPeripheralCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    if ([[self.sectionTitleArray objectAtIndex:indexPath.section] isEqualToString:@"特征属性值"]) {
        cell.titleLabel.text = [self.sectionTitleArray objectAtIndex:indexPath.row];
    }
    
    if ([[self.sectionTitleArray objectAtIndex:indexPath.section] isEqualToString:@"读数据"]) {
    
        if(indexPath.row == 0) {
            cell.titleLabel.text = @"读取数据";
        }else {
 
            NSMutableArray * mutalbeArray = [[OBDBluetooth shareOBDBluetooth].readDataDic objectForKey:self.characteristic.UUID];
            NSString * dataString = [NSString stringWithFormat:@"%@" ,[mutalbeArray objectAtIndex:indexPath.row - 1] ];
            cell.titleLabel.text = dataString;
            cell.titleLabel.font = WJFont(9);
//            NSString *textS = [[[OBDBluetooth shareOBDBluetooth]readDataDic]objectForKey:self.characteristic.UUID];
//            cell.titleLabel.text = [NSString stringWithFormat:@"%@",textS];
            LOG(@"读取数据=======: %@  == %@",[[[OBDBluetooth shareOBDBluetooth]readDataDic]objectForKey:self.characteristic.UUID],dataString);
        }
        
    }
    
    if ([[self.sectionTitleArray objectAtIndex:indexPath.section] isEqualToString:@"写数据"]) {
        if(indexPath.row == 0) {
            cell.titleLabel.text = @"写入数据";
        }else if(indexPath.row == 1){
            cell.titleLabel.text = @"1234";
//            NSString *textS = [[[OBDBluetooth shareOBDBluetooth]readDataDic]objectForKey:self.characteristic.UUID];
//            cell.titleLabel.text = [NSString stringWithFormat:@"%@",textS];
//            LOG(@"写入数据=======: %@   == %@",[[[OBDBluetooth shareOBDBluetooth]readDataDic]objectForKey:self.characteristic.UUID],textS);
        }
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([[self.sectionTitleArray objectAtIndex:indexPath.section] isEqualToString:@"读数据"]) {
        
        if(indexPath.row == 0) {
            [[OBDBluetooth shareOBDBluetooth] readCharacteristicValue:self.characteristic];
//            [self.baseTableVC reloadData];
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        }
        
    }
    
    if ([[self.sectionTitleArray objectAtIndex:indexPath.section] isEqualToString:@"写数据"]) {
        if(indexPath.row == 0) {
            [[OBDBluetooth shareOBDBluetooth]writeValue:@"66" andCharacteristic:self.characteristic];
            [self.baseTableVC reloadData];
        }
        
    }
    
}

- (void)readDataForString {
    LOG(@"特征读数据界面");
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [self.baseTableVC reloadData];
    });
    
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
