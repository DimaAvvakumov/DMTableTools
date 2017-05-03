//
//  SimpleViewController+Dummy.h
//  DMTableTools
//
//  Created by Dmitry Avvakumov on 03.05.17.
//  Copyright © 2017 Dmitry Avvakumov. All rights reserved.
//

#import "SimpleViewController.h"

@protocol SimpleModelProtocol;

@interface SimpleViewController (Dummy)

- (NSArray <id<SimpleModelProtocol>> *)dataItemsFirstSet;
- (NSArray <id<SimpleModelProtocol>> *)dataItemsSecondSet;

@end
