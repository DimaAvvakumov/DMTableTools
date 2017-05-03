//
//  SimpleViewController+Dummy.m
//  DMTableTools
//
//  Created by Dmitry Avvakumov on 03.05.17.
//  Copyright © 2017 Dmitry Avvakumov. All rights reserved.
//

#import "SimpleViewController+Dummy.h"

#import "NSString+Fish.h"

#import "SimpleBaseModel.h"

@implementation SimpleViewController (Dummy)

- (NSArray <id<SimpleModelProtocol>> *)dataItemsFirstSet {
    NSUInteger count = 100;
    NSMutableArray *dataItems = [NSMutableArray arrayWithCapacity:count];
    
    for (int i = 0; i < count; i++) {
        NSNumber *itemID = @(i + 1);
        
        SimpleBaseModel *model = [SimpleBaseModel new];
        model.itemID = itemID;
        model.title = [NSString generateRandomFishWithLength:64];
        
        [dataItems addObject:model];
    }
    
    return dataItems;
}

- (NSArray <id<SimpleModelProtocol>> *)dataItemsSecondSet {
    NSUInteger count = 80;
    NSMutableArray *dataItems = [NSMutableArray arrayWithCapacity:count];
    
    for (int i = 10; i < count; i++) {
        NSNumber *itemID = @(i + 1);
        
        SimpleBaseModel *model = [SimpleBaseModel new];
        model.itemID = itemID;
        model.title = [NSString generateRandomFishWithLength:64];
        
        [dataItems addObject:model];
    }
    
    return dataItems;
}


@end
