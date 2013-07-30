//
//  ViewController.h
//  currencyConverter
//
//  Created by Dmitry on 25.07.13.
//  Copyright (c) 2013 Dmitry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *updateSpinner;

@property (weak, nonatomic) IBOutlet UIButton *updateButton;
@property (weak, nonatomic) IBOutlet UIButton *swapButton;

@property (weak, nonatomic) IBOutlet UILabel *mainLabel;

@property (weak, nonatomic) IBOutlet UILabel *leftLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;

@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (weak, nonatomic) IBOutlet UIButton *calculateButton;

@property (strong, nonatomic) NSNumber *exchangeRate;

@property (strong, nonatomic) NSString *fromCurrency;
@property (strong, nonatomic) NSString *toCurrency;








- (void) getCurrencyUpdate;

@end
