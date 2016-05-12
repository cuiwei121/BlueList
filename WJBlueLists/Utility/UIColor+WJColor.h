//
//  UIColor+WJColor.h
//  WJBlueLists
//
//  Created by wenjuan on 16/5/12.
//  Copyright © 2016年 wenjuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (WJColor)
+ (UIColor *)colorWithHexString:(NSString *)color;

//从十六进制字符串获取颜色，
//color:支持@“#123456”、 @“0X123456”、 @“123456”三种格式
+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;
@end
