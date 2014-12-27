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

struct valueTypes {
    BOOL isEmail, isPhone, isURL, isPlain;
};

@interface ViewController () <AVCaptureMetadataOutputObjectsDelegate> {
    NSTimer *_timer;
    struct valueTypes Types;
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

    self.cameraView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
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
    Types.isEmail = NO;
    Types.isPhone = NO;
    Types.isURL = NO;
    Types.isPlain = NO;
    
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
            NSString *cleanString = [self checkStringForEach:detectionString];
            if (Types.isURL || Types.isPhone || Types.isEmail) {
                if (!alertShowing) {
                    RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"No" action:^{
                        alertShowing = NO;
                    }];
                    
                    RIButtonItem *deleteItem = [RIButtonItem itemWithLabel:@"Yes" action:^{
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:detectionString]];
                        alertShowing = NO;
                    }];
                    NSString *welcomeMessage;
                    if (Types.isURL) {
                        welcomeMessage = @"Would you like to open this link in Safari?";
                    }else if (Types.isPhone){
                        welcomeMessage = @"Would you like to call this phone number?";
                    }else if (Types.isEmail) {
                        welcomeMessage = @"Would you like to compose a new email to go to this address?";
                    }
                    alert = [[UIAlertView alloc] initWithTitle:cleanString  message:welcomeMessage cancelButtonItem:cancelItem otherButtonItems:deleteItem,nil];
                    alertShowing = YES;
                    [alert show];
                }
            }else if (Types.isPlain) {
                if (!alertShowing) {
                    RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"Ok" action:^{
                        alertShowing = NO;
                    }];
                    
                    RIButtonItem *deleteItem = [RIButtonItem itemWithLabel:@"Copy" action:^{
                        UIPasteboard *appPasteBoard = [UIPasteboard generalPasteboard];
                        [appPasteBoard setString:detectionString];
                        alertShowing = NO;
                    }];
                    alert = [[UIAlertView alloc] initWithTitle:Nil message:detectionString cancelButtonItem:cancelItem otherButtonItems:deleteItem, nil];
                    alertShowing = YES;
                    [alert show];
                }
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
    if (flashlightOn == NO) {
        flashlightOn = YES;
        [self turnTorchOn:YES];
    } else {
        flashlightOn = NO;
        [self turnTorchOn:NO];
    }
}
- (void)turnTorchOn:(bool)on {
    
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
    }
}

#pragma Regex Comparison Functions
-(NSString *)checkStringForEach:(NSString *)string {
    // Do initial check with email to remove the mailto scheme before actual checking
    if ([[[NSURL URLWithString:string] scheme] isEqual:@"MAILTO"] || [[[NSURL URLWithString:string] scheme] isEqual:@"mailto"]) {
        NSString *removeMe = [[NSURL URLWithString:string] scheme];
        string = [string stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@:",removeMe] withString:@""];
    }
    // Do the same check for phone to remove the tel scheme before actual checking
    if ([[[NSURL URLWithString:string] scheme] isEqual:@"TEL"] || [[[NSURL URLWithString:string] scheme] isEqual:@"tel"]) {
        NSString *removeMe = [[NSURL URLWithString:string] scheme];
        string = [string stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@:",removeMe] withString:@""];
    }
    // Do the actual checks
    if ([self NSStringIsValidEmail:string]) {
        Types.isEmail = YES;
        return string;
    }else if ([self NSStringIsValidLink:string]) {
        Types.isURL = YES;
        return string;
    }else if ([self NSStringIsValidPhoneNumer:string]){
        Types.isPhone = YES;
        return string;
    }else {
        Types.isPlain = YES;
        return string;
    }
}
-(BOOL)NSStringIsValidEmail:(NSString *)string
{
    NSString *stricterFilterString = @"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$";
    NSString *emailRegex = stricterFilterString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:string];
}

-(BOOL)NSStringIsValidPhoneNumer:(NSString *)string {
    NSString *laxString = @"^(?:[+]?1[-. ]?)?[(]?([0-9]{3})[)]?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$";
    NSString *phoneRegex =  laxString;
    NSPredicate *phoneText = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    return [phoneText evaluateWithObject:string];
}

-(BOOL)NSStringIsValidLink:(NSString *)string {
    NSString *laxString = @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSString *urlRegex =  laxString;
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegex];
    return [urlTest evaluateWithObject:string];
}
@end
