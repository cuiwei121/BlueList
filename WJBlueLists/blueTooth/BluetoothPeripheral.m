//
//  BluetoothPeripheral.m
//  nRF UART
//
//  Created by wenjuan on 16/4/21.
//  Copyright © 2016年 Nordic Semiconductor. All rights reserved.
//

#import "BluetoothPeripheral.h"



@interface BluetoothPeripheral()
@property (nonatomic, assign) BOOL isDistanceBle;

@end


@implementation BluetoothPeripheral

- (BluetoothPeripheral *) initWithPeripheral:(CBPeripheral*)peripheral delegate:(id<BluePeripheralDelegate>) delegate {
    if (self = [super init])
    {
        _peripheral = peripheral;
        _peripheral.delegate = self;
        _delegate = delegate;
         
    }
    return self;
}

- (void) writeString:(NSString *) string {
    //LOG(@"date = %@",[NSDate new]);
    string = [NSString stringWithFormat:@"%@\r\n",string];
    
    
    
    NSData *data = [NSData dataWithBytes:string.UTF8String length:string.length];
    [self.peripheral writeValue:data forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
}

- (void) didConnect {
   [_peripheral discoverServices:nil];
}

- (void) didDisconnect {
    //判断蓝牙是否断开的标识
    _isDistanceBle = YES;
    
    
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
        
        
        [self.peripheral discoverCharacteristics:nil forService:self.service];
        
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
        self.readCharacteristic = c;
        [self.peripheral setNotifyValue:YES forCharacteristic:self.readCharacteristic];
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



#pragma mark - 写文件



- (void)writeLogToFile:(NSString *)str {
    
    //第一：读取documents路径的方法：
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) ; //得到documents的路径，为当前应用程序独享
    
    NSString *documentD = [paths objectAtIndex:0];
    
    
    NSString *configFile = [documentD stringByAppendingPathComponent:@"blueLog.txt"]; //得到documents目录下blueLog.txt 文件的路径
    
   NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:configFile]) {
        [str writeToFile:configFile atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }else {
        NSFileHandle  *outFile;
        NSData *buffer;
        
        outFile = [NSFileHandle fileHandleForWritingAtPath:configFile];
        
        if(outFile == nil)
        {
            NSLog(@"Open of file for writing failed");
        }
        [outFile seekToEndOfFile];
        NSString *bs = [NSString stringWithFormat:@"%@\n",str];
        buffer = [bs dataUsingEncoding:NSUTF8StringEncoding];
        [outFile writeData:buffer];
        
        //关闭读写文件
        [outFile closeFile];
        
    }
    
}


@end
