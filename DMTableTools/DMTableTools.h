//
//  DMTableTools.h
//  DMTableTools
//
//  Created by Dmitry Avvakumov on 02.05.17.
//  Copyright © 2017 Dmitry Avvakumov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#pragma mark - DMTableToolsAnimation declaration

typedef NS_ENUM(NSInteger, DMTableToolsAnimation) {
    DMTableToolsNoAnimation,
    DMTableToolsDefaultAnimation
};

typedef NS_ENUM(NSInteger, DMTableToolsLoggerLevel) {
    DMTableToolsLoggerLevel_None = 0,
    DMTableToolsLoggerLevel_Warnings = 1,
    DMTableToolsLoggerLevel_All = 2
};


#pragma mark - Model declaration

@protocol DMTableToolsModel <NSObject>

@required
- (NSString *)tableTools_itemIdentifier;
- (NSString *)cellIdentifier;

@optional
- (NSString *)tableTools_modifyHash;

@end


#pragma mark - DMTableTools

@interface DMTableTools : NSObject

#pragma mark - Initialization
+ (instancetype)toolsWithTableView:(UITableView *)tableView;

#pragma mark - Table view
@property (weak, nonatomic) UITableView *tableView;
@property (copy, nonatomic) BOOL(^modificationComparatorBlock)(id item1, id item2);
@property (copy, nonatomic) void(^onModifyVisibleCellsBlock)(NSArray <NSIndexPath *> *visibleModifiedIndexPaths);

@property (assign, nonatomic) UITableViewRowAnimation tableViewRowAnimation;

/* logger */
@property (strong, nonatomic) NSString *processToken;
@property (assign, nonatomic) DMTableToolsLoggerLevel loggerLevel;

#pragma mark - Section info
@property (strong, nonatomic) NSString *sectionNameKeyPath;

#pragma mark - Data items

/**
    @brief Method must be call on main thread only
 */
- (void)setDataItems:(NSArray <id<DMTableToolsModel>> *)dataItems withAnimation:(DMTableToolsAnimation)animation;

/**
    @brief Method determine empty or not are tools
 */
- (BOOL)isEmpty;

- (id<DMTableToolsModel>)modelAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)plainIndexByIndexPath:(NSIndexPath *)indexPath;

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSections;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;

@end
