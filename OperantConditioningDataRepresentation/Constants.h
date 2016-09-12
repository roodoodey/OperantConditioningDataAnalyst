//
//  Constants.h
//  OperantConditioningDataRepresentation
//
//  Created by Mathieu Skulason on 17/09/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#ifndef OperantConditioningDataRepresentation_Constants_h
#define OperantConditioningDataRepresentation_Constants_h

enum {
    kMale = 0,
    kFemale = 1
};

enum {
    kFirstFreq = 0,
    kSecondFreq = 1,
    kThirdFreq = 2,
    kFourthFreq = 3,
    kFifthFreq = 4
};

enum {
    kFirstAmount = 0,
    kSecondAmount = 1,
    kThirdAmount = 2,
    kFourthAmount = 3,
    kFifthAmount = 4
};

typedef enum {
    kNoSchedule = 0,
    kFISchedule = 1,
    kVISchedule = 2,
    kFRSchedule = 3,
    kVRSchedule = 4
} ReinforcementSchedule;

#endif
