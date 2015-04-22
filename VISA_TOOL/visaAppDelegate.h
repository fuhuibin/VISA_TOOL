//
//  visaAppDelegate.h
//  VISA_TOOL
//
//  Created by 付绘彬 on 15-4-20.
//  Copyright (c) 2015年 ___FULLUSERNAME___. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "VisaPort.h"
#import "Visa_global.h"


@interface visaAppDelegate : NSObject <NSApplicationDelegate> {
    NSComboBox *VisaAdd;
    NSTextView *TextRead;
    NSTextField *Cmd;
    NSWindow *Gpib_window;
}

@property (assign) IBOutlet NSTextField *Cmd;
@property (assign) IBOutlet NSWindow *Gpib_window;
@property (assign) IBOutlet NSComboBox *VisaAdd;
@property (assign) IBOutlet NSTextView *TextRead;
- (IBAction)SearchGPIBAdd:(id)sender;
- (IBAction)OpenGpibAdd:(id)sender;
- (IBAction)SendCmd:(id)sender;
- (IBAction)ReadResult:(id)sender;
- (IBAction)QueryInstrument:(id)sender;
@end
