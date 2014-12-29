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
    
    // Begin camera background
    self.cameraView = [[UIView alloc] init];
    self.cameraView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    self.session = [[AVCaptureSession alloc] init];
    // create the preview layer
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.previewLayer.frame = self.cameraView.bounds;
    self.previewLayer.videoGravity = AVLayerVideoGravityResize;
    // Get the Camera Device
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *camera = nil; //[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    for(camera in devices) {
        if(camera.position == AVCaptureDevicePositionBack) {
            break;
        }
    }
    
    NSError *error=nil;
    AVCaptureDeviceInput *cameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:camera error:&error];
    if (cameraInput == nil) {
        NSLog(@"Error to create camera capture:%@",error);
    }
    // Add the input and output
    [self.session addInput:cameraInput];
    
    // Create a VideoDataOutput and add it to the session
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    [self.session addOutput:output];
    
    // see what types are supported (do this after adding otherwise the output reports nothing supported
    NSSet *potentialDataTypes = [NSSet setWithArray:@[AVMetadataObjectTypeQRCode]];
    
    NSMutableArray *supportedMetaDataTypes = [NSMutableArray array];
    for(NSString *availableMetadataObject in output.availableMetadataObjectTypes) {
        if([potentialDataTypes containsObject:availableMetadataObject]) {
            [supportedMetaDataTypes addObject:availableMetadataObject];
        }
    }
    
    [output setMetadataObjectTypes:supportedMetaDataTypes];
    
    // Get called back everytime something is recognised
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [self.cameraView.layer addSublayer:self.previewLayer];
    [self.session startRunning];
    
    // Blur camera view
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    visualEffectView.frame = self.cameraView.bounds;
    [self.cameraView addSubview:visualEffectView];
    [self.view addSubview:self.cameraView];
    [self.view sendSubviewToBack:self.cameraView];
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
    if ([self.session isRunning]) {
        [self.session stopRunning];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [self generateQR:self];
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self generateQR:self];
}
@end
