//
//  TLIndexPathUpdates+DMBatch.m
//  DMTableTools
//
//  Created by Dmitry Avvakumov on 03.05.17.
//  Copyright © 2017 Dmitry Avvakumov. All rights reserved.
//

#import "TLIndexPathUpdates+DMBatch.h"

@implementation TLIndexPathUpdates (DMBatch)

- (void)performBatchUpdatesOnTableView:(UITableView *)tableView withRowAnimation:(UITableViewRowAnimation)animation handleModificationCompletion:(void (^)(NSArray *visibleModifiedIndexPaths))completion {
    if (!self.oldDataModel) {
        [tableView reloadData];
        if (completion) {
            completion(nil);
        }
        return;
    }
    
    [CATransaction begin];
    
    [CATransaction setCompletionBlock: ^{
        
        //modified items have to be reloaded after all other batch updates
        //because, otherwise, the table view will throw an exception about
        //duplicate animations being applied to cells. This doesn't always look
        //nice, but it is better than a crash.
        NSArray *visibleModifiedIndexPaths = nil;
        
        if (self.modifiedItems.count && self.updateModifiedItems) {
            
            NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
            for (id item in self.modifiedItems) {
                NSIndexPath *indexPath = [self.updatedDataModel indexPathForItem:item];
                [indexPaths addObject:indexPath];
            }
            
            visibleModifiedIndexPaths = [self dm_intersectArray:tableView.indexPathsForVisibleRows withArray:indexPaths];
            // [tableView reloadRowsAtIndexPaths:visibleModifiedIndexPaths withRowAnimation:animation];
        }
        
        if (completion) {
            completion( visibleModifiedIndexPaths );
        }
        
    }];
    
    [tableView beginUpdates];
    
    if (self.insertedSectionNames.count) {
        NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
        for (NSString *sectionName in self.insertedSectionNames) {
            NSInteger section = [self.updatedDataModel sectionForSectionName:sectionName];
            [indexSet addIndex:section];
        }
        [tableView insertSections:indexSet withRowAnimation:animation];
    }
    
    if (self.deletedSectionNames.count) {
        NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
        for (NSString *sectionName in self.deletedSectionNames) {
            NSInteger section = [self.oldDataModel sectionForSectionName:sectionName];
            [indexSet addIndex:section];
        }
        [tableView deleteSections:indexSet withRowAnimation:animation];
    }
    
    //    // TODO Disable reordering sections because it may cause duplicate animations
    //    // when a item is inserted, deleted, or moved in that section. Need to figure
    //    // out how to avoid the duplicate animation.
    //    if (self.movedSectionNames.count) {
    //        for (NSString *sectionName in self.movedSectionNames) {
    //            NSInteger oldSection = [self.oldDataModel sectionForSectionName:sectionName];
    //            NSInteger updatedSection = [self.updatedDataModel sectionForSectionName:sectionName];
    //            [tableView moveSection:oldSection toSection:updatedSection];
    //        }
    //    }
    
    if (self.insertedItems.count) {
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        for (id item in self.insertedItems) {
            NSIndexPath *indexPath = [self.updatedDataModel indexPathForItem:item];
            [indexPaths addObject:indexPath];
        }
        [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    }
    
    if (self.deletedItems.count) {
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        for (id item in self.deletedItems) {
            NSIndexPath *indexPath = [self.oldDataModel indexPathForItem:item];
            [indexPaths addObject:indexPath];
        }
        [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    }
    
    if (self.movedItems.count) {
        for (id item in self.movedItems) {
            NSIndexPath *oldIndexPath = [self.oldDataModel indexPathForItem:item];
            NSIndexPath *updatedIndexPath = [self.updatedDataModel indexPathForItem:item];
            
            NSString *oldSectionName = [self.oldDataModel sectionNameForSection:oldIndexPath.section];
            NSString *updatedSectionName = [self.updatedDataModel sectionNameForSection:updatedIndexPath.section];
            BOOL oldSectionDeleted = [self.deletedSectionNames containsObject:oldSectionName];
            BOOL updatedSectionInserted = [self.insertedSectionNames containsObject:updatedSectionName];
            // `UITableView` doesn't support moving an item out of a deleted section
            // or moving an item into an inserted section. So we use inserts and/or deletes
            // as a workaround. A better workaround can be employed in client code by
            // by using empty sections to ensure all sections exist at all times, which
            // generally results in a better looking animation. When using `TLIndexPathControlelr`,
            // a good place to implement this workaround is in the `willUpdateDataModel`
            // delegate method by taking the incoming data model and inserting missing sections
            // with empty instances of `TLIndexPathSectionInfo`.
            if (oldSectionDeleted && updatedSectionInserted) {
                // don't need to do anything
            } else if (oldSectionDeleted) {
                [tableView insertRowsAtIndexPaths:@[updatedIndexPath] withRowAnimation:animation];
            } else if (updatedSectionInserted) {
                [tableView deleteRowsAtIndexPaths:@[oldIndexPath] withRowAnimation:animation];
                [tableView insertRowsAtIndexPaths:@[updatedIndexPath] withRowAnimation:animation];
            } else {
                [tableView moveRowAtIndexPath:oldIndexPath toIndexPath:updatedIndexPath];
            }
            
        }
    }
    
    [tableView endUpdates];
    
    [CATransaction commit];
}

- (NSArray *)dm_intersectArray:(NSArray *)firstArray withArray:(NSArray *)secondArray {
    NSMutableSet *set1 = [NSMutableSet setWithArray: firstArray];
    NSSet *set2 = [NSSet setWithArray: secondArray];
    [set1 intersectSet: set2];
    return [set1 allObjects];
}


@end
