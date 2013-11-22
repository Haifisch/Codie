//
//  GenerateViewController.m
//  QuickResponse
//
//  Created by Haifisch on 10/25/13.
//  Copyright (c) 2013 Haifisch. All rights reserved.
//

#import "GenerateViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface GenerateViewController ()

@end

@implementation GenerateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    isEmail = YES;
    isURL = NO;
    isPhone = NO;
    isPlain = NO;
    self.qrImageView.image = [QRCodeGenerator qrImageForString:@"QuickResponse is awesome!" imageSize:self.qrImageView.bounds.size.width];
    countryNames = [[NSArray alloc] initWithObjects:@"URL",@"Phone Number",@"Email", @"Plain Text",nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:
(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    return [countryNames count];
}
- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return [countryNames objectAtIndex:row];
}
#pragma mark -
#pragma mark PickerView Delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
    
    NSString *resultString = [[NSString alloc] initWithFormat:
                              @"%@",
                              [countryNames objectAtIndex:row]];
    if ([resultString isEqual:@"URL"]) {
        self.qrText.placeholder = @"URL";
        isEmail = NO;
        isURL = YES;
        isPhone = NO;
        isPlain = NO;
    }
    if ([resultString isEqual:@"Email"]) {
        self.qrText.placeholder = @"Email";
        isEmail = YES;
        isURL = NO;
        isPhone = NO;
        isPlain = NO;
    }
    if ([resultString isEqual:@"Phone Number"]) {
        self.qrText.placeholder = @"Phone Number";
        isEmail = NO;
        isURL = NO;
        isPhone = YES;
        isPlain = NO;
    }
    if ([resultString isEqual:@"Plain Text"]) {
        self.qrText.placeholder = @"Plain Text";
        isEmail = NO;
        isURL = NO;
        isPhone = NO;
        isPlain = YES;
    }
    NSLog(@"%d", isEmail);
    NSLog(@"%@",resultString);
}
- (IBAction)generateQR:(id)sender {
    NSLog(@"%d", isEmail);
    if (isEmail) {
        self.qrImageView.image = [QRCodeGenerator qrImageForString:[NSString stringWithFormat:@"MAILTO:%@", self.qrText.text] imageSize:self.qrImageView.bounds.size.width];
    }
    if (isURL) {
        self.qrImageView.image = [QRCodeGenerator qrImageForString:[NSString stringWithFormat:@"%@", self.qrText.text] imageSize:self.qrImageView.bounds.size.width];
    }
    if (isPhone) {
        self.qrImageView.image = [QRCodeGenerator qrImageForString:[NSString stringWithFormat:@"TEL:%@", self.qrText.text] imageSize:self.qrImageView.bounds.size.width];
    }
    if (isPlain) {
        self.qrImageView.image = [QRCodeGenerator qrImageForString:[NSString stringWithFormat:@"%@", self.qrText.text] imageSize:self.qrImageView.bounds.size.width];
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}
- (IBAction)share:(id)sender {
    //NSURL *url = [NSURL URLWithString:@"http://getsharekit.com"];
    SHKItem *item = [SHKItem image:self.qrImageView.image title:@"Scan this QR with #QuickResponse"];
    
    // Get the ShareKit action sheet
    SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
    
    // ShareKit detects top view controller (the one intended to present ShareKit UI) automatically,
    // but sometimes it may not find one. To be safe, set it explicitly
    [SHK setRootViewController:self];
    
    // Display the action sheet
   // [actionSheet showFromRect:CGRectZero inView:self.view animated:TRUE];
    [actionSheet showInView:self.view];
}

- (IBAction)exit:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
