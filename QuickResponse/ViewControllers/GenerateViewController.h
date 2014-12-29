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
#import <AVFoundation/AVFoundation.h>
@interface GenerateViewController : UIViewController <UITextFieldDelegate, UIDocumentInteractionControllerDelegate, AVCaptureMetadataOutputObjectsDelegate>


@property(nonatomic, strong) UIView *previewView;
@property(nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (strong, nonatomic) IBOutlet UIView *cameraView;
@property(nonatomic, strong) AVCaptureSession *session;


@property (strong, nonatomic) IBOutlet UIImageView *qrImageView;
@property (strong, nonatomic) IBOutlet UITextField *qrText;

- (IBAction)generateQR:(id)sender;
- (IBAction)share:(id)sender;
- (IBAction)exit:(id)sender;

@end
