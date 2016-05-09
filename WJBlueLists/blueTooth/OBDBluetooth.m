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
    LOG(@"Did discover peripheral %@", peripheral.name);
    
    //判断数组中是否有设备
    if(![self.peripherals containsObject:peripheral]){
        [self.peripherals addObject:peripheral];
        
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
    self.blueConnectState = YES;
    LOG(@"Did connect peripheral %@", peripheral.name);
    [self.delegate didConnectPeripheral];
    
}

- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    self.blueConnectState = NO;
    LOG(@"Did disconnect peripheral %@", peripheral.name);
    
    
    [self.delegate didDisconnectPeripheral];
    
    
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
