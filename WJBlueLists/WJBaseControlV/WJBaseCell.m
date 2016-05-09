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
        lineView.frame = CGRectMake(5,59, SCREEN_WIDTH - 10, 1);
        lineView.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:lineView];
        
    }
    return self;
}



@end
