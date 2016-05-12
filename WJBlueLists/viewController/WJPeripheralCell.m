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
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(40);
        make.height.equalTo(@40);
    }];
    _titleLabel.font = [UIFont systemFontOfSize:20];
    
    
    _identifierLabel = [[UILabel alloc]init];
    [self.contentView addSubview:_identifierLabel];
    _identifierLabel.frame = CGRectMake(40, 40, SCREEN_WIDTH - 20, 20);
    _identifierLabel.font = [UIFont systemFontOfSize:13];
    
    _rissLabel = [[UILabel alloc]init];
    [self.contentView addSubview:_rissLabel];
    _rissLabel.frame = CGRectMake(10, 40, 30, 20);
    _rissLabel.font = [UIFont systemFontOfSize:13];
    
}

@end
