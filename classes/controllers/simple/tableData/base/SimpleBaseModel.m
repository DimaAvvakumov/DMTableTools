//
//  SimpleBaseModel.m
//  DMTableRefresher
//
//  Created by Dmitry Avvakumov on 15.03.17.
//  Copyright © 2017 Dmitry Avvakumov. All rights reserved.
//

#import "SimpleBaseModel.h"

#import "SimpleBaseConfigurator.h"

@interface SimpleBaseModel()

@property (strong, nonatomic) SimpleBaseConfigurator *cfg;

@end

@implementation SimpleBaseModel

+ (NSString *)cellIdentifier {
    return @"SimpleCell";
}

- (id<DMTableRefresherConfiguratorProtocol>)configurator {
    if (_cfg == nil) {
        self.cfg = [SimpleBaseConfigurator new];
    }
    
    return _cfg;
}


@end
