//
//  CurrencyPickerViewController.h
//  currencyConverter
//
//  Created by Dmitry on 29.07.13.
//  Copyright (c) 2013 Dmitry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CurrencyPickerViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *currencyCodes;
@property (strong, nonatomic) NSArray *currencyList;
@property (strong, nonatomic) NSString *targetString;
@property (strong, nonatomic) NSString *currencySelected;

- (id) initWithString:(NSString *) string;

@end
