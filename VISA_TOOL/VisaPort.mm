//
//  CGPIB.cpp
//  GPIB
//
//  Created by Louis on 13-10-8.
//  Copyright (c) 2013年 Louis. All rights reserved.
//

#include "VisaPort.h"



VisaPort::VisaPort()
{
    mGpibComm = nil ;
    pthread_mutex_init(&mMutexLock, NULL) ;
}

VisaPort::~VisaPort()
{
    if (mGpibComm)
    {
        [mGpibComm Close] ;
        [mGpibComm release] ;
    }
    
    pthread_mutex_destroy(&mMutexLock) ;
    return ;
}

void VisaPort::AttachSerialPort(GPIBComm *gpibComm)
{
    GPIBComm *old = mGpibComm ;
    mGpibComm = [gpibComm retain] ;
    [old release] ;
    
    return ;
}

bool VisaPort::WriteString(char *szCmd)
{
    if (mGpibComm==nil)
        return false ;
    pthread_mutex_lock(&mMutexLock) ;
    bool rtn = [mGpibComm Send:[NSString stringWithFormat:@"%s",szCmd]];
    pthread_mutex_unlock(&mMutexLock) ;
    
    return rtn ;
}

char *VisaPort::ReadValue()
{
    if (mGpibComm==nil)
        return NULL ;
    
    pthread_mutex_lock(&mMutexLock) ;
    NSString *receStr = [mGpibComm Read];
    pthread_mutex_unlock(&mMutexLock) ;
    
    if (receStr==nil || receStr.length==0)
        return NULL ;
    return (char*)receStr.UTF8String ;
    
}