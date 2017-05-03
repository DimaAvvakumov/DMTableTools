//
//  SimpleBaseCell.h
//  DMTableRefresher
//
//  Created by Dmitry Avvakumov on 15.03.17.
//  Copyright © 2017 Dmitry Avvakumov. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SimpleTableViewProtocols.h"

@interface SimpleBaseCell : UITableViewCell <SimpleCellProtocol>

@property (strong, nonatomic) IBOutlet UILabel *craftLabel;

@end
