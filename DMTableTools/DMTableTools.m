//
//  DMTableTools.m
//  DMTableTools
//
//  Created by Dmitry Avvakumov on 02.05.17.
//  Copyright © 2017 Dmitry Avvakumov. All rights reserved.
//

#import "DMTableTools.h"

@implementation DMTableTools

#pragma mark - Initialization
+ (instancetype)toolsWithTableView:(UITableView *)tableView {
    DMTableTools *item = [DMTableTools new];
    item.tableView = tableView;
}


#pragma mark - Data items

- (void)setDataItems:(NSArray *)dataItems {
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSections {
    return 0;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    return 0;
}

@end
