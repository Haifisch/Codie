//
//  ViewController.h
//  QuickResponse
//
//  Created by Haifisch on 10/24/13.
//  Copyright (c) 2013 Haifisch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIAlertView+Blocks.h"
#import <AVFoundation/AVFoundation.h>
#import "QRCodeGenerator.h"
@interface ViewController : UIViewController <UIAlertViewDelegate> {
    BOOL alertShowing;
    BOOL flashlightOn;
}
- (IBAction)light:(id)sender;
- (IBAction)focusTap:(id)sender;
@property(nonatomic, strong) AVCaptureSession *session;
@end
