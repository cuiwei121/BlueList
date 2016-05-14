//
//  OBDBluetooth.m
//  nRF UART
//
//  Created by wenjuan on 16/4/21.
//  Copyright © 2016年 Nordic Semiconductor. All rights reserved.
//

#import "OBDBluetooth.h"

@interface OBDBluetooth()
@property (nonatomic, assign) BOOL isNotFirstCheckBLE;
@end


@implementation OBDBluetooth
+ (OBDBluetooth *)shareOBDBluetooth {
    static OBDBluetooth *shareOBDBluetoothInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        LOG(@"蓝牙设备中心  单例的初始化");
        shareOBDBluetoothInstance = [[self alloc] init];
        [shareOBDBluetoothInstance createCenterManager];
    });
    return shareOBDBluetoothInstance;
}

- (void)createCenterManager {
    
    //异步的创建蓝牙控制中心
     _centerManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    //主线程中
    //_centerManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}


#pragma mark - 属性 懒加载
- (NSMutableArray *)peripherals {
    if (!_peripherals) {
        _peripherals = [[NSMutableArray alloc]init];
    }
    return  _peripherals;
}

- (NSMutableArray *)rissArray {
    if (!_rissArray) {
        _rissArray = [NSMutableArray array];
    }
    return  _rissArray;
}

- (NSMutableArray *)serCharArray {
    if (!_serCharArray) {
        _serCharArray = [NSMutableArray array];
    }
    return _serCharArray;
}

- (NSMutableDictionary *)readDataDic {
    if (!_readDataDic) {
        _readDataDic = [NSMutableDictionary dictionary];
    }
    return _readDataDic;
}

#pragma mark - 蓝牙设备代理方法

- (void) centralManagerDidUpdateState:(CBCentralManager *)central
{
 
    switch (central.state) {
        case CBPeripheralManagerStatePoweredOn:
            LOG(@"BLE已打开.");
            
                [self scanPeripheral];
            
            break;
        case CBPeripheralManagerStatePoweredOff:
            
            LOG(@"请打开蓝牙");
            //断开连接
            [self.delegate didDisconnectPeripheral];
            //蓝牙状态
            self.blueConnectState = NO;
            self.blueState = NO;
            
            break;
            
        default:
            LOG(@"此设备不支持BLE或未打开蓝牙功能");
            break;
    }
    
}


/*
 Did discover peripheral abeacon_5DFA
 advertisementDATA = {
 kCBAdvDataIsConnectable = 1;
 kCBAdvDataLocalName = "abeacon_5DFA";
 kCBAdvDataManufacturerData = <d200018e 1493b085 f8541364 c7e6cc88 9462df>;
 kCBAdvDataServiceUUIDs =     (
 FEF5
 );
 }
 */
- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    //LOG(@"Did discover peripheral %@  \n advertisementDATA = %@", peripheral.name,advertisementData);
    
    //判断数组中是否有设备
    NSInteger index = [self.peripherals indexOfObject:peripheral];
    //LOG(@"index === %d",index);
    
    if (peripheral.name) {//外设的name存在  就添加到数组中
        if(![self.peripherals containsObject:peripheral]){
            [self.peripherals addObject:peripheral];
            [self.rissArray addObject:RSSI];
        }else {
            //用现在的替换原先的
            [self.rissArray replaceObjectAtIndex:index withObject:RSSI];
            [self.peripherals replaceObjectAtIndex:index withObject:peripheral];
        }
//        LOG(@"RSSI = %@",RSSI);
        //刷新tableView
        [self.delegate reloadTableView:self.peripherals andRissArray:self.rissArray];
    }
}


- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
     LOG(@"Did connect peripheral %@", peripheral.name);
    self.peripheral = peripheral;
    //链接成功后  停止扫描
    [self.centerManager stopScan];
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
    
    
}

- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    
    LOG(@"Did disconnect peripheral %@", peripheral.name);
    
}

#pragma mark - 对外方法
- (void)connectPeripheral:(CBPeripheral *)peripheral {
    self.peripheral = peripheral;
    self.peripheral.delegate = self;
    [self.centerManager stopScan];
    [self.centerManager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey: [NSNumber numberWithBool:YES]}];
}

- (void)disconnectPeripheral:(CBPeripheral *)peripheral {
    //主动断开连接
    [self.centerManager cancelPeripheralConnection:peripheral];
}

//扫描设备
- (void)scanPeripheral {
    [self.centerManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
}

//读数据
- (void)readCharacteristicValue:(CBCharacteristic *)characteristic {
    [self.peripheral readValueForCharacteristic:characteristic];
}

//写数据
//[self.peripheral writeValue:data forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
- (void)writeValue:(NSString *)writeS andCharacteristic:(CBCharacteristic *)characteristic {
    
    NSData *data = [NSData dataWithBytes:writeS.UTF8String length:writeS.length];
    [self.peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
}

/*
 CBServiceCBServiceCBService : <CBService: 0x15691460, isPrimary = YES, UUID = Device Information> uuid =  <180a>  Device Information  string = 180A
 2016-05-10 15:38:37.911 WJBlueLists[8943:2400375] CBServiceCBServiceCBService : <CBService: 0x156833b0, isPrimary = YES, UUID = Battery> uuid =  <180f>  Battery  string = 180F
 2016-05-10 15:38:37.913 WJBlueLists[8943:2400375] CBServiceCBServiceCBService : <CBService: 0x1565ec60, isPrimary = YES, UUID = 669A0C20-0008-0398-E411-D26820C58023> uuid =  <669a0c20 00080398 e411d268 20c58023>  669A0C20-0008-0398-E411-D26820C58023  string = 669A0C20 00080398 E411D268 20C58023
 2016-05-10 15:38:37.915 WJBlueLists[8943:2400375] CBServiceCBServiceCBService : <CBService: 0x156652c0, isPrimary = YES, UUID = FEF5> uuid =  <fef5>  FEF5  string = FEF5
 2016-05-10 15:38:38.030 WJBlueLists[8943:2400375] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x156824a0, UUID = Manufacturer Name String, properties = 0x2, value = (null), notifying = NO>    uuid =  <2a29>  Manufacturer Name String
 2016-05-10 15:38:38.031 WJBlueLists[8943:2400375] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x156875d0, UUID = Model Number String, properties = 0x2, value = (null), notifying = NO>    uuid =  <2a24>  Model Number String
 2016-05-10 15:38:38.033 WJBlueLists[8943:2400375] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x15573330, UUID = Firmware Revision String, properties = 0x2, value = (null), notifying = NO>    uuid =  <2a26>  Firmware Revision String
 2016-05-10 15:38:38.034 WJBlueLists[8943:2400375] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x1559e820, UUID = Software Revision String, properties = 0x2, value = (null), notifying = NO>    uuid =  <2a28>  Software Revision String
 2016-05-10 15:38:38.035 WJBlueLists[8943:2400375] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x156964c0, UUID = System ID, properties = 0x2, value = (null), notifying = NO>    uuid =  <2a23>  System ID
 2016-05-10 15:38:38.037 WJBlueLists[8943:2400375] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x156964f0, UUID = PnP ID, properties = 0x2, value = (null), notifying = NO>    uuid =  <2a50>  PnP ID
 2016-05-10 15:38:38.088 WJBlueLists[8943:2400373] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x156965b0, UUID = Battery Level, properties = 0x12, value = (null), notifying = NO>    uuid =  <2a19>  Battery Level
 2016-05-10 15:38:38.330 WJBlueLists[8943:2400375] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x1557a1c0, UUID = 669A0C20-0008-0398-E411-D26820C58024, properties = 0x2, value = (null), notifying = NO>    uuid =  <669a0c20 00080398 e411d268 20c58024>  669A0C20-0008-0398-E411-D26820C58024
 2016-05-10 15:38:38.331 WJBlueLists[8943:2400375] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x1559d770, UUID = 669A0C20-0008-0398-E411-D26820C58025, properties = 0x8, value = (null), notifying = NO>    uuid =  <669a0c20 00080398 e411d268 20c58025>  669A0C20-0008-0398-E411-D26820C58025
 2016-05-10 15:38:38.332 WJBlueLists[8943:2400375] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x1558a120, UUID = 669A0C20-0008-0398-E411-D26820C58026, properties = 0x8, value = (null), notifying = NO>    uuid =  <669a0c20 00080398 e411d268 20c58026>  669A0C20-0008-0398-E411-D26820C58026
 2016-05-10 15:38:38.333 WJBlueLists[8943:2400375] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x155840f0, UUID = 669A0C20-0008-0398-E411-D26820C58027, properties = 0x20, value = (null), notifying = NO>    uuid =  <669a0c20 00080398 e411d268 20c58027>  669A0C20-0008-0398-E411-D26820C58027
 2016-05-10 15:38:38.726 WJBlueLists[8943:2400375] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x15578e30, UUID = 8082CAA8-41A6-4021-91C6-56F9B954CC34, properties = 0xA, value = (null), notifying = NO>    uuid =  <8082caa8 41a64021 91c656f9 b954cc34>  8082CAA8-41A6-4021-91C6-56F9B954CC34
 2016-05-10 15:38:38.727 WJBlueLists[8943:2400375] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x155732f0, UUID = 724249F0-5EC3-4B5F-8804-42345AF08651, properties = 0xA, value = (null), notifying = NO>    uuid =  <724249f0 5ec34b5f 88044234 5af08651>  724249F0-5EC3-4B5F-8804-42345AF08651
 2016-05-10 15:38:38.729 WJBlueLists[8943:2400375] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x155736d0, UUID = 6C53DB25-47A1-45FE-A022-7C92FB334FD4, properties = 0x2, value = (null), notifying = NO>    uuid =  <6c53db25 47a145fe a0227c92 fb334fd4>  6C53DB25-47A1-45FE-A022-7C92FB334FD4
 2016-05-10 15:38:38.730 WJBlueLists[8943:2400375] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x1559d940, UUID = 9D84B9A3-000C-49D8-9183-855B673FDA31, properties = 0xA, value = (null), notifying = NO>    uuid =  <9d84b9a3 000c49d8 9183855b 673fda31>  9D84B9A3-000C-49D8-9183-855B673FDA31
 2016-05-10 15:38:38.732 WJBlueLists[8943:2400375] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x1559d970, UUID = 457871E8-D516-4CA1-9116-57D0B17B9CB2, properties = 0xE, value = (null), notifying = NO>    uuid =  <457871e8 d5164ca1 911657d0 b17b9cb2>  457871E8-D516-4CA1-9116-57D0B17B9CB2
 2016-05-10 15:38:38.734 WJBlueLists[8943:2400375] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x1559e440, UUID = 5F78DF94-798C-46F5-990A-B3EB6A065C88, properties = 0x12, value = (null), notifying = NO>    uuid =  <5f78df94 798c46f5 990ab3eb 6a065c88>  5F78DF94-798C-46F5-990A-B3EB6A065C88
 2016-05-10 15:38:38.736 WJBlueLists[8943:2400375] didUpdateNotificationStateForCharacteristic <CBCharacteristic: 0x156824a0, UUID = Manufacturer Name String, properties = 0x2, value = (null), notifying = NO>: Error Domain=CBErrorDomain Code=0 "Unknown error." UserInfo=0x15578e60 {NSLocalizedDescription=Unknown error.}
 2016-05-10 15:38:38.737 WJBlueLists[8943:2400375] didUpdateNotificationStateForCharacteristic <CBCharacteristic: 0x156875d0, UUID = Model Number String, properties = 0x2, value = (null), notifying = NO>: Error Domain=CBErrorDomain Code=0 "Unknown error." UserInfo=0x15578e60 {NSLocalizedDescription=Unknown error.}
 2016-05-10 15:38:38.739 WJBlueLists[8943:2400375] didUpdateNotificationStateForCharacteristic <CBCharacteristic: 0x15573330, UUID = Firmware Revision String, properties = 0x2, value = (null), notifying = NO>: Error Domain=CBErrorDomain Code=0 "Unknown error." UserInfo=0x15578e60 {NSLocalizedDescription=Unknown error.}
 2016-05-10 15:38:38.740 WJBlueLists[8943:2400375] didUpdateNotificationStateForCharacteristic <CBCharacteristic: 0x1559e820, UUID = Software Revision String, properties = 0x2, value = (null), notifying = NO>: Error Domain=CBErrorDomain Code=0 "Unknown error." UserInfo=0x156993c0 {NSLocalizedDescription=Unknown error.}
 2016-05-10 15:38:38.742 WJBlueLists[8943:2400375] didUpdateNotificationStateForCharacteristic <CBCharacteristic: 0x156964c0, UUID = System ID, properties = 0x2, value = (null), notifying = NO>: Error Domain=CBErrorDomain Code=0 "Unknown error." UserInfo=0x15699510 {NSLocalizedDescription=Unknown error.}
 2016-05-10 15:38:38.743 WJBlueLists[8943:2400375] didUpdateNotificationStateForCharacteristic <CBCharacteristic: 0x156964f0, UUID = PnP ID, properties = 0x2, value = (null), notifying = NO>: Error Domain=CBErrorDomain Code=0 "Unknown error." UserInfo=0x156b6e60 {NSLocalizedDescription=Unknown error.}
 2016-05-10 15:38:38.840 WJBlueLists[8943:2400375] didUpdateNotificationStateForCharacteristic === (null)
 2016-05-10 15:38:38.841 WJBlueLists[8943:2400375] didUpdateNotificationStateForCharacteristic <CBCharacteristic: 0x1557a1c0, UUID = 669A0C20-0008-0398-E411-D26820C58024, properties = 0x2, value = (null), notifying = NO>: Error Domain=CBErrorDomain Code=0 "Unknown error." UserInfo=0x1557a130 {NSLocalizedDescription=Unknown error.}
 2016-05-10 15:38:38.842 WJBlueLists[8943:2400375] didUpdateNotificationStateForCharacteristic <CBCharacteristic: 0x1559d770, UUID = 669A0C20-0008-0398-E411-D26820C58025, properties = 0x8, value = (null), notifying = NO>: Error Domain=CBErrorDomain Code=0 "Unknown error." UserInfo=0x1557a130 {NSLocalizedDescription=Unknown error.}
 2016-05-10 15:38:38.843 WJBlueLists[8943:2400375] didUpdateNotificationStateForCharacteristic <CBCharacteristic: 0x1558a120, UUID = 669A0C20-0008-0398-E411-D26820C58026, properties = 0x8, value = (null), notifying = NO>: Error Domain=CBErrorDomain Code=0 "Unknown error." UserInfo=0x156b90b0 {NSLocalizedDescription=Unknown error.}
 2016-05-10 15:38:38.962 WJBlueLists[8943:2400375] didUpdateNotificationStateForCharacteristic === (null)
 2016-05-10 15:38:38.966 WJBlueLists[8943:2400375] didUpdateNotificationStateForCharacteristic <CBCharacteristic: 0x15578e30, UUID = 8082CAA8-41A6-4021-91C6-56F9B954CC34, properties = 0xA, value = (null), notifying = NO>: Error Domain=CBErrorDomain Code=0 "Unknown error." UserInfo=0x15575720 {NSLocalizedDescription=Unknown error.}
 2016-05-10 15:38:38.968 WJBlueLists[8943:2400375] didUpdateNotificationStateForCharacteristic <CBCharacteristic: 0x155732f0, UUID = 724249F0-5EC3-4B5F-8804-42345AF08651, properties = 0xA, value = (null), notifying = NO>: Error Domain=CBErrorDomain Code=0 "Unknown error." UserInfo=0x156bd5b0 {NSLocalizedDescription=Unknown error.}
 2016-05-10 15:38:38.969 WJBlueLists[8943:2400375] didUpdateNotificationStateForCharacteristic <CBCharacteristic: 0x155736d0, UUID = 6C53DB25-47A1-45FE-A022-7C92FB334FD4, properties = 0x2, value = (null), notifying = NO>: Error Domain=CBErrorDomain Code=0 "Unknown error." UserInfo=0x156bd5b0 {NSLocalizedDescription=Unknown error.}
 2016-05-10 15:38:38.977 WJBlueLists[8943:2400375] didUpdateNotificationStateForCharacteristic <CBCharacteristic: 0x1559d940, UUID = 9D84B9A3-000C-49D8-9183-855B673FDA31, properties = 0xA, value = (null), notifying = NO>: Error Domain=CBErrorDomain Code=0 "Unknown error." UserInfo=0x156bd5b0 {NSLocalizedDescription=Unknown error.}
 2016-05-10 15:38:38.978 WJBlueLists[8943:2400375] didUpdateNotificationStateForCharacteristic <CBCharacteristic: 0x1559d970, UUID = 457871E8-D516-4CA1-9116-57D0B17B9CB2, properties = 0xE, value = (null), notifying = NO>: Error Domain=CBErrorDomain Code=0 "Unknown error." UserInfo=0x156bd5b0 {NSLocalizedDescription=Unknown error.}
 
 
 
 05-10 15:52:32.340 WJBlueLists[8978:2402716] Did connect peripheral abeacon_5DFA
 2016-05-10 15:52:33.880 WJBlueLists[8978:2402718] Received data on a characteristic. === <41707269 6c204272 6f746865 72>   ==April Brother
 2016-05-10 15:52:33.881 WJBlueLists[8978:2402718] Received data on a characteristic. === <41707269 6c204272 6f746865 72>
 2016-05-10 15:52:33.970 WJBlueLists[8978:2402716] Received data on a characteristic. === <312e3064>   ==1.0d
 2016-05-10 15:52:33.971 WJBlueLists[8978:2402716] Received data on a characteristic. === <312e3064>
 2016-05-10 15:52:34.030 WJBlueLists[8978:2402716] Received data on a characteristic. === <765f332e 302e372e 31>   ==v_3.0.7.1
 2016-05-10 15:52:34.031 WJBlueLists[8978:2402716] Received data on a characteristic. === <765f332e 302e372e 31>
 2016-05-10 15:52:34.119 WJBlueLists[8978:2402716] Received data on a characteristic. === <76312e33 2e31>   ==v1.3.1
 2016-05-10 15:52:34.120 WJBlueLists[8978:2402716] Received data on a characteristic. === <76312e33 2e31>
 2016-05-10 15:52:34.181 WJBlueLists[8978:2402718] Received data on a characteristic. === <123456ff fe9abcde>   ==(null)
 2016-05-10 15:52:34.181 WJBlueLists[8978:2402718] Received data on a characteristic. === <123456ff fe9abcde>
 2016-05-10 15:52:34.270 WJBlueLists[8978:2402718] Received data on a characteristic. === <01d20080 050001>   ==(null)
 2016-05-10 15:52:34.271 WJBlueLists[8978:2402718] Received data on a characteristic. === <01d20080 050001>
 2016-05-10 15:52:34.331 WJBlueLists[8978:2402718] Received data on a characteristic. === <64>   ==d
 2016-05-10 15:52:34.332 WJBlueLists[8978:2402718] Received data on a characteristic. === <64>
 2016-05-10 15:52:34.390 WJBlueLists[8978:2402718] Received data on a characteristic. === <312e332e 64>   ==1.3.d
 2016-05-10 15:52:34.391 WJBlueLists[8978:2402718] Received data on a characteristic. === <312e332e 64>
 2016-05-10 15:52:34.510 WJBlueLists[8978:2402718] Error receiving notification for characteristic <CBCharacteristic: 0x14697350, UUID = 669A0C20-0008-0398-E411-D26820C58025, properties = 0x8, value = (null), notifying = NO>: Error Domain=CBATTErrorDomain Code=2 "Reading is not permitted." UserInfo=0x14675140 {NSLocalizedDescription=Reading is not permitted.}
 2016-05-10 15:52:34.569 WJBlueLists[8978:2402718] Error receiving notification for characteristic <CBCharacteristic: 0x1454ec10, UUID = 669A0C20-0008-0398-E411-D26820C58026, properties = 0x8, value = (null), notifying = NO>: Error Domain=CBATTErrorDomain Code=2 "Reading is not permitted." UserInfo=0x146730d0 {NSLocalizedDescription=Reading is not permitted.}
 2016-05-10 15:52:34.630 WJBlueLists[8978:2402718] Error receiving notification for characteristic <CBCharacteristic: 0x1454ec40, UUID = 669A0C20-0008-0398-E411-D26820C58027, properties = 0x20, value = (null), notifying = NO>: Error Domain=CBATTErrorDomain Code=2 "Reading is not permitted." UserInfo=0x14675af0 {NSLocalizedDescription=Reading is not permitted.}
 2016-05-10 15:52:34.690 WJBlueLists[8978:2402718] Received data on a characteristic. === <>
 2016-05-10 15:52:34.750 WJBlueLists[8978:2402718] Received data on a characteristic. === <>
 2016-05-10 15:52:34.840 WJBlueLists[8978:2402718] Received data on a characteristic. === <>
 2016-05-10 15:52:34.900 WJBlueLists[8978:2402718] Received data on a characteristic. === <>
 2016-05-10 15:52:34.959 WJBlueLists[8978:2402718] Received data on a characteristic. === <>
 2016-05-10 15:52:35.020 WJBlueLists[8978:2402718] Received data on a characteristic. === <00>   ==
 2016-05-10 15:52:35.021 WJBlueLists[8978:2402718] Received data on a characteristic. === <00>
 2016-05-10 15:53:11.999 WJBlueLists[8978:2402807] Did connect peripheral abeacon_5E36
 
 
 
 //obdII
 
 BCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x146bd800, UUID = Manufacturer Name String, properties = 0x2, value = <49535343>, notifying = NO>    uuid =  <2a29>  Manufacturer Name String
 2016-05-13 09:54:32.207 WJBlueLists[10124:2712682] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x146cd220, UUID = Model Number String, properties = 0x2, value = <42543530 3530>, notifying = NO>    uuid =  <2a24>  Model Number String
 2016-05-13 09:54:32.208 WJBlueLists[10124:2712682] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x146d22d0, UUID = Serial Number String, properties = 0x2, value = <30303030>, notifying = NO>    uuid =  <2a25>  Serial Number String
 2016-05-13 09:54:32.212 WJBlueLists[10124:2712682] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x146cd390, UUID = Hardware Revision String, properties = 0x2, value = <35303530 5f535050 00000000 00>, notifying = NO>    uuid =  <2a27>  Hardware Revision String
 2016-05-13 09:54:32.215 WJBlueLists[10124:2712682] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x146bdc10, UUID = Firmware Revision String, properties = 0x2, value = <32303235 303231>, notifying = NO>    uuid =  <2a26>  Firmware Revision String
 2016-05-13 09:54:32.217 WJBlueLists[10124:2712682] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x14670660, UUID = Software Revision String, properties = 0x2, value = <30303030>, notifying = NO>    uuid =  <2a28>  Software Revision String
 2016-05-13 09:54:32.221 WJBlueLists[10124:2712682] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x146a1700, UUID = System ID, properties = 0x2, value = <00000000 00000000>, notifying = NO>    uuid =  <2a23>  System ID
 2016-05-13 09:54:32.223 WJBlueLists[10124:2712682] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x146730c0, UUID = IEEE Regulatory Certification, properties = 0x2, value = <00010004 00000000>, notifying = NO>    uuid =  <2a2a>  IEEE Regulatory Certification
 2016-05-13 09:54:32.225 WJBlueLists[10124:2712682] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x1459f390, UUID = 49535343-6DAA-4D02-ABF6-19569ACA69FE, properties = 0xA, value = <00180018 00000048 00>, notifying = NO>    uuid =  <49535343 6daa4d02 abf61956 9aca69fe>  49535343-6DAA-4D02-ABF6-19569ACA69FE
 2016-05-13 09:54:32.228 WJBlueLists[10124:2712682] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x1459daf0, UUID = 49535343-ACA3-481C-91EC-D85E28A60318, properties = 0x18, value = (null), notifying = NO>    uuid =  <49535343 aca3481c 91ecd85e 28a60318>  49535343-ACA3-481C-91EC-D85E28A60318
 2016-05-13 09:54:32.231 WJBlueLists[10124:2712682] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x14690040, UUID = FFF1, properties = 0x10, value = <0d3e>, notifying = NO>    uuid =  <fff1>  FFF1
 2016-05-13 09:54:32.233 WJBlueLists[10124:2712682] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x146935a0, UUID = FFF2, properties = 0x8, value = (null), notifying = NO>    uuid =  <fff2>  FFF2
 
 
   5DFA
 
 CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x146dc370, UUID = Manufacturer Name String, properties = 0x2, value = (null), notifying = NO>    uuid =  <2a29>  Manufacturer Name String
 2016-05-13 09:55:33.166 WJBlueLists[10124:2712830] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x1469ee50, UUID = Model Number String, properties = 0x2, value = (null), notifying = NO>    uuid =  <2a24>  Model Number String
 2016-05-13 09:55:33.167 WJBlueLists[10124:2712830] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x14672e30, UUID = Firmware Revision String, properties = 0x2, value = (null), notifying = NO>    uuid =  <2a26>  Firmware Revision String
 2016-05-13 09:55:33.169 WJBlueLists[10124:2712830] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x1468c0c0, UUID = Software Revision String, properties = 0x2, value = (null), notifying = NO>    uuid =  <2a28>  Software Revision String
 2016-05-13 09:55:33.170 WJBlueLists[10124:2712830] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x1467f390, UUID = System ID, properties = 0x2, value = (null), notifying = NO>    uuid =  <2a23>  System ID
 2016-05-13 09:55:33.172 WJBlueLists[10124:2712830] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x146b76d0, UUID = PnP ID, properties = 0x2, value = (null), notifying = NO>    uuid =  <2a50>  PnP ID
 2016-05-13 09:55:33.223 WJBlueLists[10124:2712797] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x146d9bc0, UUID = Battery Level, properties = 0x12, value = (null), notifying = NO>    uuid =  <2a19>  Battery Level
 2016-05-13 09:55:33.494 WJBlueLists[10124:2712830] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x146b5460, UUID = 669A0C20-0008-0398-E411-D26820C58024, properties = 0x2, value = (null), notifying = NO>    uuid =  <669a0c20 00080398 e411d268 20c58024>  669A0C20-0008-0398-E411-D26820C58024
 2016-05-13 09:55:33.495 WJBlueLists[10124:2712830] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x1468a510, UUID = 669A0C20-0008-0398-E411-D26820C58025, properties =8, 0x value = (null), notifying = NO>    uuid =  <669a0c20 00080398 e411d268 20c58025>  669A0C20-0008-0398-E411-D26820C58025
 2016-05-13 09:55:33.497 WJBlueLists[10124:2712830] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x14685fb0, UUID = 669A0C20-0008-0398-E411-D26820C58026, properties = 0x8, value = (null), notifying = NO>    uuid =  <669a0c20 00080398 e411d268 20c58026>  669A0C20-0008-0398-E411-D26820C58026
 2016-05-13 09:55:33.498 WJBlueLists[10124:2712830] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x146df5e0, UUID = 669A0C20-0008-0398-E411-D26820C58027, properties = 0x20, value = (null), notifying = NO>    uuid =  <669a0c20 00080398 e411d268 20c58027>  669A0C20-0008-0398-E411-D26820C58027
 2016-05-13 09:55:33.885 WJBlueLists[10124:2712830] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x1468b0b0, UUID = 8082CAA8-41A6-4021-91C6-56F9B954CC34, properties = 0xA, value = (null), notifying = NO>    uuid =  <8082caa8 41a64021 91c656f9 b954cc34>  8082CAA8-41A6-4021-91C6-56F9B954CC34
 2016-05-13 09:55:33.886 WJBlueLists[10124:2712830] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x146a0b10, UUID = 724249F0-5EC3-4B5F-8804-42345AF08651, properties = 0xA, value = (null), notifying = NO>    uuid =  <724249f0 5ec34b5f 88044234 5af08651>  724249F0-5EC3-4B5F-8804-42345AF08651
 2016-05-13 09:55:33.887 WJBlueLists[10124:2712830] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x1469df50, UUID = 6C53DB25-47A1-45FE-A022-7C92FB334FD4, properties = 0x2, value = (null), notifying = NO>    uuid =  <6c53db25 47a145fe a0227c92 fb334fd4>  6C53DB25-47A1-45FE-A022-7C92FB334FD4
 2016-05-13 09:55:33.889 WJBlueLists[10124:2712830] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x1467e870, UUID = 9D84B9A3-000C-49D8-9183-855B673FDA31, properties = 0xA, value = (null), notifying = NO>    uuid =  <9d84b9a3 000c49d8 9183855b 673fda31>  9D84B9A3-000C-49D8-9183-855B673FDA31
 
    0xA = 0x2 + 0x8
    0xE = 0x2 + 0x8 + 0x4
    0x12 = 0x10 + 0x02
 
 2016-05-13 09:55:33.890 WJBlueLists[10124:2712830] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x14689150, UUID = 457871E8-D516-4CA1-9116-57D0B17B9CB2, properties = 0xE, value = (null), notifying = NO>    uuid =  <457871e8 d5164ca1 911657d0 b17b9cb2>  457871E8-D516-4CA1-9116-57D0B17B9CB2
 2016-05-13 09:55:33.892 WJBlueLists[10124:2712830] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x1469bf20, UUID = 5F78DF94-798C-46F5-990A-B3EB6A065C88, properties = 0x12, value = (null), notifying = NO>    uuid =  <5f78df94 798c46f5 990ab3eb 6a065c88>  5F78DF94-798C-46F5-990A-B3EB6A065C88
 
 */
#pragma mark - 设备的代理方法

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error)
    {
        LOG(@"Error discovering services: %@", error);
        return;
    }
    
    for (CBService *service in [peripheral services])
    {
        //[ast stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        //        NSString *string = [NSString stringWithFormat:@"%@",service.UUID.data];
        //        NSCharacterSet*set = [NSCharacterSet characterSetWithCharactersInString:@"<>"];
        //        NSString*trimmedString = [string stringByTrimmingCharactersInSet:set];
        //        trimmedString = [trimmedString uppercaseString];
        //        //LOG(@"CBServiceCBServiceCBService : %@ uuid =  %@  %@  string = %@", service,service.UUID.data,service.UUID,trimmedString);
        
        
        [self.peripheral discoverCharacteristics:nil forService:service];
        
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error)
    {
        LOG(@"Error discovering characteristics: %@", error);
        return;
    }
    
    for (CBCharacteristic *c in [service characteristics])
    {
     
        //        [self.peripheral setNotifyValue:YES forCharacteristic:c];
        [self.peripheral readValueForCharacteristic:c];
        
        //        LOG(@"CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: %@    uuid =  %@  %@", c,c.UUID.data,c.UUID);
        
        [self getLasterCharacteristic:peripheral andCharacteristic:c];
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        LOG(@"Error receiving notification for characteristic %@: %@", characteristic, error);
        return;
    }
    
    if ([[characteristic value] bytes] ) {
        NSString *string = [NSString stringWithUTF8String:[[characteristic value] bytes]];
        if (string) {
            [self.readDataDic setObject:string forKey:characteristic.UUID];
            if ([string isEqualToString:@"d"]) {
                [self.readDataDic setObject:[characteristic value] forKey:characteristic.UUID];
            }
        }else
        {
            [self.readDataDic setObject:[characteristic value] forKey:characteristic.UUID];
        }
        
        LOG(@"Received data on a characteristic. === %@   ==%@",[characteristic value],string);
    }else {
        LOG(@"Received data on a characteristic. === %@    ",[characteristic value]);
        [self.readDataDic setObject:[characteristic value] forKey:characteristic.UUID];
    }
    
    
//    [self.delegate readDataForString:[NSString stringWithFormat:@"%@",characteristic.value]];
    //[self getLasterCharacteristic:peripheral andCharacteristic:characteristic];
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    
    
    if (error)
    {
        LOG(@"didUpdateNotificationStateForCharacteristic %@: %@", characteristic, error);
        return;
    }
//    NSString *string = [NSString stringWithUTF8String:[[characteristic value] bytes]];
    
    
    LOG(@"didUpdateNotificationStateForCharacteristic === %@    ",[characteristic value] );

}



//判断最后一个特征值 然后跳转
- (void)getLasterCharacteristic:(CBPeripheral *)peripheral andCharacteristic:(CBCharacteristic *)characteristic {
    //判断最后一个服务的最后一个特征值
    CBService *lasterServer = [peripheral.services lastObject];
    CBCharacteristic *lasterCharac = [lasterServer.characteristics lastObject];
    
    //LOG(@"uuid laster= %@  %@",lasterCharac.UUID,characteristic.UUID);
    if ([lasterCharac.UUID isEqual:characteristic.UUID]) {
        [self arrayForServAndCha:peripheral];
        [self.delegate nextVC];
    }
}

//设置服务和特征的值
- (void)arrayForServAndCha:(CBPeripheral *)peripheral {
    for (int i = 0; i < [peripheral.services count]; i ++) {
        CBService *serv = [peripheral.services objectAtIndex:i];
        for (int j = 0; j < [serv.characteristics count]; j ++) {
            CBCharacteristic *charater = [serv.characteristics objectAtIndex:j];
            [self.serCharArray addObject:charater];
            
        }
    }
}






#pragma mark - 设备的代理方法
- (void) didReceiveData:(NSString *)string
{
    [self.delegate didReceiveDataCenter:string];
}


 

@end
