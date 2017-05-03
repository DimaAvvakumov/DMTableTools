//
//  DMTableTools.m
//  DMTableTools
//
//  Created by Dmitry Avvakumov on 02.05.17.
//  Copyright © 2017 Dmitry Avvakumov. All rights reserved.
//

#import "DMTableTools.h"

// frameworks
#import <TLIndexPathTools/TLIndexPathTools.h>

@interface DMTableTools()

/* core data items */
@property (strong, nonatomic) TLIndexPathDataModel *dataModel;

/* candidate */
@property (assign, nonatomic) BOOL updateInProcess;
@property (strong, nonatomic) NSArray <id<DMTableToolsModel>> *candidateDataItems;
@property (assign, nonatomic) DMTableToolsAnimation candidateAnimation;

@end

@implementation DMTableTools

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.updateInProcess = NO;
        
        self.candidateAnimation = DMTableToolsNoAnimation;
        
        self.modificationComparatorBlock = nil;
    }
    return self;
}

+ (instancetype)toolsWithTableView:(UITableView *)tableView {
    DMTableTools *item = [DMTableTools new];
    item.tableView = tableView;
    
    return item;
}


#pragma mark - Data items

- (void)setDataItems:(NSArray <id<DMTableToolsModel>> *)dataItems withAnimation:(DMTableToolsAnimation)animation {
    /* check for main thread */
    if (![NSThread isMainThread]) return;
    
    /* check for updating process */
    if (self.updateInProcess) {
        self.candidateDataItems = dataItems;
        self.candidateAnimation = animation;
        
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self performBatchUpdateWithItems:dataItems completition:^(BOOL isSuccess) {
            
            /* finish */
            self.updateInProcess = NO;
            
            [self afterBatchUpdate];
        }];
    });
    
    self.updateInProcess = YES;
}

- (id<DMTableToolsModel>)modelAtIndexPath:(NSIndexPath *)indexPath {
    id<DMTableToolsModel> model = [self.dataModel itemAtIndexPath:indexPath];
    if ([model conformsToProtocol:@protocol(DMTableToolsModel)]) {
        return model;
    }
    
    return nil;
}

- (void)afterBatchUpdate {
    if (self.candidateDataItems == nil) return;
    
    NSArray <id<DMTableToolsModel>> *dataItems = self.candidateDataItems;
    DMTableToolsAnimation animation = self.candidateAnimation;
    
    self.candidateDataItems = nil;
    
    [self setDataItems:dataItems withAnimation:animation];
}

- (void)performBatchUpdateWithItems:(NSArray <id<DMTableToolsModel>> *)dataItems completition:(void(^)(BOOL isSuccess))finishBlock {
    /* array of tl index path */
    NSArray <TLIndexPathItem *> *items = [self arrayOfIndexPathItemsFromArray:dataItems];
    
    /* new data model */
    TLIndexPathDataModel *newModel = [[TLIndexPathDataModel alloc] initWithItems:items];
    TLIndexPathDataModel *oldModel = self.dataModel;
    
    if (oldModel == nil) {
        
        self.dataModel = newModel;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            
            if (finishBlock) {
                finishBlock(YES);
            }
        });
        
        return;
    }
    
    /* batch updater */
    TLIndexPathUpdates *updates = [[TLIndexPathUpdates alloc] initWithOldDataModel:oldModel updatedDataModel:newModel modificationComparatorBlock:self.modificationComparatorBlock];
    
    self.dataModel = newModel;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [updates performBatchUpdatesOnTableView:self.tableView withRowAnimation:UITableViewRowAnimationAutomatic completion:^(BOOL finished) {
            if (finishBlock) {
                finishBlock(YES);
            }
        }];
    });
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSections {
    return 0;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    return 0;
}

#pragma mark - Array for index path

- (NSArray <TLIndexPathItem *> *)arrayOfIndexPathItemsFromArray:(NSArray <id<DMTableToolsModel>> *)models {
    NSUInteger count = [models count];
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:count];
    for (id<DMTableToolsModel> model in models) {
        NSString *identifier = [model identifier];
        NSString *sectionName = nil;
        NSString *cellIdentifier = @"Cell";
        
        TLIndexPathItem *item = [[TLIndexPathItem alloc] initWithIdentifier:identifier sectionName:sectionName cellIdentifier:cellIdentifier data:model];
        
        [items addObject:item];
    }
    
    return items;
}


@end
