//
//  ViewController.m
//  currencyConverter
//
//  Created by Dmitry on 25.07.13.
//  Copyright (c) 2013 Dmitry. All rights reserved.
//

#import "ViewController.h"

#define EXCHANGE_RATE_URL_STRING @"http://rate-exchange.appspot.com/currency?from=USD&to=EUR"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Setting exchange rate to some value, so our application can work offline.
    
    self.exchangeRate = @0.8;
    self.updateSpinner.hidden = YES;
    
    [self.textField setReturnKeyType:UIReturnKeyDone];
    self.textField.delegate = self;
    
    
    // Adding methods to buttons manually, you can see the methods in selectors.
    
    [self.updateButton addTarget:self action:@selector(getCurrencyUpdate) forControlEvents:UIControlEventTouchUpInside];
    [self.calculateButton addTarget:self action:@selector(calculate) forControlEvents:UIControlEventTouchUpInside];
    
    // Adds gesture recognizer to whole view, so it will trigger when user taps anywhere on screen but for already existing buttons. This hides the keyboard. Whole view becomes one huge button that hides keyboard on tap.
    
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:tapper];
    
}

#pragma mark UITextField delegate methods


    // This method adds Done button to our keyboard, calls calculations if we press it and hides keyboard.

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
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Enter a number" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
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
    
    NSURL *url = [NSURL URLWithString:EXCHANGE_RATE_URL_STRING];
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
