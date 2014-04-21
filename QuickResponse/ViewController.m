//
//  ViewController.m
//  QuickResponse
//
//  Created by Haifisch on 10/24/13.
//  Copyright (c) 2013 Haifisch. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#define debug 0
@interface ViewController () <AVCaptureMetadataOutputObjectsDelegate> {
    NSTimer *_timer;
}
@property(nonatomic, strong) UIView *previewView;
@property(nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (strong, nonatomic) IBOutlet UIView *cameraView;
@property (strong, nonatomic) IBOutlet UILabel *label;
@end

@implementation ViewController
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
- (IBAction)focusTap:(id)sender{
    [self focusNow];
}
-(void)focusNow{
    NSArray *devices = [AVCaptureDevice devices];
    NSError *error;
    for (AVCaptureDevice *device in devices) {
        if ([device position] == AVCaptureDevicePositionBack) {
            [device lockForConfiguration:&error];
            if ([device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
                device.focusMode = AVCaptureFocusModeAutoFocus;
            }
            
            [device unlockForConfiguration];
        }
    }
    //NSLog(@"focusing");
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    self.session = [[AVCaptureSession alloc] init];
    
    // create the preview layer
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.previewLayer.frame = self.cameraView.bounds;
    self.previewLayer.videoGravity = AVLayerVideoGravityResize;
    //    previewLayer.orientation = AVCaptureVideoOrientationLandscapeLeft;
    // Get the Camera Device
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *camera = nil; //[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    for(camera in devices) {
        if(camera.position == AVCaptureDevicePositionBack) {
            break;
        }
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                              target:self
                                            selector:@selector(focusNow)
                                            userInfo:nil
                                             repeats:YES];    // Create a AVCaptureInput with the camera device
    [_timer fire];
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
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (![self.session isRunning]) {
        [self.session startRunning];
    }
}
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    UIAlertView *alert;
    CGRect highlightViewRect = CGRectZero;
    AVMetadataMachineReadableCodeObject *barCodeObject;
    NSString *detectionString = nil;
    NSArray *barCodeTypes = @[AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code,
                              AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code,
                              AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode];
    
    for (AVMetadataObject *metadata in metadataObjects) {
        for (NSString *type in barCodeTypes) {
            if ([metadata.type isEqualToString:type])
            {
                barCodeObject = (AVMetadataMachineReadableCodeObject *)[self.previewLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata];
                highlightViewRect = barCodeObject.bounds;
                detectionString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
                break;
            }
        }
        
        if (detectionString != nil)
        {
            NSURL *url = [[NSURL alloc] initWithString:detectionString];
            if(debug)NSLog(@"%@", [url scheme]);
            if ([[url scheme] isEqual:@"http"]) {
                if (!alertShowing) {
                    RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"No" action:^{
                        // this is the code that will be executed when the user taps "No"
                        // this is optional... if you leave the action as nil, it won't do anything
                        // but here, I'm showing a block just to show that you can use one if you want to.
                        alertShowing = NO;
                    }];
                    
                    RIButtonItem *deleteItem = [RIButtonItem itemWithLabel:@"Yes" action:^{
                        // this is the code that will be executed when the user taps "Yes"
                        // delete the object in question...
                        [[UIApplication sharedApplication] openURL:url];
                        alertShowing = NO;
                    }];
                                        alert = [[UIAlertView alloc] initWithTitle:@"Would you like to open" message:detectionString cancelButtonItem:cancelItem otherButtonItems:deleteItem,nil];
                    alertShowing = YES;
                    [alert show];
                             
                }
                if(debug)NSLog(@"It's a URL");
            }
            if ([[url scheme] isEqual:@"TEL"]) {
                if (!alertShowing) {
                    RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"No" action:^{
                        // this is the code that will be executed when the user taps "No"
                        // this is optional... if you leave the action as nil, it won't do anything
                        // but here, I'm showing a block just to show that you can use one if you want to.
                        alertShowing = NO;
                    }];
                    
                    RIButtonItem *deleteItem = [RIButtonItem itemWithLabel:@"Yes" action:^{
                        // this is the code that will be executed when the user taps "Yes"
                        // delete the object in question...
                        [[UIApplication sharedApplication] openURL:url];
                        alertShowing = NO;
                    }];
                    
                    alert = [[UIAlertView alloc] initWithTitle:@"Would you like to call" message:detectionString cancelButtonItem:cancelItem otherButtonItems:deleteItem, nil];
                    alertShowing = YES;
                    [alert show];
                    
                }
                if(debug)NSLog(@"It's a phone number");
            }
            if ([[url scheme] isEqual:@"MAILTO"]) {
                if (!alertShowing) {
                    RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"No" action:^{
                        // this is the code that will be executed when the user taps "No"
                        // this is optional... if you leave the action as nil, it won't do anything
                        // but here, I'm showing a block just to show that you can use one if you want to.
                        alertShowing = NO;
                    }];
                    
                    RIButtonItem *deleteItem = [RIButtonItem itemWithLabel:@"Yes" action:^{
                        // this is the code that will be executed when the user taps "Yes"
                        // delete the object in question...
                        [[UIApplication sharedApplication] openURL:url];
                        alertShowing = NO;
                    }];
                    alert = [[UIAlertView alloc] initWithTitle:@"Would you like to email" message:detectionString cancelButtonItem:cancelItem otherButtonItems:deleteItem, nil];
                    alertShowing = YES;
                    [alert show];
                    
                }
                if(debug)NSLog(@"It's a email");
            }
            if (![url scheme]) {
                if (!alertShowing) {
                    RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"Ok" action:^{
                        // this is the code that will be executed when the user taps "No"
                        // this is optional... if you leave the action as nil, it won't do anything
                        // but here, I'm showing a block just to show that you can use one if you want to.
                        alertShowing = NO;
                    }];
                    
                    RIButtonItem *deleteItem = [RIButtonItem itemWithLabel:@"Copy" action:^{
                        // this is the code that will be executed when the user taps "Yes"
                        // delete the object in question...
                        UIPasteboard *appPasteBoard = [UIPasteboard generalPasteboard];
                        [appPasteBoard setString:detectionString];
                        alertShowing = NO;
                    }];
                    alert = [[UIAlertView alloc] initWithTitle:Nil message:detectionString cancelButtonItem:cancelItem otherButtonItems:deleteItem, nil];
                    alertShowing = YES;
                    [alert show];
                    
                }
                if(debug)NSLog(@"It's plain :(");
            }

            _label.text = detectionString;
            break;
        }
        else
            _label.text = @"(none)";
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    alertShowing = NO;
}

- (IBAction)light:(id)sender {

        if (flashlightOn == NO)
        {
            flashlightOn = YES;
            [self turnTorchOn:YES];
        }
        else
        {
            flashlightOn = NO;
            [self turnTorchOn:NO];
        }
        

}
- (void) turnTorchOn: (bool) on {
    
    // check if flashlight available
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]){
            
            [device lockForConfiguration:nil];
            if (on) {
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
                //torchIsOn = YES; //define as a variable/property if you need to know status
            } else {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
                //torchIsOn = NO;
            }
            [device unlockForConfiguration];
        }
    } }

@end
