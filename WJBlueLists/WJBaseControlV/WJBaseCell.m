//
//  WJBaseCell.m
//  WJBlueLists
//
//  Created by wenjuan on 16/5/9.
//  Copyright © 2016年 wenjuan. All rights reserved.
//

#import "WJBaseCell.h"

@implementation WJBaseCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        
        UIView *lineView = [[UIView alloc]init];
        lineView.backgroundColor = [UIColor colorWithHexString:@"c3c3c3"];
        [self.contentView addSubview:lineView];
        
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.right.equalTo(self.contentView);
            make.left.equalTo(self.contentView).offset(10);
            make.height.equalTo(@1);
        }];
        
        
        _arrowImageV = [[UIImageView alloc]init];
        [self.contentView addSubview:_arrowImageV];
        _arrowImageV.image = [UIImage imageNamed:@"rightArrow"];
        [_arrowImageV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.width.equalTo(@12);
            make.centerY.equalTo(self.contentView);
            make.right.equalTo(self.contentView).offset(-10);
        }];
        
        
    }
    return self;
}



@end
