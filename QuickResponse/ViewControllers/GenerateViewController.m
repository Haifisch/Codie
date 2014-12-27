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
{
    UIDocumentInteractionController *documentInteractionController;
}

@end

@implementation GenerateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Configure the view.
    [self.qrText becomeFirstResponder];
    self.qrImageView.image = [QRCodeGenerator qrImageForString:@"Codie is awesome!" imageSize:255];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)generateQR:(id)sender {
    if (!([self.qrText.text length] > 0)) {
        self.qrImageView.image = [QRCodeGenerator qrImageForString:[NSString stringWithFormat:@"Example QR"] imageSize:255];
    }else {
        self.qrImageView.image = [QRCodeGenerator qrImageForString:[NSString stringWithFormat:@"%@", self.qrText.text] imageSize:255];
    }
}
- (IBAction)share:(id)sender {
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[self.qrImageView.image] applicationActivities:nil];
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)exit:(id)sender {
    [self.qrText resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self generateQR:self];
}
@end
