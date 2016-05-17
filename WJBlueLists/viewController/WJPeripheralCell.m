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
        make.top.equalTo(self.contentView).offset(5);
        make.left.equalTo(self.contentView).offset(40);
        make.right.equalTo(self.contentView).offset(-20);
        make.height.equalTo(@35);
    }];
    _titleLabel.font = [UIFont systemFontOfSize:20];
    
    
    _identifierLabel = [[UILabel alloc]init];
    [self.contentView addSubview:_identifierLabel];
    _identifierLabel.frame = CGRectMake(40, 35, SCREEN_WIDTH - 60, 20);
//    _identifierLabel.font = [UIFont systemFontOfSize:13];
    _identifierLabel.adjustsFontSizeToFitWidth = YES;
    
    _rissLabel = [[UILabel alloc]init];
    [self.contentView addSubview:_rissLabel];
    _rissLabel.frame = CGRectMake(10, 40, 30, 20);
    _rissLabel.font = [UIFont systemFontOfSize:13];
    
    
    _titleLabel.textColor = [UIColor colorWithHexString:@"3d3d3d"];
    _identifierLabel.textColor = [UIColor colorWithHexString:@"3d3d3d"];
    _rissLabel.textColor = [UIColor colorWithHexString:@"3d3d3d"];
}

@end
