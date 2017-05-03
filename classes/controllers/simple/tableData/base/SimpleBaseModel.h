//
//  SimpleBaseModel.h
//  DMTableRefresher
//
//  Created by Dmitry Avvakumov on 15.03.17.
//  Copyright © 2017 Dmitry Avvakumov. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SimpleTableViewProtocols.h"

@interface SimpleBaseModel : NSObject <SimpleModelProtocol, NSCopying>

@property (strong, nonatomic) NSNumber *itemID;
@property (strong, nonatomic) NSString *title;

@end
