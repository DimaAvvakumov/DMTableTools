//
//  TLIndexPathUpdates+DMBatch.h
//  DMTableTools
//
//  Created by Dmitry Avvakumov on 03.05.17.
//  Copyright © 2017 Dmitry Avvakumov. All rights reserved.
//

#import <TLIndexPathTools/TLIndexPathTools.h>

@interface TLIndexPathUpdates (DMBatch)

- (void)performBatchUpdatesOnTableView:(UITableView *)tableView withRowAnimation:(UITableViewRowAnimation)animation handleModificationCompletion:(void (^)(NSArray *visibleModifiedIndexPaths))completion;

@end
