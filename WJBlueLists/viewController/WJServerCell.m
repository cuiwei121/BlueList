//
//  WJServerCell.m
//  WJBlueLists
//
//  Created by wenjuan on 16/5/12.
//  Copyright © 2016年 wenjuan. All rights reserved.
//

#import "WJServerCell.h"

@implementation WJServerCell

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
    _nameLabel = [[UILabel alloc]init];
    _nameLabel.font = WJFont(15);
    [self.contentView addSubview:_nameLabel];
    
    _desLabel = [[UILabel alloc]init];
    _desLabel.font = WJFont(10);
    [self.contentView addSubview:_desLabel];
    
    _nameLabel.frame = CGRectMake(10, 0, SCREEN_WIDTH - 10, 40);
    _desLabel.frame = CGRectMake(10, 40, SCREEN_WIDTH - 10, 20);
    
    
    
//    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.contentView).offset(10);
//        make.bottom.equalTo(self.contentView.mas_centerX).offset(10);
//        make.right.equalTo(self.contentView);
//    }];
//    
//    [_desLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.left.equalTo(_nameLabel);
//        make.top.equalTo(_nameLabel.mas_bottom).offset(3);
//    }];
    
}

@end
