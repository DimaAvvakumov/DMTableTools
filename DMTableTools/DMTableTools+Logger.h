//
//  DMTableTools+Logger.h
//  DMTableTools
//
//  Created by Dmitry Avvakumov on 20.10.17.
//  Copyright © 2017 Dmitry Avvakumov. All rights reserved.
//

#import "DMTableTools.h"

@interface DMTableTools (Logger)

- (void)logger_prepareForStartBinding;
- (void)logger_beforeBatchUpdate;
- (void)logger_finishedBatchUpdate;

- (void)logger_noContinueData;
- (void)logger_prepareForNewCircle;

@end
