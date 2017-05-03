//
//  SimpleTableViewProtocols.h
//  DMTableTools
//
//  Created by Avvakumov Dmitry on 02.05.17.
//  Copyright © 2017 Dmitry Avvakumov. All rights reserved.
//

#ifndef SimpleTableViewProtocols_h
#define SimpleTableViewProtocols_h

#import "DMTableTools.h"

@protocol SimpleModelProtocol <DMTableToolsModel>

@required
- (BOOL)isModifyCompareToModel:(id<SimpleModelProtocol>)oldModel;

@end

@protocol SimpleCellProtocol <NSObject>

@required
- (void)configureWithModel:(id<SimpleModelProtocol>)model;

@end



#endif /* SimpleTableViewProtocols_h */
