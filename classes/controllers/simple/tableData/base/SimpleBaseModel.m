//
//  SimpleBaseModel.m
//  DMTableRefresher
//
//  Created by Dmitry Avvakumov on 15.03.17.
//  Copyright © 2017 Dmitry Avvakumov. All rights reserved.
//

#import "SimpleBaseModel.h"

@implementation SimpleBaseModel

#pragma mark - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone {
    SimpleBaseModel *model = [[[self class] allocWithZone:zone] init];
    
    model.itemID = self.itemID;
    model.title = self.title;
    
    return model;
}

#pragma mark - SimpleModelProtocol

- (NSString *)cellIdentifier {
    return @"SimpleCell";
}

- (NSString *)tableTools_itemIdentifier {
    return [NSString stringWithFormat:@"item-%@", self.itemID];
}

- (NSString *)tableTools_modifyHash {
    return self.title;
}

- (BOOL)isModifyCompareToModel:(SimpleBaseModel *)oldModel {
    if (![oldModel isKindOfClass:[SimpleBaseModel class]]) return NO;
    
    if ([self.title isEqualToString:oldModel.title]) return NO;
    
    return YES;
}

@end
