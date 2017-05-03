//
//  SimpleViewController.m
//  DMTableRefresher
//
//  Created by Dmitry Avvakumov on 15.03.17.
//  Copyright © 2017 Dmitry Avvakumov. All rights reserved.
//

#import "SimpleViewController.h"

#import "SimpleTableViewProtocols.h"

#import "SimpleBaseModel.h"

@interface SimpleViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) DMTableTools *tableTools;

@end

@implementation SimpleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    DMTableTools *tableTools = [DMTableTools toolsWithTableView:self.tableView];
    tableTools.sectionNameKeyPath = @"section";
    tableTools.modificationComparatorBlock = ^BOOL(id<SimpleModelProtocol> item1, id<SimpleModelProtocol> item2) {
        
        return [item1 isModifyCompareToModel:item2];
    };
    self.tableTools = tableTools;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Restore data

- (void)restoreData {
    SimpleBaseModel *model = [SimpleBaseModel new];
    model.itemID = @(1);
    model.title = @"Первый";
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.tableTools numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableTools numberOfRowsInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    /* model */
    id<SimpleModelProtocol> model = (id<SimpleModelProtocol>) [self.tableTools modelAtIndexPath:indexPath];
    if (![model conformsToProtocol:@protocol(SimpleModelProtocol)]) return nil;
    
    /* cell for model */
    UITableViewCell<SimpleCellProtocol> *cell = [tableView dequeueReusableCellWithIdentifier:model.cellIdentifier forIndexPath:indexPath];
    if (![cell conformsToProtocol:@protocol(SimpleCellProtocol)]) return nil;
    
    /* configure cell */
    [cell configureWithModel:model];
    
    return cell;
}

@end
