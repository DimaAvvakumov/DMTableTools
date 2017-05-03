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


#pragma mark - Model declaration

@protocol DMTableToolsModel <NSObject>

@required
- (NSString *)identifier;
- (NSString *)cellIdentifier;

@end


#pragma mark - DMTableTools

@interface DMTableTools : NSObject

#pragma mark - Initialization
+ (instancetype)toolsWithTableView:(UITableView *)tableView;

#pragma mark - Table view
@property (weak, nonatomic) UITableView *tableView;
@property (copy, nonatomic) BOOL(^modificationComparatorBlock)(id item1, id item2);

#pragma mark - Data items

/* Method must be call on main thread only 
 */

- (void)setDataItems:(NSArray <id<DMTableToolsModel>> *)dataItems withAnimation:(DMTableToolsAnimation)animation;

- (id<DMTableToolsModel>)modelAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSections;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;

@end
