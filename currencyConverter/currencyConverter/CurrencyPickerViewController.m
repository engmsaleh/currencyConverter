//
//  CurrencyPickerViewController.m
//  currencyConverter
//
//  Created by Dmitry on 29.07.13.
//  Copyright (c) 2013 Dmitry. All rights reserved.
//

#import "CurrencyPickerViewController.h"

@interface CurrencyPickerViewController ()

@end

@implementation CurrencyPickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithString:(NSString *) string
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        
        if ([string isEqualToString:@"from"]) {
            self.targetString = string;
        }
        else if ([string isEqualToString:@"to"]) {
            self.targetString = string;
        }
        else {
            NSException *exception = [[NSException alloc] initWithName:@"Failure to init table view!" reason:@"Wrong string provided, use \"from\" or \"to\"." userInfo:nil];
            [exception raise];
        }
    
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Making UITableView in code
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 768) style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    
    // For this to work we need to set our class header file to conform to these protocols, see .h file
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CellIdentifier"];
    
    self.currencyCodes = @[@"AED", @"ARS", @"BGN", @"BRL", @"CAD", @"USD", @"EUR", @"RUR"];
    self.currencyList = @[@"United Arab Emirates Dirham", @"Argentina Peso", @"Bulgaria Lev", @"Brazil Real", @"Canada Dollar", @"USA Dollar", @"Euro", @"Russian Rouble"];
}

#pragma mark UITableView delegate methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];

    cell.textLabel.text = self.currencyList[indexPath.row];
    cell.detailTextLabel.text = self.currencyCodes[indexPath.row];

    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.currencyCodes count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.currencySelected = self.currencyCodes[indexPath.row];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    if ([self.targetString isEqualToString:@"from"]) {
        [center postNotificationName:FROM_CURRENCY_CHANGED_NOTFICATION object:self userInfo:@{@"currency": self.currencySelected}];
    }
    else {
        [center postNotificationName:TO_CURRENCY_CHANGED_NOTIFICATION object:self userInfo:@{@"currency": self.currencySelected}];
    }
    
    [self performSelector:@selector(removeSelf) withObject:nil afterDelay:0.2];
}

- (void) removeSelf
{
    [self.navigationController popViewControllerAnimated:YES];
}





















- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
