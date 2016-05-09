//
//  WJPeripheralCell.m
//  WJBlueLists
//
//  Created by wenjuan on 16/5/9.
//  Copyright © 2016年 wenjuan. All rights reserved.
//

#import "WJPeripheralCell.h"

@implementation WJPeripheralCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createCellView];
    }
    return self;
}

- (void)createCellView {
    _titleLabel = [[UILabel alloc]init];
    [self.contentView addSubview:_titleLabel];
    _titleLabel.frame = CGRectMake(0, 1, SCREEN_WIDTH, 30);
}

@end
