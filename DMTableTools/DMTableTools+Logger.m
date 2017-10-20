//
//  DMTableTools+Logger.m
//  DMTableTools
//
//  Created by Dmitry Avvakumov on 20.10.17.
//  Copyright © 2017 Dmitry Avvakumov. All rights reserved.
//

#import "DMTableTools+Logger.h"

@implementation DMTableTools (Logger)

- (void)logger_prepareForStartBinding {
    if (![self logger_accessForLevel:DMTableToolsLoggerLevel_All]) return;
    
    NSLog(@"\n--\nDMTableTools:Start with data;\nToken:%@\n", self.processToken);
}

- (void)logger_beforeBatchUpdate {
    if (![self logger_accessForLevel:DMTableToolsLoggerLevel_All]) return;
    
    NSLog(@"\n--\nDMTableTools:Before batch update;\nToken:%@\n", self.processToken);
}

- (void)logger_finishedBatchUpdate {
    if (![self logger_accessForLevel:DMTableToolsLoggerLevel_All]) return;
    
    NSLog(@"\n--\nDMTableTools:Finished batch update;\nToken:%@\n", self.processToken);
}

- (void)logger_noContinueData {
    if (![self logger_accessForLevel:DMTableToolsLoggerLevel_All]) return;
    
    NSLog(@"\n--\nDMTableTools:Continue data is empty. Stop update.;\nToken:%@\n", self.processToken);
}

- (void)logger_prepareForNewCircle {
    if (![self logger_accessForLevel:DMTableToolsLoggerLevel_All]) return;
    
    NSLog(@"\n--\nDMTableTools:Continue data is exist. Prepare for new circle of update.;\nToken:%@\n", self.processToken);
}

- (BOOL)logger_accessForLevel:(DMTableToolsLoggerLevel)level {
    if (self.loggerLevel == level) return YES;
    if (self.loggerLevel > level) return YES;
    
    return NO;
}

@end
