//
//  GenerateViewController.h
//  QuickResponse
//
//  Created by Haifisch on 10/25/13.
//  Copyright (c) 2013 Haifisch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShareKit.h"

#import "QRCodeGenerator.h"
@interface GenerateViewController : UIViewController <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
    NSArray            *countryNames;
    BOOL isURL, isEmail, isPhone, isPlain;
}
@property (strong, nonatomic) IBOutlet UIImageView *qrImageView;
- (IBAction)generateQR:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *qrText;
- (IBAction)share:(id)sender;
- (IBAction)exit:(id)sender;

@end
