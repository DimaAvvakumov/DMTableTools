//
//  DMTableTools.h
//  DMTableTools
//
//  Created by Dmitry Avvakumov on 02.05.17.
//  Copyright © 2017 Dmitry Avvakumov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DMTableTools : NSObject

#pragma mark - Initialization
+ (instancetype)toolsWithTableView:(UITableView *)tableView;

#pragma mark - Table view
@property (weak, nonatomic) UITableView *tableView;

#pragma mark - Data items
- (void)setDataItems:(NSArray *)dataItems;

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSections;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;

@end
