//
//  GenerateViewController.h
//  QuickResponse
//
//  Created by Haifisch on 10/25/13.
//  Copyright (c) 2013 Haifisch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import "QRCodeGenerator.h"
@interface GenerateViewController : UIViewController <UITextFieldDelegate, UIDocumentInteractionControllerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *qrImageView;
@property (strong, nonatomic) IBOutlet UITextField *qrText;

- (IBAction)generateQR:(id)sender;
- (IBAction)share:(id)sender;
- (IBAction)exit:(id)sender;

@end
