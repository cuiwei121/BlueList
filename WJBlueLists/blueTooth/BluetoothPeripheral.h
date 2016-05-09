//
//  BluetoothPeripheral.h
//  nRF UART
//
//  Created by wenjuan on 16/4/21.
//  Copyright © 2016年 Nordic Semiconductor. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>



@protocol BluePeripheralDelegate
- (void) didReceiveData:(NSString *) string;
@end


@interface BluetoothPeripheral : NSObject <CBPeripheralDelegate>


@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) CBService *service;
@property (nonatomic, strong) CBCharacteristic *readCharacteristic;
@property (nonatomic, strong) CBCharacteristic *writeCharacteristic;
@property (nonatomic, strong) id<BluePeripheralDelegate> delegate;

- (BluetoothPeripheral *) initWithPeripheral:(CBPeripheral*)peripheral delegate:(id<BluePeripheralDelegate>) delegate;

- (void) writeString:(NSString *) string;

- (void) didConnect;
- (void) didDisconnect;

@end
