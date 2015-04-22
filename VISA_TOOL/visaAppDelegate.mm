//
//  visaAppDelegate.m
//  VISA_TOOL
//
//  Created by 付绘彬 on 15-4-20.
//  Copyright (c) 2015年 ___FULLUSERNAME___. All rights reserved.
//

#import "visaAppDelegate.h"

@implementation visaAppDelegate
@synthesize Gpib_window;
@synthesize Cmd;
@synthesize VisaAdd;
@synthesize TextRead;

-(id)init{
    self = [super init];
    gpibport = new VisaPort();
    if(self){
        
    }
    return self;
}

-(void)dealloc{
    delete gpibport;
    [pGPIBComm release];
    [super dealloc];
}

-(void)awakeFromNib{
  //  [self SearchGPIBAdd:nil];
    
    
    

}

-(void)GPIBDeviceInitial{
 
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}


- (IBAction)SearchGPIBAdd:(id)sender {
    NSMutableArray *searchedDevice = [[NSMutableArray alloc]init];
    searchedDevice = [GPIBComm ScanGPIBDevice];
    if (searchedDevice == nil || [searchedDevice count]<=0) {
        NSRunAlertPanel(@"GPIB Instrument", @"No device find!!", @"ok", nil, nil);
    }
    [VisaAdd removeAllItems];
    [VisaAdd addItemsWithObjectValues:searchedDevice];
  //  [VisaAdd selectItemAtIndex:0];
    
}

- (IBAction)OpenGpibAdd:(id)sender {
    if (VisaAdd.stringValue.length == 0) {
        NSRunAlertPanel(@"GPIB Instrument", @"No GPIB Device Selected", @"ok", nil, nil);
    }else{
        [pGPIBComm Close] ;
        if (pGPIBComm)
        {
            [pGPIBComm release] ;
            pGPIBComm = nil ;
        }
        NSString *GpibAddress = VisaAdd.stringValue;
        if ([pGPIBComm Open:GpibAddress]) {
            NSRunAlertPanel(@"GPIB Instrument", @"Can't open the GPIB address", @"ok", nil, nil);
        }else{
          [Gpib_window setTitle:pGPIBComm.mInstrIDN];
        }
        gpibport->AttachSerialPort(pGPIBComm);
        return ;
    }
    
    
}

- (IBAction)SendCmd:(id)sender {
    
    if (Cmd.stringValue.length<=0)
        return ;
    
    NSString *cmd = [NSString stringWithFormat:@"%@\n",Cmd.stringValue] ;
    if ([pGPIBComm Send:cmd])
    {
        [[[TextRead textStorage] mutableString] appendFormat:@"\nSend :%@",cmd] ;
        NSRange theRange = NSMakeRange([[TextRead textStorage]length], 0);
        [TextRead scrollRangeToVisible:theRange];
    }
    

    
}

- (IBAction)ReadResult:(id)sender {
    NSString *readStr = [pGPIBComm Read] ;
    if (readStr!=nil)
    {
        [[[TextRead textStorage] mutableString] appendFormat:@"\nRead :%@",readStr] ;
        NSRange theRange = NSMakeRange([[TextRead textStorage]length], 0);
        [TextRead scrollRangeToVisible:theRange];
    }

}

- (IBAction)QueryInstrument:(id)sender {
    if (Cmd.stringValue.length<=0)
        return ;
    
    NSString *cmd = [NSString stringWithFormat:@"%@\n",Cmd.stringValue] ;
    if ([pGPIBComm Send:cmd])
    {
        [[[TextRead textStorage] mutableString] appendFormat:@"\nSend :%@",cmd] ;
        NSRange theRange = NSMakeRange([[TextRead textStorage]length], 0);
        [TextRead scrollRangeToVisible:theRange];
    }
    
    NSString *readStr = [pGPIBComm Read] ;
    if (readStr!=nil)
    {
        [[[TextRead textStorage] mutableString] appendFormat:@"\nRead :%@",readStr] ;
        NSRange theRange = NSMakeRange([[TextRead textStorage]length], 0);
        [TextRead scrollRangeToVisible:theRange];
    }

}

- (void)windowWillClose:(NSNotification *)notification{
    [NSApp terminate:nil];
}

@end
