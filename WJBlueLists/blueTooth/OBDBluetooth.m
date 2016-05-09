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
            [self.delegate checkBlueState:NO];
            
            break;
            
        default:
            LOG(@"此设备不支持BLE或未打开蓝牙功能");
            break;
    }
    
}

- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    //LOG(@"Did discover peripheral %@", peripheral.name);
    
    //判断数组中是否有设备
    NSInteger index = [self.peripherals indexOfObject:peripheral];
    //LOG(@"index === %d",index);
    
    if (peripheral.name) {//外设的name存在  就添加到数组中
        if(![self.peripherals containsObject:peripheral]){
            [self.peripherals addObject:peripheral];
            [self.rissArray addObject:RSSI];
        }else {
            [self.rissArray replaceObjectAtIndex:index withObject:RSSI];
        }
//        LOG(@"RSSI = %@",RSSI);
        //刷新tableView
        [self.delegate reloadTableView:self.peripherals andRissArray:self.rissArray];
    }
    
    
    //判断是否已经连接过   蓝牙设备
//    if ([peripheral.name isEqualToString:@"OBDII"]) {
//        self.peripheral = peripheral;
//        self.peripheral.delegate = self;
//        [self.centerManager stopScan];
//        [self.centerManager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey: [NSNumber numberWithBool:YES]}];
//    }
}


- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
     LOG(@"Did connect peripheral %@", peripheral.name);
    //链接成功后  停止扫描
    [self.centerManager stopScan];
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
    
//    self.blueConnectState = YES;
//    [self.delegate didConnectPeripheral];
    
}

- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    
    LOG(@"Did disconnect peripheral %@", peripheral.name);
    
//    self.blueConnectState = NO;
    
    
    
//    [self.delegate didDisconnectPeripheral];
    
    
}


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


/*
 2016-05-09 18:34:47.174 WJBlueLists[8573:2346572] Did connect peripheral abeacon_5DFA
 2016-05-09 18:34:47.985 WJBlueLists[8573:2346572] CBServiceCBServiceCBService : <CBService: 0x15d6fea0, isPrimary = YES, UUID = Device Information>
 2016-05-09 18:34:47.987 WJBlueLists[8573:2346572] CBServiceCBServiceCBService : <CBService: 0x15d82fb0, isPrimary = YES, UUID = Battery>
 2016-05-09 18:34:47.988 WJBlueLists[8573:2346572] CBServiceCBServiceCBService : <CBService: 0x15d9d000, isPrimary = YES, UUID = 669A0C20-0008-0398-E411-D26820C58023>
 2016-05-09 18:34:47.990 WJBlueLists[8573:2346572] CBServiceCBServiceCBService : <CBService: 0x15d98530, isPrimary = YES, UUID = FEF5>
 2016-05-09 18:34:48.225 WJBlueLists[8573:2346572] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x15d6ebd0, UUID = Manufacturer Name String, properties = 0x2, value = (null), notifying = NO>
 2016-05-09 18:34:48.226 WJBlueLists[8573:2346572] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x15d84dc0, UUID = Model Number String, properties = 0x2, value = (null), notifying = NO>
 2016-05-09 18:34:48.227 WJBlueLists[8573:2346572] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x15d9bed0, UUID = Firmware Revision String, properties = 0x2, value = (null), notifying = NO>
 2016-05-09 18:34:48.228 WJBlueLists[8573:2346572] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x15d9bf00, UUID = Software Revision String, properties = 0x2, value = (null), notifying = NO>
 2016-05-09 18:34:48.229 WJBlueLists[8573:2346572] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x15e66aa0, UUID = System ID, properties = 0x2, value = (null), notifying = NO>
 2016-05-09 18:34:48.230 WJBlueLists[8573:2346572] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x15e66f00, UUID = PnP ID, properties = 0x2, value = (null), notifying = NO>
 2016-05-09 18:34:48.344 WJBlueLists[8573:2346571] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x15e680b0, UUID = Battery Level, properties = 0x12, value = (null), notifying = NO>
 2016-05-09 18:34:48.674 WJBlueLists[8573:2346572] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x15e89bd0, UUID = 669A0C20-0008-0398-E411-D26820C58024, properties = 0x2, value = (null), notifying = NO>
 2016-05-09 18:34:48.675 WJBlueLists[8573:2346572] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x15e66580, UUID = 669A0C20-0008-0398-E411-D26820C58025, properties = 0x8, value = (null), notifying = NO>
 2016-05-09 18:34:48.676 WJBlueLists[8573:2346572] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x15e67550, UUID = 669A0C20-0008-0398-E411-D26820C58026, properties = 0x8, value = (null), notifying = NO>
 2016-05-09 18:34:48.677 WJBlueLists[8573:2346572] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x15e94300, UUID = 669A0C20-0008-0398-E411-D26820C58027, properties = 0x20, value = (null), notifying = NO>
 2016-05-09 18:34:49.214 WJBlueLists[8573:2346571] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x15d63830, UUID = 8082CAA8-41A6-4021-91C6-56F9B954CC34, properties = 0xA, value = (null), notifying = NO>
 2016-05-09 18:34:49.215 WJBlueLists[8573:2346571] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x15d84df0, UUID = 724249F0-5EC3-4B5F-8804-42345AF08651, properties = 0xA, value = (null), notifying = NO>
 2016-05-09 18:34:49.216 WJBlueLists[8573:2346571] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x15d768c0, UUID = 6C53DB25-47A1-45FE-A022-7C92FB334FD4, properties = 0x2, value = (null), notifying = NO>
 2016-05-09 18:34:49.217 WJBlueLists[8573:2346571] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x15d768f0, UUID = 9D84B9A3-000C-49D8-9183-855B673FDA31, properties = 0xA, value = (null), notifying = NO>
 2016-05-09 18:34:49.218 WJBlueLists[8573:2346571] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x15d9c000, UUID = 457871E8-D516-4CA1-9116-57D0B17B9CB2, properties = 0xE, value = (null), notifying = NO>
 2016-05-09 18:34:49.219 WJBlueLists[8573:2346571] CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: <CBCharacteristic: 0x15d658d0, UUID = 5F78DF94-798C-46F5-990A-B3EB6A065C88, properties = 0x12, value = (null), notifying = NO>
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
        LOG(@"CBServiceCBServiceCBService : %@", service);
        
        
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
        
        LOG(@"CBCharacteristicCBCharacteristicCBCharacteristic g characteristics: %@", c);
        
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        LOG(@"Error receiving notification for characteristic %@: %@", characteristic, error);
        return;
    }
    NSString *string = [NSString stringWithUTF8String:[[characteristic value] bytes]];
    
    
    LOG(@"Received data on a characteristic. === %@   ==%@",[characteristic value],string);
    
}



#pragma mark - 设备的代理方法
- (void) didReceiveData:(NSString *)string
{
    [self.delegate didReceiveDataCenter:string];
}


 

@end
