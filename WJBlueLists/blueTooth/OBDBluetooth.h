//
//  OBDBluetooth.h
//  nRF UART
//
//  Created by wenjuan on 16/4/21.
//  Copyright © 2016年 Nordic Semiconductor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol OBDBluetoothDelegate
- (void) reloadTableView:(NSMutableArray *) peripheralA andRissArray:(NSMutableArray *)rissArray;
- (void) checkBlueState:(BOOL)blueState;
- (void) didConnectPeripheral;
- (void) didDisconnectPeripheral;
- (void) didReceiveDataCenter:(NSString *) string;

//设备的连接状态
- (void)nextVC;

@end


@interface OBDBluetooth : NSObject <CBCentralManagerDelegate,CBPeripheralDelegate,CBPeripheralDelegate>
@property (nonatomic, strong) CBCentralManager *centerManager;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) CBCharacteristic *characteristic;
@property (nonatomic, assign) BOOL blueConnectState;
@property (nonatomic, assign) BOOL blueState;
@property (strong,nonatomic) NSMutableArray *peripherals;
@property (nonatomic, strong) NSMutableArray *rissArray;
@property (nonatomic, strong) id<OBDBluetoothDelegate> delegate;

//服务  特征 数组

+ (OBDBluetooth *)shareOBDBluetooth;

//连接设备
- (void)connectPeripheral:(CBPeripheral *)peripheral;
//断开设备连接
- (void)disconnectPeripheral:(CBPeripheral *)peripheral;
//扫描设备
- (void)scanPeripheral;
@end
