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
#import "TLIndexPathUpdates+DMBatch.h"

#import "DMTableTools+Logger.h"

@interface DMTableTools()

/* core data items */
@property (strong, nonatomic) TLIndexPathDataModel *dataModel;
@property (assign, nonatomic) BOOL isEmptyDataModel;

/* data items hash */
@property (strong, nonatomic) NSMutableDictionary <NSString *, NSString *> *hashByModelsIDs;

/* candidate */
@property (assign, nonatomic) BOOL updateInProcess;
@property (strong, nonatomic) NSArray <id<DMTableToolsModel>> *candidateDataItems;
@property (assign, nonatomic) DMTableToolsAnimation candidateAnimation;

/* content utilizer */
@property (strong, nonatomic) NSDictionary *visibleCellsInfo;

@end

@implementation DMTableTools

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.updateInProcess = NO;
        
        self.candidateAnimation = DMTableToolsNoAnimation;
        
        self.modificationComparatorBlock = nil;
        self.sectionNameKeyPath = nil;
        
        self.tableViewRowAnimation = UITableViewRowAnimationAutomatic;
        
        self.loggerLevel = DMTableToolsLoggerLevel_None;
#ifdef DEBUG
        self.loggerLevel = DMTableToolsLoggerLevel_Warnings;
#endif
        
        self.isEmptyDataModel = YES;
        self.hashByModelsIDs = nil;
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
    // NSArray <id<DMTableToolsModel>> *copyedDataItems = [[NSArray alloc] initWithArray:dataItems copyItems:YES];
    NSArray <id<DMTableToolsModel>> *copyedDataItems = [dataItems copy];
    
    /* check for main thread */
    if (![NSThread isMainThread]) return;
    
    /* check for updating process */
    if (self.updateInProcess) {
        self.candidateDataItems = copyedDataItems;
        self.candidateAnimation = animation;
        
        return;
    }
    
    /* precess will start at this point */
    self.processToken = [NSProcessInfo processInfo].globallyUniqueString;
    
    self.isEmptyDataModel = (dataItems && [dataItems count] > 0) ? NO : YES;
    
    /* log start process */
    [self logger_prepareForStartBinding];
    
    /* check for no - animation */
    BOOL noAnimation = NO;
    if (animation == DMTableToolsNoAnimation) {
        noAnimation = YES;
    }
    if (animation == DMTableToolsFixedAnimation) {
        noAnimation = YES;
    }
    if (noAnimation) {
        /* utilize content offset */
        if (animation == DMTableToolsFixedAnimation) {
            [self utilizeContentOffset];
        }
        
        /* remove old model for reloadData imerdentaly */
        self.dataModel = nil;
        
        /* log before batch */
        [self logger_beforeBatchUpdate];
        
        [self performBatchUpdateWithItems:copyedDataItems completition:^(BOOL isSuccess) {
            
            /* log before batch */
            [self logger_finishedBatchUpdate];
            
            /* restore content offset */
            if (animation == DMTableToolsFixedAnimation) {
                [self restoreContentOffset];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self restoreContentOffset];
                });
            }
            
            [self afterBatchUpdate];
        }];

    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            /* log before batch */
            [self logger_beforeBatchUpdate];
            
            [self performBatchUpdateWithItems:copyedDataItems completition:^(BOOL isSuccess) {
                
                /* log before batch */
                [self logger_finishedBatchUpdate];
                
                [self afterBatchUpdate];
            }];
        });
        
        self.updateInProcess = YES;
    }
}

- (BOOL)isEmpty {
    return self.isEmptyDataModel;
}

- (NSArray <NSString *> *)sectionNames {
    if (self.dataModel == nil) return nil;
    
    return [self.dataModel sectionNames];
}

- (id<DMTableToolsModel>)modelAtIndexPath:(NSIndexPath *)indexPath {
    TLIndexPathItem *item = [self.dataModel itemAtIndexPath:indexPath];
    id<DMTableToolsModel> model = item.data;
    if ([model conformsToProtocol:@protocol(DMTableToolsModel)]) {
        return model;
    }
    
    return nil;
}

- (NSInteger)plainIndexByIndexPath:(NSIndexPath *)indexPath {
    TLIndexPathItem *item = [self.dataModel itemAtIndexPath:indexPath];
    NSUInteger index = [[self.dataModel items] indexOfObject:item];
    
    return index;
}

- (void)afterBatchUpdate {
    /* check for candidate */
    if (self.candidateDataItems == nil) {
        /* log before batch */
        [self logger_noContinueData];
        
        /* finish */
        self.updateInProcess = NO;
        
        return;
    }
    
    NSArray <id<DMTableToolsModel>> *dataItems = self.candidateDataItems;
    DMTableToolsAnimation animation = self.candidateAnimation;
    
    self.candidateDataItems = nil;
    
    /* log before batch */
    [self logger_prepareForNewCircle];
    
    /* finish */
    self.updateInProcess = NO;
    
    [self setDataItems:dataItems withAnimation:animation];
}

- (void)setDataModel:(TLIndexPathDataModel *)dataModel {
    _dataModel = dataModel;
    
    if (dataModel == nil) return;
    
    NSArray <TLIndexPathItem *> *items = dataModel.items;
    if (items == nil) return;
    
    NSUInteger count = [items count];
    NSMutableDictionary *hashByModels = [NSMutableDictionary dictionaryWithCapacity:count];
    
    for (TLIndexPathItem *item in items) {
        id<DMTableToolsModel> model = item.data;
        if (model == nil) continue;
        
        if (![model conformsToProtocol:@protocol(DMTableToolsModel)]) continue;
        if (![model respondsToSelector:@selector(tableTools_modifyHash)]) continue;
        
        NSString *itemID = [model tableTools_itemIdentifier];
        NSString *hash = [model tableTools_modifyHash];
        if (hash == nil) {
            hash = @"";
        }
        
        [hashByModels setObject:hash forKey:itemID];
    }
    
    self.hashByModelsIDs = hashByModels;
}

- (void)performBatchUpdateWithItems:(NSArray <id<DMTableToolsModel>> *)dataItems completition:(void(^)(BOOL isSuccess))finishBlock {
    
    
    /* array of tl index path */
    NSArray <TLIndexPathItem *> *items = [self arrayOfIndexPathItemsFromArray:dataItems];
    
    /* section name */
    NSString *sectionKeyPath = (self.sectionNameKeyPath) ? @"sectionName" : nil;
    
    /* new data model */
    TLIndexPathDataModel *newModel = [[TLIndexPathDataModel alloc] initWithItems:items sectionNameKeyPath:sectionKeyPath identifierKeyPath:nil];
    TLIndexPathDataModel *oldModel = self.dataModel;
    
    if (oldModel == nil) {
        
        self.dataModel = newModel;
        
        void(^reloadBlock)(void) = ^(void){
            [self.tableView reloadData];
            
            if (finishBlock) {
                finishBlock(YES);
            }
        };
        
        if ([NSThread isMainThread]) {
            reloadBlock();
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                reloadBlock();
            });
        }
        
        return;
    }
    
    // weak self
    __weak typeof (self) weakSelf = self;
    
    /* batch updater */
    TLIndexPathUpdates *updates = [[TLIndexPathUpdates alloc] initWithOldDataModel:oldModel updatedDataModel:newModel modificationComparatorBlock:^BOOL(TLIndexPathItem *item1, TLIndexPathItem *item2) {
        typeof (weakSelf) strongSelf = weakSelf;
        if (strongSelf == nil) return NO;
        
        /* if modification block isset */
        if (strongSelf.modificationComparatorBlock) {
            return strongSelf.modificationComparatorBlock(item1.data, item2.data);
        }
        
        /* compare with hash */
        
        id<DMTableToolsModel> model1 = item1.data;
        id<DMTableToolsModel> model2 = item2.data;
        
        /* if modify selectors not provided then set to is not modify */
        if (![model1 respondsToSelector:@selector(tableTools_modifyHash)]) return NO;
        if (![model2 respondsToSelector:@selector(tableTools_modifyHash)]) return NO;
        
        NSString *model1NewHash = [model1 tableTools_modifyHash];
        NSString *model2NewHash = nil;
        
        if ([model1 isEqual:model2]) {
            NSString *itemID = [model1 tableTools_itemIdentifier];
            NSMutableDictionary <NSString *, NSString *> *hashByModelsIDs = self.hashByModelsIDs;
            if (hashByModelsIDs == nil) return NO;
            
            model2NewHash = [hashByModelsIDs objectForKey:itemID];
        } else {
            model2NewHash = [model2 tableTools_modifyHash];
        }
        
        /* hashes are equal -> not changes */
        if ([model1NewHash isEqualToString:model2NewHash]) return NO;
        
        return YES;
    }];
    
    self.dataModel = newModel;
    
    void(^reloadBlock)(void) = ^(void){
        [updates performBatchUpdatesOnTableView:self.tableView withRowAnimation:self.tableViewRowAnimation handleModificationCompletion:^(NSArray *visibleModifiedIndexPaths) {
            
            if (visibleModifiedIndexPaths) {
                if (self.onModifyVisibleCellsBlock) {
                    self.onModifyVisibleCellsBlock( visibleModifiedIndexPaths );
                } else {
                    [self.tableView reloadRowsAtIndexPaths:visibleModifiedIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
                }
            }
            
            if (finishBlock) {
                finishBlock(YES);
            }
        }];
    };
    
    if ([NSThread isMainThread]) {
        reloadBlock();
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            reloadBlock();
        });
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSections {
    if (self.dataModel == nil) return 0;
    
    return [self.dataModel numberOfSections];
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    if (self.dataModel == nil) return 0;
    
    return [self.dataModel numberOfRowsInSection:section];
}

#pragma mark - Array for index path

- (NSArray <TLIndexPathItem *> *)arrayOfIndexPathItemsFromArray:(NSArray <id<DMTableToolsModel>> *)models {
    NSUInteger count = [models count];
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:count];
    for (id<DMTableToolsModel> model in models) {
        NSString *identifier = [model tableTools_itemIdentifier];
        NSString *sectionName = nil;
        NSString *cellIdentifier = @"Cell";
        
        /* try to get section name */
        NSString *sectionNameKeyPath = self.sectionNameKeyPath;
        if (sectionNameKeyPath) {
            @try {
                NSObject *modelCandidate = (NSObject *) model;
                NSString *sectionNameCandidate = [modelCandidate valueForKeyPath:sectionNameKeyPath];
                if (sectionNameCandidate && [sectionNameCandidate isKindOfClass:[NSString class]]) {
                    sectionName = sectionNameCandidate;
                }
            } @catch (NSException *exception) {
                NSLog(@"Declare `sectionNameKeyPath` at instance of DMTableTools without providing an implementaion of method in model");
                NSLog(@"Posible solution: append `%@` method at model", sectionNameKeyPath);
            }
        }
        
        TLIndexPathItem *item = [[TLIndexPathItem alloc] initWithIdentifier:identifier sectionName:sectionName cellIdentifier:cellIdentifier data:model];
        
        [items addObject:item];
    }
    
    return items;
}

#pragma mark - Content offset manipulation

- (void)utilizeContentOffset {
    NSArray <NSIndexPath *>*visiblePaths = self.tableView.indexPathsForVisibleRows;
    if (!visiblePaths) return;
    if ([visiblePaths count] == 0) return;
    
    NSMutableArray *infoArray = [NSMutableArray arrayWithCapacity:[visiblePaths count]];
    CGFloat offset = self.tableView.contentOffset.y;
    
    for (NSIndexPath *indexPath in visiblePaths) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        id<DMTableToolsModel> model = [self modelAtIndexPath:indexPath];
        NSString *identifier = [model tableTools_itemIdentifier];
        if (identifier == nil) continue;
        
        CGFloat cellOffset = cell.frame.origin.y;
        CGFloat offsetScreen = cellOffset - offset;
        
        NSDictionary *info = @{ @"entity": identifier, @"offset": @(offsetScreen) };
        
        [infoArray addObject:info];
    }
    
    if ([infoArray count] > 0) {
        self.visibleCellsInfo = infoArray;
    } else {
        self.visibleCellsInfo = nil;
    }
}

- (void)restoreContentOffset {
    if (self.visibleCellsInfo) {
        for (NSDictionary *info in self.visibleCellsInfo) {
            NSString *identifier = [info objectForKey:@"entity"];
            NSNumber *screenOffset = [info objectForKey:@"offset"];
            UITableView *tableView = self.tableView;
            
            NSIndexPath *indexPath = [self.dataModel indexPathForIdentifier:identifier];
            if (indexPath == nil) continue;
            
            CGRect rect = [self.tableView rectForRowAtIndexPath:indexPath];
            CGFloat offset = rect.origin.y - screenOffset.doubleValue;
            
            /* Check for out bounding offset */
            CGFloat tableHeight = tableView.frame.size.height;
            CGFloat contentHeight = tableView.contentSize.height;
            if (contentHeight > 0.0 && offset + tableHeight > contentHeight) {
                offset = contentHeight - tableHeight;
            }
            
            CGPoint contentOffset = CGPointMake(0.0, offset);
            
            [tableView setContentOffset:contentOffset];
            
            break;
        }
    }
}


@end
