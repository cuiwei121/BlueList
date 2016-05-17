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
#import "WJCharacteristicCell.h"

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
    UIView * sectionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 80)];
    //    sectionView.backgroundColor = [UIColor orangeColor];
    UILabel * label = [[UILabel alloc]init];
    label.frame = CGRectMake(10, 0, SCREEN_WIDTH - 15, 80);
    label.numberOfLines = 0;
    label.text = [NSString stringWithFormat:@"设备名: %@\nUUID: %@",[OBDBluetooth shareOBDBluetooth].peripheral.name,[OBDBluetooth shareOBDBluetooth].peripheral.identifier.UUIDString];
    
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


//特征属性解析
- (void)getPropertyArray {
    [self.sectionTitleArray removeAllObjects];
    
    if (self.characteristic.properties & CBCharacteristicPropertyRead) {
        [self.sectionTitleArray addObject:@"可读"];
    }
    if (self.characteristic.properties & CBCharacteristicPropertyWrite) {
        [self.sectionTitleArray addObject:@"可写"];
    }
    if (self.characteristic.properties & CBCharacteristicPropertyWriteWithoutResponse) {
        [self.sectionTitleArray addObject:@"写无回复"];
    }
    if (self.characteristic.properties & CBCharacteristicPropertyNotify) {
        [self.sectionTitleArray addObject:@"订阅"];
    }
    if (self.characteristic.properties & CBCharacteristicPropertyIndicate) {
        [self.sectionTitleArray addObject:@"声明"];
    }
    [self.sectionTitleArray addObject:@"特征属性值"];
}


#pragma mark - tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
 
    [self getPropertyArray];
    
    if (self.characteristic.properties & CBCharacteristicPropertyRead) {
        return 2;
    }else {
        return 1;
    }
}

//每一个分区的头
- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    if ((self.characteristic.properties & CBCharacteristicPropertyRead) && (section == 0)) {
        
        return @"读数据";
        
    }else {
        
        return  @"特征属性值";
    }
    
}



- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 45;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
 
    if ((self.characteristic.properties & CBCharacteristicPropertyRead) && (section == 0)) {
        
        NSMutableArray * mutalbeArray = [[OBDBluetooth shareOBDBluetooth].readDataDic objectForKey:self.characteristic.UUID];
        if ([mutalbeArray count]>10) {
            return 11;
        }else {
            if ([mutalbeArray count] <= 0) {
                return 2;
            }else {
                return [mutalbeArray count] + 1 ;
            }
        }
        
    }else {
        return [self.sectionTitleArray count] - 1;
    }
 
    
    

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = @"peripheralCell";
    WJCharacteristicCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[WJCharacteristicCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    if ((self.characteristic.properties & CBCharacteristicPropertyRead) && (indexPath.section == 0)) {
        //读数据
        if(indexPath.row == 0) {
            cell.textDataLabel.text = @"读取数据";
            cell.textDataLabel.textColor = [UIColor blueColor];
        }else {
            cell.textDataLabel.textColor = [UIColor colorWithHexString:@"3d3d3d"];
            NSMutableArray * mutalbeArray = [[OBDBluetooth shareOBDBluetooth].readDataDic objectForKey:self.characteristic.UUID];
            if ([mutalbeArray count] > 0 ) {
                NSString * dataString = [NSString stringWithFormat:@"%@" ,[mutalbeArray objectAtIndex:indexPath.row - 1] ];
                cell.textDataLabel.text = dataString;
            }
  
            
            //  LOG(@"读取数据=======: %@  == %@",[[[OBDBluetooth shareOBDBluetooth]readDataDic]objectForKey:self.characteristic.UUID],dataString);
        }
        
    }else {
        //属性列表
        cell.textDataLabel.text = [self.sectionTitleArray objectAtIndex:indexPath.row];
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
