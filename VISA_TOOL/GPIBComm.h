//
//  GPIBComm.h
//  VISA_TOOL
//
//  Created by 付绘彬 on 15-4-20.
//  Copyright (c) 2015年 付绘彬. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VISA/VISA.h>

#define receBuff_Len        3000
@interface GPIBComm : NSObject
{
	unsigned long  portStatus  ;
    NSMutableString *mInstrIDN ;
    unsigned char mReceBuff[receBuff_Len] ;
    
@private
    ViSession mDefaultRM;
    ViSession mInst;
    ViStatus mStatus;
    ViUInt32 rcount;
    
    char mStringinput[512] ;
    
    NSLock * m_gpibLock;
}

@property(readonly) NSMutableString *mInstrIDN ;
+(NSMutableArray*)ScanGPIBDevice;

-(BOOL)Open:(NSString*)gpibAddr ;
-(bool)IsOpen ;
-(void)Close ;

//send  and received data
-(BOOL)Send:(NSString*)sendCMD ;
-(NSString*)Read ;

@end
