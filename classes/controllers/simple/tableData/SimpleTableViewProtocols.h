//
//  SimpleTableViewProtocols.h
//  DMTableTools
//
//  Created by Avvakumov Dmitry on 02.05.17.
//  Copyright © 2017 Dmitry Avvakumov. All rights reserved.
//

#ifndef SimpleTableViewProtocols_h
#define SimpleTableViewProtocols_h

@protocol SimpleModelProtocol <NSObject>

+ (NSString *)cellIdentifier;

@end

@protocol SimpleCellProtocol <NSObject>

- (void)configureWithModel:(id<SimpleModelProtocol>)model;

@end



#endif /* SimpleTableViewProtocols_h */
