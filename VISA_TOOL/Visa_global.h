//
//  GPIB_global.h
//  GPIB
//
//  Created by Louis on 13-10-9.
//  Copyright (c) 2013年 Louis. All rights reserved.
//

#ifndef __GPIB__GPIB_global__
#define __GPIB__GPIB_global__

#include <iostream>
#import "GPIBComm.h"
#import "VisaPort.h"

extern VisaPort   *gpibport;
extern GPIBComm *pGPIBComm  ;

#endif /* defined(__GPIB__GPIB_global__) */
