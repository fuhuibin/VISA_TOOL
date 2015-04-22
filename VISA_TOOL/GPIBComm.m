//
//  GPIBComm.m
//  VISA_TOOL
//
//  Created by 付绘彬 on 15-4-20.
//  Copyright (c) 2015年 付绘彬. All rights reserved.
//

#import "GPIBComm.h"
enum PortStatus
{
	PortStatus_Whether_Init             =0x00000001 ,
	PortStatus_Whether_Connect_Success  =0x00000002 ,
} ;

#define SET_BIT_1(x)    portStatus|=(x)
#define SET_BIT_0(x)    portStatus&=~(x)
#define GET_BIT(x)      portStatus&x

@implementation GPIBComm
@synthesize mInstrIDN ;
-(id)init
{
	portStatus = 0X00000000 ;
	SET_BIT_0(PortStatus_Whether_Init|PortStatus_Whether_Connect_Success);//00000000
    // NSLog(PortStatus_Whether_Init|PortStatus_Whether_Connect_Success);
    mInstrIDN = nil ;
    self=[super init] ;
	if (self)
	{
        //then create resource manager
        mStatus = viOpenDefaultRM(&mDefaultRM) ;
        if (mStatus < VI_SUCCESS)
            NSLog(@"Could not open a session to the VISA Resource Manager!\n") ;
        else
            SET_BIT_1(PortStatus_Whether_Init);//00000001
        
        mInstrIDN = [[NSMutableString alloc] init] ;
        
        m_gpibLock = [NSLock new];
	}
	return self ;
}

-(void)dealloc
{
	SET_BIT_0(PortStatus_Whether_Init|PortStatus_Whether_Connect_Success);
    // viClose(mInst) ;
    // viClose(mDefaultRM) ;
    [mInstrIDN release] ;
    [m_gpibLock release];
	[super dealloc] ;
}


+(NSMutableArray*)ScanGPIBDevice
{
    ViSession defaultRM ;
    ViFindList findList;
    ViUInt32 numInstrs;
    char instrDescriptor[256];
    NSMutableArray *InstrList = [NSMutableArray new];
    
    
    ViStatus status ;
    
    status = viOpenDefaultRM(&defaultRM) ;
    if (status < VI_SUCCESS)
    {
        printf("Could not open a session to the VISA Resource Manager!\n");
        return nil ;
    }
    
    status = viFindRsrc (defaultRM, "GPIB[0-9]*::?*INSTR", &findList, &numInstrs, instrDescriptor);
    if (status < VI_SUCCESS)
    {
        printf ("An error occurred while finding resources.\nHit enter to continue.");
        viClose (defaultRM);
        return nil ;
    }
    
    [InstrList addObject:[NSString stringWithFormat:@"%s",instrDescriptor]];
    
    while (--numInstrs)
    {
        /* stay in this loop until we find all instruments */
        status = viFindNext (findList, instrDescriptor);  /* find next desriptor */
        if (status < VI_SUCCESS)
        {   /* did we find the next resource? */
            printf ("An error occurred finding the next resource.\nHit enter to continue.");
            fflush(stdin);
            getchar();
            viClose (defaultRM);
            return nil;
        }
        printf("%s \n",instrDescriptor);
        
        [InstrList addObject:[NSString stringWithFormat:@"%s",instrDescriptor]];
        
    }    /* end while */
    
    //return [NSString stringWithFormat:@"%s",instrDescriptor] ;
    viClose(defaultRM);
    return InstrList;
}

-(BOOL)Open:(NSString*)gpibAddr
{
    [m_gpibLock lock];
    SET_BIT_0(PortStatus_Whether_Init);
    viClose(mInst) ;
    viClose(mDefaultRM) ;
    mStatus = viOpenDefaultRM(&mDefaultRM) ;
    if (mStatus < VI_SUCCESS)
    {
        NSLog(@"Could not open a session to the VISA Resource Manager!\n");
        [m_gpibLock unlock];
        return FALSE ;
    }
    
    SET_BIT_1(PortStatus_Whether_Init);
    
	if (GET_BIT(PortStatus_Whether_Connect_Success))
	{
        viClose(mInst) ;
		SET_BIT_0(PortStatus_Whether_Connect_Success);
	}
   	//clear old info end
	[mInstrIDN setString:@""];
	SET_BIT_0(PortStatus_Whether_Connect_Success);
	
    //	NSString *strTmp = [NSString stringWithFormat:@"GPIB::%d::INSTR",addr] ;
    NSString *strTmp = [NSString stringWithString:gpibAddr] ;
    
    mStatus = viOpen (mDefaultRM, (char*)[strTmp UTF8String], VI_NULL, VI_NULL, &mInst);
    if (mStatus < VI_SUCCESS)
    {
        NSLog(@"Could not open a session to the device simulator");
        viClose (mInst);
        viClose(mDefaultRM);
        [m_gpibLock unlock];
        return FALSE ;
    }
    
    //    char cmd3[] = "*CLS\n" ;
    //    char cmd4[] = "MEAS:CURR:DC?\n";//"MEAS:CURR:DC? 1A,0.001MA\n" ;
    strcpy(mStringinput,"*RST\n");
    mStatus = viWrite (mInst, (ViBuf)mStringinput, (ViUInt32)strlen(mStringinput), &rcount);
    if (mStatus < VI_SUCCESS)
    {
        NSLog(@"Error writing to the instrument\n");
        viClose (mInst);
        [m_gpibLock unlock];
        return FALSE ;
    }
    
    strcpy(mStringinput,"*CLS\n");
    mStatus = viWrite (mInst, (ViBuf)mStringinput, (ViUInt32)strlen(mStringinput), &rcount);
    if (mStatus < VI_SUCCESS)
    {
        NSLog(@"Error writing to the instrument\n");
        viClose (mInst);
        [m_gpibLock unlock];
        return FALSE ;
    }
    
    
    strcpy(mStringinput,"*IDN?\n");
    mStatus = viWrite (mInst, (ViBuf)mStringinput, (ViUInt32)strlen(mStringinput), &rcount);
    if (mStatus < VI_SUCCESS)
    {
        NSLog(@"Error writing to the instrument\n");
        viClose (mInst);
        [m_gpibLock unlock];
        return FALSE ;
    }
    
    usleep(200) ;
    memset(mReceBuff, 0, receBuff_Len);
    
    mStatus = viRead (mInst, mReceBuff, receBuff_Len, &rcount);
    if (mStatus < VI_SUCCESS) //fail
    {
        NSLog(@"Error Reading From the instrument\n");
        viClose (mInst);
        [m_gpibLock unlock];
        return FALSE ;
    }
    
    [mInstrIDN setString:[NSString stringWithFormat:@"%s",mReceBuff]];
    SET_BIT_1(PortStatus_Whether_Connect_Success);
    [m_gpibLock unlock];
    return true ;
}

-(bool)IsOpen
{
	if (GET_BIT(PortStatus_Whether_Connect_Success))
		return true ;
	return false ;
}

-(void)Close
{
    [m_gpibLock lock];
	if (GET_BIT(PortStatus_Whether_Connect_Success))
	{
		viClose(mInst) ;
        viClose(mDefaultRM);
		SET_BIT_0(PortStatus_Whether_Connect_Success) ;
	}
	
	SET_BIT_0(PortStatus_Whether_Connect_Success);
    [m_gpibLock unlock];
	return ;
};



-(BOOL)Send:(NSString*)sendCMD
{
    [m_gpibLock lock];
	if (GET_BIT(PortStatus_Whether_Connect_Success))
	{
        //first to clear old buffer before sending cmd
        
        strcpy(mStringinput,sendCMD.UTF8String);
        mStatus = viWrite (mInst, (ViBuf)mStringinput, (ViUInt32)strlen(mStringinput), &rcount);
        if (mStatus < VI_SUCCESS)
        {
            NSLog(@"Error writing to the instrument\n");
            //viClose (mInst);
            SET_BIT_0(PortStatus_Whether_Connect_Success) ;
            [m_gpibLock unlock];
            return false ;
        }
        [m_gpibLock unlock];
		return true ;
	}
    [m_gpibLock unlock];
	return false ;
}

-(NSString*)Read
{
    [m_gpibLock lock];
	if (GET_BIT(PortStatus_Whether_Connect_Success))
	{
        memset(mReceBuff, 0, receBuff_Len);
        mStatus = viRead (mInst, mReceBuff, receBuff_Len, &rcount);
        if (mStatus < VI_SUCCESS) //fail
        {
            NSLog(@"Error Reading From the instrument\n");
            [m_gpibLock unlock];
            return nil ;
        }
        [m_gpibLock unlock];
		return [NSString stringWithFormat:@"%s",mReceBuff] ;
	}
    
    [m_gpibLock unlock];
	return nil ;
}


@end
