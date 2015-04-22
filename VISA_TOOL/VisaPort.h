//
//  CGPIB.h
//  GPIB
//
//  Created by Louis on 13-10-8.
//  Copyright (c) 2013年 Louis. All rights reserved.
//

#ifndef __GPIB__CGPIB__
#define __GPIB__CGPIB__

#include <iostream>
#import <Foundation/Foundation.h>
#import <VISA/VISA.h>
#import "GPIBComm.h"


class VisaPort {
public:
    VisaPort();
    ~VisaPort();
public:
    void AttachSerialPort(GPIBComm *gpibComm) ;
    
    bool WriteString(char *szCMD);
    char* ReadValue();

private:
    GPIBComm *mGpibComm ;
    pthread_mutex_t mMutexLock ;
};

#endif /* defined(__GPIB__CGPIB__) */
