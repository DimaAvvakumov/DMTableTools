//
//  SimpleBaseCell.m
//  DMTableRefresher
//
//  Created by Dmitry Avvakumov on 15.03.17.
//  Copyright © 2017 Dmitry Avvakumov. All rights reserved.
//

#import "SimpleBaseCell.h"

#import "SimpleBaseModel.h"

@implementation SimpleBaseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureWithModel:(SimpleBaseModel *)model {
    
    self.craftLabel.text = model.title;
    
}

@end
