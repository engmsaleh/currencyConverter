//
//  ViewController.m
//  currencyConverter
//
//  Created by Dmitry on 25.07.13.
//  Copyright (c) 2013 Dmitry. All rights reserved.
//

#import "ViewController.h"
#import "CurrencyPickerViewController.h"

#define EXCHANGE_RATE_URL_STRING @"http://rate-exchange.appspot.com/currency?"
#define KLEFTLABELTAG 99
#define KRIGHTLABELTAG 77

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Currency Converter";
    
    // Setting exchange rate to some value, so our application can work offline.
    
    self.exchangeRate = @0.753;
    self.updateSpinner.hidden = YES;
    
    [self.textField setReturnKeyType:UIReturnKeyDone];
    self.textField.delegate = self;
    
    
    // Adding methods to buttons manually, you can see the methods in selectors.
    
    [self.updateButton addTarget:self action:@selector(getCurrencyUpdate) forControlEvents:UIControlEventTouchUpInside];
    [self.calculateButton addTarget:self action:@selector(calculate) forControlEvents:UIControlEventTouchUpInside];
    [self.swapButton addTarget:self action:@selector(swap) forControlEvents:UIControlEventTouchUpInside];
    
    // Adds gesture recognizer to whole view, so it will trigger when user taps anywhere on screen but for already existing buttons. This hides the keyboard. Whole view becomes one huge button that hides keyboard on tap.
    
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:tapper];
    
    // Adds gesture recognizer to left currency label
    
    UITapGestureRecognizer *tapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(callTableView:)];
    [self.leftLabel addGestureRecognizer:tapOne];
    
    UITapGestureRecognizer *tapTwo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(callTableView:)];
    [self.rightLabel addGestureRecognizer:tapTwo];
    
    self.leftLabel.userInteractionEnabled = YES;
    self.rightLabel.userInteractionEnabled = YES;
    
    self.leftLabel.tag = KLEFTLABELTAG;
    self.rightLabel.tag = KRIGHTLABELTAG;
    
    
    // Adding self to notification center - listening to certain notifications and calling related methods when received.
    // The method is called and notification is provided to it.
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(fromCurrencyChanged:) name:FROM_CURRENCY_CHANGED_NOTFICATION object:nil];
    [center addObserver:self selector:@selector(toCurrencyChanged:) name:TO_CURRENCY_CHANGED_NOTIFICATION object:nil];
    
    self.fromCurrency = @"USD";
    self.toCurrency = @"EUR";
}

- (void) viewWillAppear:(BOOL)animated
{
    [self getCurrencyUpdate];
}


- (void) fromCurrencyChanged:(NSNotification *) notification
{
    self.fromCurrency = notification.userInfo[@"currency"];
    self.leftLabel.text = self.fromCurrency;
    
}

- (void) toCurrencyChanged:(NSNotification *) notification
{
    self.toCurrency = notification.userInfo[@"currency"];
    self.rightLabel.text = self.toCurrency;
    
}

- (void) callTableView:(UITapGestureRecognizer *) sender
{
    NSString *temp;
    
    if (sender.view.tag == KLEFTLABELTAG) {
        temp = @"from";
    }
    
    else if (sender.view.tag) {
        temp = @"to";
    }

    CurrencyPickerViewController *picker = [[CurrencyPickerViewController alloc] initWithString:temp];
    [self.navigationController pushViewController:picker animated:YES];
}

- (void) swap
{
    NSString *temp = self.fromCurrency;
    self.fromCurrency = self.toCurrency;
    self.toCurrency = temp;
    
    self.leftLabel.text = self.fromCurrency;
    self.rightLabel.text = self.toCurrency;
    [self getCurrencyUpdate];
}

#pragma mark UITextField delegate methods


    // This method adds Done button to our keyboard, calls calculations if we dm it and hides keyboard.

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    [self calculate];
    return YES;
}


    // This method hides keyboard when we tap anywhere on screen.

- (void) hideKeyboard
{
    [self.textField resignFirstResponder];
}

    // This method takes value from text field, checks if it is not zero and then calculates total.

-(void) calculate
{
    double temp = [self.textField.text doubleValue];
    if (temp != 0) {
        self.resultLabel.text = [NSString stringWithFormat:@"%.2f", (temp * [self.exchangeRate doubleValue])];
    }
    
        // If the value in text field is bad, pop alert view.
    
        // commenting this out, since it pops every time automatic update takes place
    
//    else
//    {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Enter a number" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//        [alert show];
//    }
}

    // This delegate method checks for entry only of numeric characters into text field.

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    /* for backspace */
    if([string length]==0){
        return YES;
    }
    
    /*  limit to only numeric characters  */
    
    NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    for (int i = 0; i < [string length]; i++) {
        unichar c = [string characterAtIndex:i];
        if ([myCharSet characterIsMember:c]) {
            return YES;
        }
    }
    
    return NO;
}

    // Calls server and tries to get updated rate.

- (void) getCurrencyUpdate
{
    [self.updateSpinner startAnimating];
    self.updateSpinner.hidden = NO;
    
    
    NSString *temp = EXCHANGE_RATE_URL_STRING;
    temp = [NSString stringWithFormat:@"%@from=%@&to=%@", temp, self.fromCurrency, self.toCurrency];
    
    NSURL *url = [NSURL URLWithString:temp];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    NSURLConnection *myConnection = [[NSURLConnection alloc] initWithRequest:requestObj delegate:self startImmediately:YES];
    
    // Supressing warning
    
    NSLog(@"%@", myConnection);
}


#pragma mark NSURLConnection deleage methods

    /* This method is getting called when we actually managed to get stuff from server and logs error if it failed.
     It also tries to convert received data into NSMutableDictionary and we access the rate from it and sets our rate property to the one from server.
     Also recalculates results.
     */

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSError *error;
    
    NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
    if (error) {
        NSLog(@"Error: %@", [error localizedDescription]);  
    }
    else
    {
        NSLog(@"Received data from server: %@", dict);
        self.exchangeRate = dict[@"rate"];
        self.mainLabel.text = [NSString stringWithFormat:@"%.2f", [self.exchangeRate floatValue]];
        [self calculate];
    }
    [self.updateSpinner stopAnimating];
    self.updateSpinner.hidden = YES;
}


@end
