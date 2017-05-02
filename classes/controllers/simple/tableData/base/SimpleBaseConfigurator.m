//
//  SimpleBaseConfigurator.m
//  DMTableRefresher
//
//  Created by Dmitry Avvakumov on 15.03.17.
//  Copyright © 2017 Dmitry Avvakumov. All rights reserved.
//

#import "SimpleBaseConfigurator.h"

#import "SimpleBaseModel.h"
#import "SimpleBaseCell.h"

@implementation SimpleBaseConfigurator

- (void)configureCell:(SimpleBaseCell *)cell withModel:(SimpleBaseModel *)model {
    
}

- (CGSize)sizeForModel:(SimpleBaseModel *)model {
    return CGSizeMake(320.0, 44.0);
}


@end
