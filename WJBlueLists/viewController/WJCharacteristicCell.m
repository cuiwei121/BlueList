//
//  WJCharacteristicCell.m
//  WJBlueLists
//
//  Created by wenjuan on 16/5/17.
//  Copyright © 2016年 wenjuan. All rights reserved.
//

#import "WJCharacteristicCell.h"

@implementation WJCharacteristicCell

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
        self.arrowImageV.hidden = YES;
        [self createCellView];
    }
    return self;
}

- (void)createCellView {
    _textDataLabel = [[UILabel alloc]init];
    [self.contentView addSubview:_textDataLabel];
    [_textDataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(15);
        make.right.equalTo(self.contentView).offset(-15);
    }];
    
    
    _textDataLabel.textColor = [UIColor colorWithHexString:@"3d3d3d"];
    _textDataLabel.font = WJFont(15);
    
}


@end
