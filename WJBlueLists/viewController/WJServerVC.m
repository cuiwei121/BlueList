//
//  WJServerVC.m
//  WJBlueLists
//
//  Created by wenjuan on 16/5/10.
//  Copyright © 2016年 wenjuan. All rights reserved.
//

#import "WJServerVC.h"
#import "OBDBluetooth.h"
#import "WJServerCell.h"
#import "WJPeripheralCell.h"

@interface WJServerVC ()<OBDBluetoothDelegate>
@property (nonatomic, strong) NSArray *sectonArray;


@end

@implementation WJServerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"服务特征";
    [OBDBluetooth shareOBDBluetooth].delegate = self;
    if ([OBDBluetooth shareOBDBluetooth].serCharArray) {
        self.sectonArray = [OBDBluetooth shareOBDBluetooth].peripheral.services;
 
    }
    
    //创建头文件  tableview的头
    UIView * sectionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
//    sectionView.backgroundColor = [UIColor orangeColor];
    UILabel * label = [[UILabel alloc]init];
    label.frame = CGRectMake(0, 0, 200, 40);
    label.text = @"123456";
    [sectionView addSubview:label];
    [self.baseTableVC setTableHeaderView:sectionView];
    
    
    // Do any additional setup after loading the view.
}

#pragma mark - 属性
- (NSArray *)sectonArray {
    if (!_sectonArray) {
        _sectonArray = [NSArray array];
    }
    return _sectonArray;
}


#pragma mark - tableview 代理方法

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return  [self.sectonArray count];
}

//每一个分区的头
- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    CBService *service = [self.sectonArray objectAtIndex:section];
    
    NSString *uuidData = [NSString stringWithFormat:@"%@",service.UUID.data];
    NSString *uuidS = [NSString stringWithFormat:@"%@",service.UUID];
    NSCharacterSet*set = [NSCharacterSet characterSetWithCharactersInString:@"<>"];
    uuidS = [uuidS  stringByReplacingOccurrencesOfString:@"-" withString:@""];
    uuidData = [uuidData stringByTrimmingCharactersInSet:set];
    uuidData = [uuidData stringByReplacingOccurrencesOfString:@" " withString:@""];
    uuidData = [uuidData uppercaseString];
    
    if (![uuidData isEqualToString:uuidS]) {
        return [NSString stringWithFormat:@"%@  %@",service.UUID,uuidData];
    }else {
        return [NSString stringWithFormat:@"UUID：%@",service.UUID];
    }
    
    
//    return nil;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return 100;
    }else {
        return 60;
    }
}
//
//- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    UIView * sectionView = [[UIView alloc]init];
//    sectionView.backgroundColor = [UIColor orangeColor];
//    UILabel * label = [[UILabel alloc]init];
//    label.frame = CGRectMake(0, 0, 200, 40);
//    label.text = @"123456";
//    [sectionView addSubview:label];
//    return sectionView;
//
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    return 60;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    CBService *service = [self.sectonArray objectAtIndex:section];
    return [service.characteristics count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = @"peripheralCell";
    WJServerCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[WJServerCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    
    CBService *service = [self.sectonArray objectAtIndex:indexPath.section];
    NSArray *characArray = service.characteristics;
    
    
    CBCharacteristic *characteristic = [characArray objectAtIndex:indexPath.row];
    
    
    //uuid
    NSString *uuidData = [NSString stringWithFormat:@"%@",characteristic.UUID.data];
    NSString *uuidS = [NSString stringWithFormat:@"%@",characteristic.UUID];
    LOG(@"uuids = %@ \n uuidData = %@ ",uuidS,uuidData);

    /*
     1,
     uuids = 49535343-ACA3-481C-91EC-D85E28A60318
     uuidData = <49535343 aca3481c 91ecd85e 28a60318>
     
     2.
     uuids = Software Revision String
     uuidData = <2a28>
     
     3.
     uuids = FFF2
     uuidData = <fff2>
     */
    //字符串的处理
    NSCharacterSet*set = [NSCharacterSet characterSetWithCharactersInString:@"<>"];
    uuidS = [uuidS  stringByReplacingOccurrencesOfString:@"-" withString:@""];
    uuidData = [uuidData stringByTrimmingCharactersInSet:set];
    uuidData = [uuidData stringByReplacingOccurrencesOfString:@" " withString:@""];
    uuidData = [uuidData uppercaseString];
    if (![uuidData isEqualToString:uuidS]) {
        
        cell.nameLabel.text = [NSString stringWithFormat:@"%@ :%@",characteristic.UUID,uuidData];
    }else {
        cell.nameLabel.text = [NSString stringWithFormat:@"%@",characteristic.UUID];
    }

    cell.desLabel.text = [NSString stringWithFormat:@"属性：%d",characteristic.properties];
   

    return cell;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)nextVC {
//刷新界面
    
    LOG(@"刷新界面");
    
    
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
