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

#import "NSString+Fish.h"

@interface SimpleViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) DMTableTools *tableTools;

@property (strong, nonatomic) NSArray *dataItems;

@end

@implementation SimpleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureTableTools];
}

- (void)configureTableTools {
    // weak self
    __weak typeof (self) weakSelf = self;
    
    DMTableTools *tableTools = [DMTableTools toolsWithTableView:self.tableView];
    tableTools.sectionNameKeyPath = nil; // @"section";
//    tableTools.modificationComparatorBlock = ^BOOL(id<SimpleModelProtocol> item1, id<SimpleModelProtocol> item2) {
//        
//        return [item1 isModifyCompareToModel:item2];
//    };
    tableTools.onModifyVisibleCellsBlock = ^(NSArray<NSIndexPath *> *visibleModifiedIndexPaths) {
        typeof (weakSelf) strongSelf = weakSelf;
        if (strongSelf == nil) return ;
        
        for (NSIndexPath *indexPath in visibleModifiedIndexPaths) {
            id<SimpleModelProtocol> model = (id<SimpleModelProtocol>) [strongSelf.tableTools modelAtIndexPath:indexPath];
            if (![model conformsToProtocol:@protocol(SimpleModelProtocol)]) return ;
            
            /* cell for model */
            UITableViewCell<SimpleCellProtocol> *cell = [strongSelf.tableView cellForRowAtIndexPath:indexPath];
            if (![cell conformsToProtocol:@protocol(SimpleCellProtocol)]) return ;
            
            [cell configureWithModel:model];
        }
    };
    self.tableTools = tableTools;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)insertNewSet:(UIButton *)sender {
    NSArray <id<SimpleModelProtocol>> *dataItems = [self randomDataItemsSet];
    
    self.dataItems = dataItems;
    
    [self.tableTools setDataItems:dataItems withAnimation:DMTableToolsDefaultAnimation];
}

- (IBAction)changeCurrentSet:(UIButton *)sender {
    NSArray *visibleIndexPaths = [self.tableView indexPathsForVisibleRows];
    if (visibleIndexPaths == nil) return;
    
    NSIndexPath *indexPath = [visibleIndexPaths firstObject];
    NSInteger index = [self.tableTools plainIndexByIndexPath:indexPath];
    if (index == NSNotFound) return;
    
    SimpleBaseModel *model = (SimpleBaseModel *) [self.dataItems objectAtIndex:index];
    model.title = [NSString generateRandomFishWithLength:64.0];
    
//    SimpleBaseModel *newModel = [model copy];
//    newModel.title = [NSString generateRandomFishWithLength:64.0];
//    
//    /* modify data items */
//    NSMutableArray *dataItems = [self.dataItems mutableCopy];
//    [dataItems replaceObjectAtIndex:index withObject:newModel];
//
//    self.dataItems = dataItems;
    
    [self.tableTools setDataItems:self.dataItems withAnimation:DMTableToolsDefaultAnimation];
}

- (IBAction)appendCurrentSet:(UIButton *)sender {
    if (self.dataItems == nil) return;
    
    NSInteger count = [self.dataItems count];
    
    SimpleBaseModel *model = [SimpleBaseModel new];
    model.itemID = @(count + 1);
    model.title = [NSString generateRandomFishWithLength:64.0];
    
    NSMutableArray *dataItems = [self.dataItems mutableCopy];
    [dataItems insertObject:model atIndex:0];
    
    self.dataItems = dataItems;
    
    [self.tableTools setDataItems:self.dataItems withAnimation:DMTableToolsDefaultAnimation];
}

- (IBAction)removeOneAction:(UIButton *)sender {
    NSArray *visibleIndexPaths = [self.tableView indexPathsForVisibleRows];
    if (visibleIndexPaths == nil) return;
    
    NSIndexPath *indexPath = [visibleIndexPaths firstObject];
    NSInteger index = [self.tableTools plainIndexByIndexPath:indexPath];
    if (index == NSNotFound) return;
    
    NSMutableArray *dataItems = [self.dataItems mutableCopy];
    [dataItems removeObjectAtIndex:index];
    
    self.dataItems = dataItems;
    
    [self.tableTools setDataItems:self.dataItems withAnimation:DMTableToolsDefaultAnimation];
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
